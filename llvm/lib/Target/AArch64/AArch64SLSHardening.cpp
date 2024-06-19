//===- AArch64SLSHardening.cpp - Harden Straight Line Missspeculation -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass to insert code to mitigate against side channel
// vulnerabilities that may happen under straight line miss-speculation.
//
//===----------------------------------------------------------------------===//

#include "AArch64InstrInfo.h"
#include "AArch64Subtarget.h"
#include "Utils/AArch64BaseInfo.h"
#include "llvm/CodeGen/IndirectThunks.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/Pass.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Target/TargetMachine.h"
#include <cassert>

using namespace llvm;

#define DEBUG_TYPE "aarch64-sls-hardening"

#define AARCH64_SLS_HARDENING_NAME "AArch64 sls hardening pass"

namespace {

class RequestedThunksInfo {
public:
  void requestThunk(unsigned OriginalOpcode, Register Xn, Register Xm = AArch64::NoRegister);

  using CallbackFn = std::function<void(unsigned OriginalOpcode, Register Xn, Register Xm)>;
  void forAllThunks(CallbackFn Callback) const;

  static SmallString<64> getThunkName(unsigned OriginalOpcode, Register Xn, Register Xm = AArch64::NoRegister);

  static constexpr StringRef BLRThunkPrefixCommon = "__llvm_slsblr_thunk";
  static constexpr StringRef BLRThunkPrefix       = "__llvm_slsblr_thunk";
  static constexpr StringRef BLRAAZThunkPrefix    = "__llvm_slsblr_thunk_aaz";
  static constexpr StringRef BLRABZThunkPrefix    = "__llvm_slsblr_thunk_abz";
  static constexpr StringRef BLRAAThunkPrefix     = "__llvm_slsblr_thunk_aa";
  static constexpr StringRef BLRABThunkPrefix     = "__llvm_slsblr_thunk_ab";

private:
  static constexpr unsigned NumPermittedRegs = 29;
  static constexpr struct {
    const char* Name;
    Register Reg;
  } NamesAndRegs[NumPermittedRegs] = {
    { "x0",  AArch64::X0},
    { "x1",  AArch64::X1},
    { "x2",  AArch64::X2},
    { "x3",  AArch64::X3},
    { "x4",  AArch64::X4},
    { "x5",  AArch64::X5},
    { "x6",  AArch64::X6},
    { "x7",  AArch64::X7},
    { "x8",  AArch64::X8},
    { "x9",  AArch64::X9},
    { "x10",  AArch64::X10},
    { "x11",  AArch64::X11},
    { "x12",  AArch64::X12},
    { "x13",  AArch64::X13},
    { "x14",  AArch64::X14},
    { "x15",  AArch64::X15},
    // X16 and X17 are deliberately missing, as the mitigation requires those
    // register to not be used in BLR. See comment in ConvertBLRToBL for more
    // details.
    { "x18",  AArch64::X18},
    { "x19",  AArch64::X19},
    { "x20",  AArch64::X20},
    { "x21",  AArch64::X21},
    { "x22",  AArch64::X22},
    { "x23",  AArch64::X23},
    { "x24",  AArch64::X24},
    { "x25",  AArch64::X25},
    { "x26",  AArch64::X26},
    { "x27",  AArch64::X27},
    { "x28",  AArch64::X28},
    { "x29",  AArch64::FP},
    // X30 is deliberately missing, for similar reasons as X16 and X17 are
    // missing.
    { "x31",  AArch64::XZR},
  };

  /// Returns small integer uniquely representing possible operand of BLR*.
  static unsigned getIndex(Register Reg);

  static StringRef getRegName(Register Reg) {
    return NamesAndRegs[getIndex(Reg)].Name;
  }

  uint32_t BLROperands = 0;
  uint32_t BLRAAZOperands = 0;
  uint32_t BLRABZOperands = 0;
  uint32_t BLRAAOperands[NumPermittedRegs] = { 0, };
  uint32_t BLRABOperands[NumPermittedRegs] = { 0, };
};

class AArch64RequestedThunksInfoWrapper : public ImmutablePass {
  RequestedThunksInfo RTI;

public:
  static char ID;
  explicit AArch64RequestedThunksInfoWrapper() : ImmutablePass(ID) {
    initializeAArch64RequestedThunksInfoWrapperPass(*PassRegistry::getPassRegistry());
  }

  RequestedThunksInfo &getRTI() { return RTI; }
  const RequestedThunksInfo &getRTI() const { return RTI; }
};

class AArch64SLSHardening : public MachineFunctionPass {
public:
  const TargetInstrInfo *TII;
  const TargetRegisterInfo *TRI;
  const AArch64Subtarget *ST;
  RequestedThunksInfo *RTI;

  static char ID;

  AArch64SLSHardening() : MachineFunctionPass(ID) {
    initializeAArch64SLSHardeningPass(*PassRegistry::getPassRegistry());
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AArch64RequestedThunksInfoWrapper>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &Fn) override;

  StringRef getPassName() const override { return AARCH64_SLS_HARDENING_NAME; }

private:
  bool hardenReturnsAndBRs(MachineBasicBlock &MBB) const;
  bool hardenBLRs(MachineBasicBlock &MBB) const;
  MachineBasicBlock &ConvertBLRToBL(MachineBasicBlock &MBB,
                                    MachineBasicBlock::instr_iterator) const;
};

} // end anonymous namespace

char AArch64RequestedThunksInfoWrapper::ID = 0;
char AArch64SLSHardening::ID = 0;

INITIALIZE_PASS(AArch64RequestedThunksInfoWrapper, "aarch64-sls-thunks-info-wrapper", "AArch64 SLS Thunks Info Wrapper", false, false)
INITIALIZE_PASS(AArch64SLSHardening, "aarch64-sls-hardening",
                AARCH64_SLS_HARDENING_NAME, false, false)

FunctionPass *llvm::createAArch64RequestedThunksInfoWrapperPass() {
  return new AArch64SLSHardening();
}

unsigned RequestedThunksInfo::getIndex(Register Reg) {
  assert(Reg != AArch64::X16 && Reg != AArch64::X17 && Reg != AArch64::LR);

  // Most Xn registers have consequent ids, except for FP and XZR.
  unsigned Result = (unsigned)Reg - (unsigned)AArch64::X0;
  if (Reg == AArch64::FP)
    Result = 29;
  else if (Reg == AArch64::XZR)
    Result = 31;

  // Account for X30 (LR) being forbidden.
  if (Result > 29)
    Result -= 1;
  // Account for X16 and X17 being forbidden.
  if (Result > 15)
    Result -= 2;

  // Ensure the assumptions about integer ids assigned by TableGen still hold.
  assert(Result < NumPermittedRegs &&
          "Reg is not from GPR64 or internal register numbering changed");
  assert(NamesAndRegs[Result].Reg == Reg && "Register numbering changed");

  return Result;
}

void RequestedThunksInfo::requestThunk(unsigned OriginalOpcode, Register Xn, Register Xm) {
  uint32_t XnBit = 1u << getIndex(Xn);

  switch (OriginalOpcode) {
  default:
    llvm_unreachable_internal("Unexpected opcode");
  case AArch64::BLR:
  case AArch64::BLRNoIP:
    BLROperands |= XnBit;
    break;
  case AArch64::BLRAAZ:
    BLRAAZOperands |= XnBit;
    break;
  case AArch64::BLRABZ:
    BLRABZOperands |= XnBit;
    break;
  case AArch64::BLRAA:
    BLRAAOperands[getIndex(Xm)] |= XnBit;
    break;
  case AArch64::BLRAB:
    BLRABOperands[getIndex(Xm)] |= XnBit;
    break;
  }
}

SmallString<64> RequestedThunksInfo::getThunkName(unsigned OriginalOpcode, Register Xn, Register Xm) {
  StringRef NamePrefix;
  bool IsTwoReg = false;

  switch (OriginalOpcode) {
  default:
    llvm_unreachable_internal("Unexpected opcode");
  case AArch64::BLR:
  case AArch64::BLRNoIP:
    NamePrefix = BLRThunkPrefix;
    break;
  case AArch64::BLRAAZ:
    NamePrefix = BLRAAZThunkPrefix;
    break;
  case AArch64::BLRABZ:
    NamePrefix = BLRABZThunkPrefix;
    break;
  case AArch64::BLRAA:
    IsTwoReg = true;
    NamePrefix = BLRAAThunkPrefix;
    break;
  case AArch64::BLRAB:
    IsTwoReg = true;
    NamePrefix = BLRABThunkPrefix;
    break;
  }

  if (IsTwoReg) {
    assert(Xm != AArch64::NoRegister && "Missing Xm operand");
    return formatv("{0}_{1}_{2}", NamePrefix, getRegName(Xn), getRegName(Xm)).sstr<64>();
  }
  assert(Xm == AArch64::NoRegister && "Unexpected Xm operand");
  return formatv("{0}_{1}", NamePrefix, getRegName(Xn)).sstr<64>();
}

void RequestedThunksInfo::forAllThunks(CallbackFn Callback) const {
  for (unsigned XnIndex = 0; XnIndex < NumPermittedRegs; ++XnIndex) {
    unsigned XnBit = 1u << XnIndex;
    Register XnReg = NamesAndRegs[XnIndex].Reg;
    if (BLROperands & XnBit)
      Callback(AArch64::BLR, XnReg, AArch64::NoRegister);
    if (BLRAAZOperands & XnBit)
      Callback(AArch64::BLRAAZ, XnReg, AArch64::NoRegister);
    if (BLRABZOperands & XnBit)
      Callback(AArch64::BLRABZ, XnReg, AArch64::NoRegister);
    for (unsigned XmIndex = 0; XmIndex < NumPermittedRegs; ++XmIndex) {
      Register XmReg = NamesAndRegs[XmIndex].Reg;
      if (BLRAAOperands[XmIndex] & XnBit)
        Callback(AArch64::BLRAA, XnReg, XmReg);
      if (BLRABOperands[XmIndex] & XnBit)
        Callback(AArch64::BLRAB, XnReg, XmReg);
    }
  }
}

static void insertSpeculationBarrier(const AArch64Subtarget *ST,
                                     MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator MBBI,
                                     DebugLoc DL,
                                     bool AlwaysUseISBDSB = false) {
  assert(MBBI != MBB.begin() &&
         "Must not insert SpeculationBarrierEndBB as only instruction in MBB.");
  assert(std::prev(MBBI)->isBarrier() &&
         "SpeculationBarrierEndBB must only follow unconditional control flow "
         "instructions.");
  assert(std::prev(MBBI)->isTerminator() &&
         "SpeculationBarrierEndBB must only follow terminators.");
  const TargetInstrInfo *TII = ST->getInstrInfo();
  unsigned BarrierOpc = ST->hasSB() && !AlwaysUseISBDSB
                            ? AArch64::SpeculationBarrierSBEndBB
                            : AArch64::SpeculationBarrierISBDSBEndBB;
  if (MBBI == MBB.end() ||
      (MBBI->getOpcode() != AArch64::SpeculationBarrierSBEndBB &&
       MBBI->getOpcode() != AArch64::SpeculationBarrierISBDSBEndBB))
    BuildMI(MBB, MBBI, DL, TII->get(BarrierOpc));
}

bool AArch64SLSHardening::runOnMachineFunction(MachineFunction &MF) {
  ST = &MF.getSubtarget<AArch64Subtarget>();
  TII = MF.getSubtarget().getInstrInfo();
  TRI = MF.getSubtarget().getRegisterInfo();
  RTI = &getAnalysis<AArch64RequestedThunksInfoWrapper>().getRTI();

  bool Modified = false;
  for (auto &MBB : MF) {
    Modified |= hardenReturnsAndBRs(MBB);
    Modified |= hardenBLRs(MBB);
  }

  return Modified;
}

static bool isBLR(const MachineInstr &MI) {
  switch (MI.getOpcode()) {
  case AArch64::BLR:
  case AArch64::BLRNoIP:
  case AArch64::BLRAA:
  case AArch64::BLRAB:
  case AArch64::BLRAAZ:
  case AArch64::BLRABZ:
    return true;
  }
  return false;
}

bool AArch64SLSHardening::hardenReturnsAndBRs(MachineBasicBlock &MBB) const {
  if (!ST->hardenSlsRetBr())
    return false;
  bool Modified = false;
  MachineBasicBlock::iterator MBBI = MBB.getFirstTerminator(), E = MBB.end();
  MachineBasicBlock::iterator NextMBBI;
  for (; MBBI != E; MBBI = NextMBBI) {
    MachineInstr &MI = *MBBI;
    NextMBBI = std::next(MBBI);
    if (MI.isReturn() || isIndirectBranchOpcode(MI.getOpcode())) {
      assert(MI.isTerminator());
      insertSpeculationBarrier(ST, MBB, std::next(MBBI), MI.getDebugLoc());
      Modified = true;
    }
  }
  return Modified;
}

namespace {
struct SLSBLRThunkInserter : ThunkInserter<SLSBLRThunkInserter> {
  const char *getThunkPrefix() {
    return RequestedThunksInfo::BLRThunkPrefixCommon.data();
  }
  bool mayUseThunk(const MachineFunction &MF, bool InsertedThunks) {
    if (InsertedThunks)
      return false;
    ComdatThunks &= !MF.getSubtarget<AArch64Subtarget>().hardenSlsNoComdat();
    // FIXME: This could also check if there are any BLRs in the function
    // to more accurately reflect if a thunk will be needed.
    return MF.getSubtarget<AArch64Subtarget>().hardenSlsBlr();
  }
  bool insertThunks(MachineModuleInfo &MMI, MachineFunction &MF);
  void populateThunk(MachineFunction &MF, unsigned Opcode, Register Xn, Register Xm);
  void populateThunk(MachineFunction &MF) {}

  void setRequestedThunksInfo(const RequestedThunksInfo &Req) { RTI = &Req; }

private:
  bool ComdatThunks = true;
  const RequestedThunksInfo *RTI;
};
} // namespace

static unsigned getThunkOpcode(unsigned OriginalOpcode) {
  switch (OriginalOpcode) {
  default:
    llvm_unreachable_internal("Unexpected opcode");
  case AArch64::BLR:
  case AArch64::BLRNoIP:
    return AArch64::BR;
  case AArch64::BLRAA:
    return AArch64::BRAA;
  case AArch64::BLRAB:
    return AArch64::BRAB;
  case AArch64::BLRAAZ:
    return AArch64::BRAAZ;
  case AArch64::BLRABZ:
    return AArch64::BRABZ;
  }
}

bool SLSBLRThunkInserter::insertThunks(MachineModuleInfo &MMI,
                                       MachineFunction &MF) {
  bool Modified = false;
  RTI->forAllThunks([&](unsigned OriginalOpcode, Register Xn, Register Xm) {
    unsigned ThunkOpcode = getThunkOpcode(OriginalOpcode);

    auto ThunkName = RequestedThunksInfo::getThunkName(OriginalOpcode, Xn, Xm);
    StringRef TargetAttrs = ThunkOpcode == AArch64::BR ? "" : "+pauth";
    createThunkFunction(MMI, ThunkName, ComdatThunks, TargetAttrs);

    Function *ThunkFn = MF.getFunction().getParent()->getFunction(ThunkName);
    MachineFunction *ThunkMF = MMI.getMachineFunction(*ThunkFn);
    populateThunk(*ThunkMF, ThunkOpcode, Xn, Xm);

    Modified = true;
  });
  return Modified;
}

void SLSBLRThunkInserter::populateThunk(MachineFunction &MF, unsigned Opcode, Register Xn, Register Xm) {
  assert(MF.getName().starts_with(getThunkPrefix()));
  const TargetInstrInfo *TII =
      MF.getSubtarget<AArch64Subtarget>().getInstrInfo();

  // Depending on whether this pass is in the same FunctionPassManager as the
  // IR->MIR conversion, the thunk may be completely empty, or contain a single
  // basic block with a single return instruction. Normalise it to contain a
  // single empty basic block.
  if (MF.size() == 1) {
    assert(MF.front().size() == 1);
    assert(MF.front().front().getOpcode() == AArch64::RET);
    MF.front().erase(MF.front().begin());
  } else {
    assert(MF.size() == 0);
    MF.push_back(MF.CreateMachineBasicBlock());
  }

  MachineBasicBlock *Entry = &MF.front();
  Entry->clear();

  //  These thunks need to consist of the following instructions:
  //  __llvm_slsblr_thunk_xN:
  //      ; BR instruction is not compatible with "BTI c" branch target
  //      ; in general, but "BR x16" is.
  //      MOV x16, xN
  //      BR x16
  //      barrierInsts
  Entry->addLiveIn(Xn);
  if (Xm != AArch64::NoRegister)
    Entry->addLiveIn(Xm);
  // MOV X16, Xn == ORR X16, XZR, Xn, LSL #0
  BuildMI(Entry, DebugLoc(), TII->get(AArch64::ORRXrs), AArch64::X16)
      .addReg(AArch64::XZR)
      .addReg(Xn)
      .addImm(0);
  auto &BMI = BuildMI(Entry, DebugLoc(), TII->get(Opcode)).addReg(AArch64::X16);
  if (Xm != AArch64::NoRegister)
    BMI.addReg(Xm);
  // Make sure the thunks do not make use of the SB extension in case there is
  // a function somewhere that will call to it that for some reason disabled
  // the SB extension locally on that function, even though it's enabled for
  // the module otherwise. Therefore set AlwaysUseISBSDB to true.
  insertSpeculationBarrier(&MF.getSubtarget<AArch64Subtarget>(), *Entry,
                           Entry->end(), DebugLoc(), true /*AlwaysUseISBDSB*/);
}

MachineBasicBlock &AArch64SLSHardening::ConvertBLRToBL(
    MachineBasicBlock &MBB, MachineBasicBlock::instr_iterator MBBI) const {
  // Transform a BLR to a BL as follows:
  // Before:
  //   |-----------------------------|
  //   |      ...                    |
  //   |  instI                      |
  //   |  BLR xN                     |
  //   |  instJ                      |
  //   |      ...                    |
  //   |-----------------------------|
  //
  // After:
  //   |-----------------------------|
  //   |      ...                    |
  //   |  instI                      |
  //   |  BL __llvm_slsblr_thunk_xN  |
  //   |  instJ                      |
  //   |      ...                    |
  //   |-----------------------------|
  //
  //   __llvm_slsblr_thunk_xN:
  //   |-----------------------------|
  //   |  MOV x16, xN                |
  //   |  BR x16                     |
  //   |  barrierInsts               |
  //   |-----------------------------|
  //
  // The __llvm_slsblr_thunk_xN thunks are created by the SLSBLRThunkInserter.
  // This function merely needs to transform BLR xN into
  // BL __llvm_slsblr_thunk_xN.
  //
  // Since linkers are allowed to clobber X16 and X17 on function calls, the
  // above mitigation only works if the original BLR instruction was not
  // BLR X16 nor BLR X17. Code generation before must make sure that no BLR
  // X16|X17 was produced if the mitigation is enabled.

  MachineInstr &BLR = *MBBI;
  assert(isBLR(BLR));
  unsigned OriginalOpcode = BLR.getOpcode();
  Register Xn, Xm;
  unsigned NumRegOperands;
  switch (OriginalOpcode) {
  case AArch64::BLRAA:
  case AArch64::BLRAB:
    Xn = BLR.getOperand(0).getReg();
    Xm = BLR.getOperand(1).getReg();
    NumRegOperands = 2;
    break;
  case AArch64::BLR:
  case AArch64::BLRNoIP:
  case AArch64::BLRAAZ:
  case AArch64::BLRABZ:
    Xn = BLR.getOperand(0).getReg();
    Xm = AArch64::NoRegister;
    NumRegOperands = 1;
    break;
  default:
    llvm_unreachable("unhandled BLR");
  }
  DebugLoc DL = BLR.getDebugLoc();

  MachineFunction &MF = *MBBI->getMF();
  MCContext &Context = MBB.getParent()->getContext();
  auto ThunkName = RequestedThunksInfo::getThunkName(BLR.getOpcode(), Xn, Xm);
  MCSymbol *Sym = Context.getOrCreateSymbol(ThunkName);
  RTI->requestThunk(OriginalOpcode, Xn, Xm);

  MachineInstr *BL = BuildMI(MBB, MBBI, DL, TII->get(AArch64::BL)).addSym(Sym);

  // Now copy the implicit operands from BLR to BL and copy other necessary
  // info.
  // However, both BLR and BL instructions implictly use SP and implicitly
  // define LR. Blindly copying implicit operands would result in SP and LR
  // operands to be present multiple times. While this may not be too much of
  // an issue, let's avoid that for cleanliness, by removing those implicit
  // operands from the BL created above before we copy over all implicit
  // operands from the BLR.
  int ImpLROpIdx = -1;
  int ImpSPOpIdx = -1;
  for (unsigned OpIdx = BL->getNumExplicitOperands();
       OpIdx < BL->getNumOperands(); OpIdx++) {
    MachineOperand Op = BL->getOperand(OpIdx);
    if (!Op.isReg())
      continue;
    if (Op.getReg() == AArch64::LR && Op.isDef())
      ImpLROpIdx = OpIdx;
    if (Op.getReg() == AArch64::SP && !Op.isDef())
      ImpSPOpIdx = OpIdx;
  }
  assert(ImpLROpIdx != -1);
  assert(ImpSPOpIdx != -1);
  int FirstOpIdxToRemove = std::max(ImpLROpIdx, ImpSPOpIdx);
  int SecondOpIdxToRemove = std::min(ImpLROpIdx, ImpSPOpIdx);
  BL->removeOperand(FirstOpIdxToRemove);
  BL->removeOperand(SecondOpIdxToRemove);
  // Now copy over the implicit operands from the original BLR
  BL->copyImplicitOps(MF, BLR);
  MF.moveCallSiteInfo(&BLR, BL);
  // Also add the register operands of the original BLR* instruction
  // as being used in the called thunk.
  assert(BLR.getNumExplicitOperands() == NumRegOperands && "Expected one or two register inputs");
  for (unsigned OpIdx = 0; OpIdx < NumRegOperands; ++OpIdx) {
    MachineOperand &Op = BLR.getOperand(OpIdx);
    BL->addOperand(MachineOperand::CreateReg(Op.getReg(), /*isDef=*/false,
                                             /*isImp=*/true, Op.isKill()));
  }
  // Remove BLR instruction
  MBB.erase(MBBI);

  return MBB;
}

bool AArch64SLSHardening::hardenBLRs(MachineBasicBlock &MBB) const {
  if (!ST->hardenSlsBlr())
    return false;
  bool Modified = false;
  MachineBasicBlock::instr_iterator MBBI = MBB.instr_begin(),
                                    E = MBB.instr_end();
  MachineBasicBlock::instr_iterator NextMBBI;
  for (; MBBI != E; MBBI = NextMBBI) {
    MachineInstr &MI = *MBBI;
    NextMBBI = std::next(MBBI);
    if (isBLR(MI)) {
      ConvertBLRToBL(MBB, MBBI);
      Modified = true;
    }
  }
  return Modified;
}

FunctionPass *llvm::createAArch64SLSHardeningPass() {
  return new AArch64SLSHardening();
}

namespace {
class AArch64IndirectThunks : public MachineFunctionPass {
public:
  static char ID;

  AArch64IndirectThunks() : MachineFunctionPass(ID) {}
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AArch64RequestedThunksInfoWrapper>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  StringRef getPassName() const override { return "AArch64 Indirect Thunks"; }

  bool doInitialization(Module &M) override;
  bool runOnMachineFunction(MachineFunction &MF) override;

private:
  std::tuple<SLSBLRThunkInserter> TIs;

  template <typename... ThunkInserterT>
  static void initTIs(Module &M,
                      std::tuple<ThunkInserterT...> &ThunkInserters) {
    (..., std::get<ThunkInserterT>(ThunkInserters).init(M));
  }
  template <typename... ThunkInserterT>
  static bool runTIs(MachineModuleInfo &MMI, MachineFunction &MF,
                     std::tuple<ThunkInserterT...> &ThunkInserters) {
    return (0 | ... | std::get<ThunkInserterT>(ThunkInserters).run(MMI, MF));
  }
};

} // end anonymous namespace

char AArch64IndirectThunks::ID = 0;

FunctionPass *llvm::createAArch64IndirectThunks() {
  return new AArch64IndirectThunks();
}

bool AArch64IndirectThunks::doInitialization(Module &M) {
  initTIs(M, TIs);
  return false;
}

bool AArch64IndirectThunks::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << getPassName() << '\n');
  auto &MMI = getAnalysis<MachineModuleInfoWrapperPass>().getMMI();
  auto &RTI = getAnalysis<AArch64RequestedThunksInfoWrapper>().getRTI();
  std::get<SLSBLRThunkInserter>(TIs).setRequestedThunksInfo(RTI);
  return runTIs(MMI, MF, TIs);
}
