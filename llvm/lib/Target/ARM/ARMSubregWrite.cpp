//===-------------------------- ARMSubregWrite.cpp ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// ARMSubregWrite pass attempts to mitigate a pipeline stall when an
// FP/ASIMD uop reads a D- or Q-register that has recently been
// written with one or more S-register results.
// ===----------------------------------------------------------------------===//

#include "ARM.h"
#include "ARMInstrInfo.h"
#include "MCTargetDesc/ARMAddressingModes.h"
#include "ARMMachineFunctionInfo.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "arm-subreg-write"
STATISTIC(NumHazardsFound, "Number of S-register forwarding hazards found");
STATISTIC(NumHazardsNotHandled,
          "Number of S-register forwarding hazards not handled");

namespace {
class ARMSubregWrite : public MachineFunctionPass {
  const TargetInstrInfo *TII;

public:
  static char ID;
  explicit ARMSubregWrite() : MachineFunctionPass(ID) {
    initializeARMSubregWritePass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &F) override;

  StringRef getPassName() const override {
    return "Fix incorrect subregister writes";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  bool runOnBasicBlock(MachineBasicBlock &MBB, MachineRegisterInfo &MRI);
};
char ARMSubregWrite::ID = 0;

} // namespace

INITIALIZE_PASS(ARMSubregWrite, "arm-subreg-writes-pass",
                "ARM subregister writes optimization", false, false)

bool ARMSubregWrite::runOnMachineFunction(MachineFunction &F) {
  LLVM_DEBUG(dbgs() << "***** ARMSubregWrite *****\n");
  bool Changed = false;
  TII = F.getSubtarget().getInstrInfo();
  MachineRegisterInfo &MRI = F.getRegInfo();

  for (auto &MBB : F) {
    Changed |= runOnBasicBlock(MBB, MRI);
  }
  return Changed;
}

static bool isFPASIMDInstr(const MachineInstr &MI) {
  switch (MI.getOpcode()) {
  case ARM::NEON_VMAXNMNDf:
  case ARM::NEON_VMAXNMNQf:
  case ARM::NEON_VMINNMNDf:
  case ARM::NEON_VMINNMNQf:
  case ARM::VABDfd:
  case ARM::VABDfq:
  case ARM::VABSfd:
  case ARM::VABSfq:
  case ARM::VACGEfd:
  case ARM::VACGEfq:
  case ARM::VACGTfd:
  case ARM::VACGTfq:
  case ARM::VADDfd:
  case ARM::VADDfq:
  case ARM::VCEQfd:
  case ARM::VCEQfq:
  case ARM::VCGEfd:
  case ARM::VCGEfq:
  case ARM::VCGTfd:
  case ARM::VCGTfq:
  case ARM::VFMAfd:
  case ARM::VFMAfq:
  case ARM::VFMSfd:
  case ARM::VFMSfq:
  case ARM::VMAXfd:
  case ARM::VMAXfq:
  case ARM::VMINfd:
  case ARM::VMINfq:
  case ARM::VMLAfd:
  case ARM::VMLAfq:
  case ARM::VMLSfd:
  case ARM::VMLSfq:
  case ARM::VMULfd:
  case ARM::VMULfq:
  case ARM::VNEGfd:
  case ARM::VNEGf32q:
  case ARM::VRECPEfd:
  case ARM::VRECPEfq:
  case ARM::VRECPSfd:
  case ARM::VRECPSfq:
  case ARM::VRSQRTEfd:
  case ARM::VRSQRTEfq:
  case ARM::VRSQRTSfd:
  case ARM::VRSQRTSfq:
  case ARM::VSUBfd:
  case ARM::VSUBfq:
  case ARM::VEXTd32:
  case ARM::VEXTq32:
  case ARM::VORNd:
  case ARM::VORNq:
  case ARM::VORRd:
  case ARM::VORRq:
  case ARM::VANDd:
  case ARM::VANDq:
  case ARM::VEORd:
  case ARM::VEORq:
  case ARM::VBICd:
  case ARM::VBICq:
  case ARM::VBIFd:
  case ARM::VBIFq:
  case ARM::VBITd:
  case ARM::VBITq:
  case ARM::VBSLd:
  case ARM::VBSLq:
  case ARM::VBSPd:
  case ARM::VBSPq:
  case ARM::VCNTd:
  case ARM::VCNTq:
  case ARM::VMVNd:
  case ARM::VMVNq:
  case ARM::VABALsv4i32:
  case ARM::VABALuv4i32:
  case ARM::VABAsv2i32:
  case ARM::VABAsv4i32:
  case ARM::VABAuv2i32:
  case ARM::VABAuv4i32:
  case ARM::VABDLsv4i32:
  case ARM::VABDLuv4i32:
  case ARM::VABDsv2i32:
  case ARM::VABDsv4i32:
  case ARM::VABDuv2i32:
  case ARM::VABDuv4i32:
  case ARM::VABSv2i32:
  case ARM::VABSv4i32:
  case ARM::VADDHNv2i32:
  case ARM::VADDLsv4i32:
  case ARM::VADDLuv4i32:
  case ARM::VADDWsv4i32:
  case ARM::VADDWuv4i32:
  case ARM::VADDv2i32:
  case ARM::VADDv4i32:
  case ARM::VBICiv2i32:
  case ARM::VBICiv4i32:
  case ARM::VCADDv2f32:
  case ARM::VCADDv4f32:
  case ARM::VCEQv2i32:
  case ARM::VCEQv4i32:
  case ARM::VCEQzv2f32:
  case ARM::VCEQzv2i32:
  case ARM::VCEQzv4f32:
  case ARM::VCEQzv4i32:
  case ARM::VCGEsv2i32:
  case ARM::VCGEsv4i32:
  case ARM::VCGEuv2i32:
  case ARM::VCGEuv4i32:
  case ARM::VCGEzv2f32:
  case ARM::VCGEzv2i32:
  case ARM::VCGEzv4f32:
  case ARM::VCGEzv4i32:
  case ARM::VCGTsv2i32:
  case ARM::VCGTsv4i32:
  case ARM::VCGTuv2i32:
  case ARM::VCGTuv4i32:
  case ARM::VCGTzv2f32:
  case ARM::VCGTzv2i32:
  case ARM::VCGTzv4f32:
  case ARM::VCGTzv4i32:
  case ARM::VCLEzv2f32:
  case ARM::VCLEzv2i32:
  case ARM::VCLEzv4f32:
  case ARM::VCLEzv4i32:
  case ARM::VCLSv2i32:
  case ARM::VCLSv4i32:
  case ARM::VCLTzv2f32:
  case ARM::VCLTzv2i32:
  case ARM::VCLTzv4f32:
  case ARM::VCLTzv4i32:
  case ARM::VCLZv2i32:
  case ARM::VCLZv4i32:
  case ARM::VCMLAv2f32:
  case ARM::VCMLAv2f32_indexed:
  case ARM::VCMLAv4f32:
  case ARM::VCMLAv4f32_indexed:
  case ARM::VHADDsv2i32:
  case ARM::VHADDsv4i32:
  case ARM::VHADDuv2i32:
  case ARM::VHADDuv4i32:
  case ARM::VHSUBsv2i32:
  case ARM::VHSUBsv4i32:
  case ARM::VHSUBuv2i32:
  case ARM::VHSUBuv4i32:
  case ARM::VMAXsv2i32:
  case ARM::VMAXsv4i32:
  case ARM::VMAXuv2i32:
  case ARM::VMAXuv4i32:
  case ARM::VMINsv2i32:
  case ARM::VMINsv4i32:
  case ARM::VMINuv2i32:
  case ARM::VMINuv4i32:
  case ARM::VMLALslsv2i32:
  case ARM::VMLALsluv2i32:
  case ARM::VMLALsv4i32:
  case ARM::VMLALuv4i32:
  case ARM::VMLAslv2i32:
  case ARM::VMLAslv4i32:
  case ARM::VMLAv2i32:
  case ARM::VMLAv4i32:
  case ARM::VMLSLslsv2i32:
  case ARM::VMLSLsluv2i32:
  case ARM::VMLSLsv4i32:
  case ARM::VMLSLuv4i32:
  case ARM::VMLSslv2i32:
  case ARM::VMLSslv4i32:
  case ARM::VMLSv2i32:
  case ARM::VMLSv4i32:
  case ARM::VMOVLsv4i32:
  case ARM::VMOVLuv4i32:
  case ARM::VMOVNv2i32:
  case ARM::VMOVv2f32:
  case ARM::VMOVv2i32:
  case ARM::VMOVv4f32:
  case ARM::VMOVv4i32:
  case ARM::VMULLslsv2i32:
  case ARM::VMULLsluv2i32:
  case ARM::VMULLsv4i32:
  case ARM::VMULLuv4i32:
  case ARM::VMULslv2i32:
  case ARM::VMULslv4i32:
  case ARM::VMULv2i32:
  case ARM::VMULv4i32:
  case ARM::VMVNv2i32:
  case ARM::VMVNv4i32:
  case ARM::VORRiv2i32:
  case ARM::VORRiv4i32:
  case ARM::VPADALsv2i32:
  case ARM::VPADALsv4i32:
  case ARM::VPADALuv2i32:
  case ARM::VPADALuv4i32:
  case ARM::VPADDLsv2i32:
  case ARM::VPADDLsv4i32:
  case ARM::VPADDLuv2i32:
  case ARM::VPADDLuv4i32:
  case ARM::VQABSv2i32:
  case ARM::VQABSv4i32:
  case ARM::VQADDsv2i32:
  case ARM::VQADDsv4i32:
  case ARM::VQADDuv2i32:
  case ARM::VQADDuv4i32:
  case ARM::VQDMLALslv2i32:
  case ARM::VQDMLALv4i32:
  case ARM::VQDMLSLslv2i32:
  case ARM::VQDMLSLv4i32:
  case ARM::VQDMULHslv2i32:
  case ARM::VQDMULHslv4i32:
  case ARM::VQDMULHv2i32:
  case ARM::VQDMULHv4i32:
  case ARM::VQDMULLslv2i32:
  case ARM::VQDMULLv4i32:
  case ARM::VQMOVNsuv2i32:
  case ARM::VQMOVNsv2i32:
  case ARM::VQMOVNuv2i32:
  case ARM::VQNEGv2i32:
  case ARM::VQNEGv4i32:
  case ARM::VQRDMLAHslv2i32:
  case ARM::VQRDMLAHslv4i32:
  case ARM::VQRDMLAHv2i32:
  case ARM::VQRDMLAHv4i32:
  case ARM::VQRDMLSHslv2i32:
  case ARM::VQRDMLSHslv4i32:
  case ARM::VQRDMLSHv2i32:
  case ARM::VQRDMLSHv4i32:
  case ARM::VQRDMULHslv2i32:
  case ARM::VQRDMULHslv4i32:
  case ARM::VQRDMULHv2i32:
  case ARM::VQRDMULHv4i32:
  case ARM::VQRSHLsv2i32:
  case ARM::VQRSHLsv4i32:
  case ARM::VQRSHLuv2i32:
  case ARM::VQRSHLuv4i32:
  case ARM::VQRSHRNsv2i32:
  case ARM::VQRSHRNuv2i32:
  case ARM::VQRSHRUNv2i32:
  case ARM::VQSHLsiv2i32:
  case ARM::VQSHLsiv4i32:
  case ARM::VQSHLsuv2i32:
  case ARM::VQSHLsuv4i32:
  case ARM::VQSHLsv2i32:
  case ARM::VQSHLsv4i32:
  case ARM::VQSHLuiv2i32:
  case ARM::VQSHLuiv4i32:
  case ARM::VQSHLuv2i32:
  case ARM::VQSHLuv4i32:
  case ARM::VQSHRNsv2i32:
  case ARM::VQSHRNuv2i32:
  case ARM::VQSHRUNv2i32:
  case ARM::VQSUBsv2i32:
  case ARM::VQSUBsv4i32:
  case ARM::VQSUBuv2i32:
  case ARM::VQSUBuv4i32:
  case ARM::VRADDHNv2i32:
  case ARM::VRHADDsv2i32:
  case ARM::VRHADDsv4i32:
  case ARM::VRHADDuv2i32:
  case ARM::VRHADDuv4i32:
  case ARM::VRSHLsv2i32:
  case ARM::VRSHLsv4i32:
  case ARM::VRSHLuv2i32:
  case ARM::VRSHLuv4i32:
  case ARM::VRSHRNv2i32:
  case ARM::VRSHRsv2i32:
  case ARM::VRSHRsv4i32:
  case ARM::VRSHRuv2i32:
  case ARM::VRSHRuv4i32:
  case ARM::VRSRAsv2i32:
  case ARM::VRSRAsv4i32:
  case ARM::VRSRAuv2i32:
  case ARM::VRSRAuv4i32:
  case ARM::VRSUBHNv2i32:
  case ARM::VSHLLsv4i32:
  case ARM::VSHLLuv4i32:
  case ARM::VSHLiv2i32:
  case ARM::VSHLiv4i32:
  case ARM::VSHLsv2i32:
  case ARM::VSHLsv4i32:
  case ARM::VSHLuv2i32:
  case ARM::VSHLuv4i32:
  case ARM::VSHRNv2i32:
  case ARM::VSHRsv2i32:
  case ARM::VSHRsv4i32:
  case ARM::VSHRuv2i32:
  case ARM::VSHRuv4i32:
  case ARM::VSLIv2i32:
  case ARM::VSLIv4i32:
  case ARM::VSRAsv2i32:
  case ARM::VSRAsv4i32:
  case ARM::VSRAuv2i32:
  case ARM::VSRAuv4i32:
  case ARM::VSRIv2i32:
  case ARM::VSRIv4i32:
  case ARM::VSUBHNv2i32:
  case ARM::VSUBLsv4i32:
  case ARM::VSUBLuv4i32:
  case ARM::VSUBWsv4i32:
  case ARM::VSUBWuv4i32:
  case ARM::VSUBv2i32:
  case ARM::VSUBv4i32:
  case ARM::VTSTv2i32:
  case ARM::VTSTv4i32:
    return true;
  default:
    return false;
  }
}

struct DQRegDesc {
  SmallVector<Register, 2> DRegs;
  SmallVector<Register, 4> SRegs;
};

// Provide DenseMapInfo for chars.
template<> struct llvm::DenseMapInfo<DQRegDesc> {
  static inline DQRegDesc getEmptyKey() {
    return DQRegDesc();
  }
  static inline DQRegDesc getTombstoneKey() {
    DQRegDesc DQReg;
    DQReg.SRegs.push_back(0);
    return DQReg;
  }
  static unsigned getHashValue(const DQRegDesc& DQReg) {
    unsigned Val = 0;
    for (unsigned I = 0; I < DQReg.DRegs.size(); ++I) {
      Val |= DQReg.DRegs[I] << (I * 8);
    }
    for (unsigned I = 0; I < DQReg.SRegs.size(); ++I) {
      Val |= DQReg.SRegs[I] << (I * 8);
    }
    return Val;
  }
  static bool isEqual(const DQRegDesc &LHS, const DQRegDesc &RHS) {
    if (LHS.DRegs.size() != RHS.DRegs.size())
      return false;

    if (LHS.SRegs.size() != RHS.SRegs.size())
      return false;

    for (unsigned I = 0; I < LHS.DRegs.size(); ++I) {
      if (LHS.DRegs[I] != RHS.DRegs[I])
	return false;
    }

    for (unsigned I = 0; I < LHS.SRegs.size(); ++I) {
      if (LHS.SRegs[I] != RHS.SRegs[I])
	return false;
    }
    return true;
  }
};

static bool matchSRegSequence(MachineInstr &MI, const MachineRegisterInfo &MRI,
                              SmallVectorImpl<Register> &SRegs) {
  if (!MI.isRegSequence())
    return false;

  // We're looking for either Dreg (2 x Sreg) or Qreg (4 x Sreg)
  assert(MI.getNumOperands() % 2 == 1);
  if (MI.getNumOperands() < 5)
    return false;

  for (unsigned OpIdx = 1; OpIdx < MI.getNumOperands(); OpIdx += 2) {
    MachineOperand &MOP = MI.getOperand(OpIdx);
    Register SReg = MOP.getReg();
    if (MRI.getRegClass(SReg) != &ARM::SPRRegClass)
      return false;
    uint16_t Index = 0;
    switch (MI.getOperand(OpIdx + 1).getImm()) {
    case ARM::ssub_0:
      Index = 0;
      break;
    case ARM::ssub_1:
      Index = 1;
      break;
    case ARM::ssub_2:
      Index = 2;
      break;
    case ARM::ssub_3:
      Index = 3;
      break;
    default:
      llvm_unreachable("Unhandled index.");
    }

    if (SRegs.empty()) {
      unsigned NumSubregs = (MI.getNumOperands() - 1) / 2;
      SRegs.resize(NumSubregs);
      assert((SRegs.size() == 2 || SRegs.size() == 4) &&
             "Unexpected number of sub-registers in a REG_SEQUENCE");
    }
    assert(SReg);
    SRegs[Index] = SReg;
  }
  return true;
}

static bool matchSRegInsertSubreg(MachineInstr &MI,
                                  const MachineRegisterInfo &MRI,
                                  Register &SrcReg,
                                  SmallVectorImpl<Register> &SRegs) {
  if (!MI.isInsertSubreg())
    return false;

  SrcReg = MI.getOperand(1).getReg();
  Register SReg = MI.getOperand(2).getReg();
  if (MRI.getRegClass(SReg) != &ARM::SPRRegClass)
    return false;

  uint16_t Index = 0;
  switch (MI.getOperand(3).getImm()) {
  case ARM::ssub_0:
    Index = 0;
    break;
  case ARM::ssub_1:
    Index = 1;
    break;
  case ARM::ssub_2:
    Index = 2;
    break;
  case ARM::ssub_3:
    Index = 3;
    break;
  default:
    llvm_unreachable("Unhandled index.");
  }

  if (SRegs.empty()) {
    const TargetRegisterClass *RC = MRI.getRegClass(SrcReg);
    bool IsQReg = RC == &ARM::QPRRegClass || RC == &ARM::MQPRRegClass ||
                  RC == &ARM::QPR_VFP2RegClass;

    if (IsQReg)
      SRegs.resize(4);
    else
      SRegs.resize(2);
  }

  assert(SReg);
  SRegs[Index] = SReg;
  return true;
}

// Insert a pair of VMOVRS and VSETLNi32 to copy an S-register using a
// scalar write to the corresponding D-register.
void insertSRegCopy(DQRegDesc &DQReg, Register SReg, uint16_t Index,
		    MachineBasicBlock &MBB,
		    MachineBasicBlock::iterator InsertPt,
		    const DebugLoc &DL, const TargetInstrInfo &TII,
		    MachineRegisterInfo &MRI) {
  // FIXME: VSETLN doesn't work with S-registers, so we have to copy
  // via a core register. Is there a better way to do this?
  Register TmpGPReg = MRI.createVirtualRegister(&ARM::GPRRegClass);
  MachineInstr *TmpCopyDef =
      BuildMI(MBB, InsertPt, DL, TII.get(ARM::VMOVRS), TmpGPReg)
          .addReg(SReg)
          .add(predOps(ARMCC::AL));
  LLVM_DEBUG(dbgs() << "New instr: " << *TmpCopyDef);

  unsigned DRegIndex = Index / 2;
  Register DReg = DQReg.DRegs[DRegIndex];

  Register NewDReg = MRI.cloneVirtualRegister(DReg);
  MachineInstr *NewDef =
      BuildMI(MBB, InsertPt, DL, TII.get(ARM::VSETLNi32), NewDReg)
          .addReg(DReg)
          .addReg(TmpGPReg)
          .addImm(Index)
          .add(predOps(ARMCC::AL));
  LLVM_DEBUG(dbgs() << "New instr: " << *NewDef);

  DQReg.DRegs[DRegIndex] = NewDReg;
}

// Insert a VLD1 to replace a VLDRS instruction.
void insertVLD1FromVLDRS(DQRegDesc &DQReg, Register AddrReg,
			 unsigned VLDRSOffset, uint16_t Index,
			 MachineBasicBlock &MBB,
			 MachineBasicBlock::iterator InsertPt,
			 const DebugLoc &DL, const TargetInstrInfo &TII,
			 MachineRegisterInfo &MRI) {
  if (VLDRSOffset != 0) {
    unsigned Offset = ARM_AM::getAM5Offset(VLDRSOffset);
    unsigned UnscaledOffset = Offset * 4;
    bool IsSub = ARM_AM::getAM5Op(VLDRSOffset) == ARM_AM::sub;
    Register NewAddr = MRI.cloneVirtualRegister(AddrReg);

    ARMFunctionInfo *AFI = MBB.getParent()->getInfo<ARMFunctionInfo>();
    unsigned ADDriOpc = !AFI->isThumbFunction() ? ARM::ADDri : ARM::t2ADDri;
    unsigned SUBriOpc = !AFI->isThumbFunction() ? ARM::SUBri : ARM::t2SUBri;

    MachineInstr *NewAddrDef =
        BuildMI(MBB, InsertPt, DL, TII.get(IsSub ? SUBriOpc : ADDriOpc),
                NewAddr)
            .addReg(AddrReg)
            .addImm(UnscaledOffset)
            .add(predOps(ARMCC::AL))
            .add(condCodeOp());
    LLVM_DEBUG(dbgs() << "New instr: " << *NewAddrDef);
    AddrReg = NewAddr;
  }

  unsigned DRegIndex = Index / 2;
  Register DReg = DQReg.DRegs[DRegIndex];

  Register NewDReg = MRI.cloneVirtualRegister(DReg);
  unsigned Alignment = 0; // conservatively set to zero
  MachineInstr *NewDef =
      BuildMI(MBB, InsertPt, DL, TII.get(ARM::VLD1LNd32), NewDReg)
          .addReg(AddrReg)
          .addImm(Alignment)
          .addReg(DReg)
          .addImm(Index)
          .add(predOps(ARMCC::AL));
  LLVM_DEBUG(dbgs() << "New instr: " << *NewDef);

  DQReg.DRegs[DRegIndex] = NewDReg;
}

void rewriteSRegDef(DQRegDesc &DQReg, Register SReg, uint16_t Index,
		    MachineBasicBlock &MBB,
		    MachineBasicBlock::iterator InsertPt,
		    const DebugLoc &DL, const TargetInstrInfo &TII,
		    MachineRegisterInfo &MRI) {
  assert(SReg);
  MachineOperand *SRegDefOp = MRI.getOneDef(SReg);
  if (!SRegDefOp || &MBB != SRegDefOp->getParent()->getParent()) {
    LLVM_DEBUG(dbgs() << "No def found in the current BB\n");
    insertSRegCopy(DQReg, SReg, Index, MBB, InsertPt, DL, TII, MRI);
    return;
  }
  MachineInstr *SRegDef = SRegDefOp->getParent();

  LLVM_DEBUG(dbgs() << "Rewriting " << *SRegDef);
  switch (SRegDef->getOpcode()) {
  case ARM::VLDRS: {
    const MachineOperand &AddrOp = SRegDef->getOperand(1);
    if (!AddrOp.isReg()) {
      insertSRegCopy(DQReg, SReg, Index, MBB, InsertPt, DL, TII, MRI);
      return;
    }

    Register AddrReg = AddrOp.getReg();
    unsigned Offset = SRegDef->getOperand(2).getImm();
    insertVLD1FromVLDRS(DQReg, AddrReg, Offset, Index, MBB,
			InsertPt, DL, TII, MRI);
    return;
  }
  case TargetOpcode::IMPLICIT_DEF: {
    return;
  }
  default: {
    insertSRegCopy(DQReg, SReg, Index, MBB, InsertPt, DL, TII, MRI);
    return;
  }
  }
  llvm_unreachable("Unhandled instruction");
}

typedef DenseMap<DQRegDesc, SmallVector<MachineOperand *, 8>> DQRegToUsersMap;

static void findHazardCandidates(MachineInstr &MI, MachineRegisterInfo &MRI,
                                 DQRegToUsersMap &HazardCandidates) {
  LLVM_DEBUG(dbgs() << "Scanning: " << MI);
  if (!isFPASIMDInstr(MI))
    return;
  for (MachineOperand &MOP : MI.uses()) {
    if (!MOP.isReg() || MOP.isImplicit())
      continue;
    MachineInstr *MOPDef = MRI.getUniqueVRegDef(MOP.getReg());
    if (!MOPDef) {
      LLVM_DEBUG(dbgs() << "Unable to find a unique def for " << MOP << '\n');
      continue;
    }

    DQRegDesc DQReg;
    if (matchSRegSequence(*MOPDef, MRI, DQReg.SRegs)) {
      LLVM_DEBUG(dbgs() << "Candidate: " << MOP << '\n');
      HazardCandidates[DQReg].push_back(&MOP);
      ++NumHazardsFound;
      continue;
    }
    Register SrcReg;
    if (matchSRegInsertSubreg(*MOPDef, MRI, SrcReg, DQReg.SRegs)) {
      MachineInstr *SrcRegDef = MRI.getUniqueVRegDef(SrcReg);
      if (!SrcRegDef) {
        LLVM_DEBUG(dbgs() << "Unable to find a unique def for "
                          << MRI.getVRegName(SrcReg) << '\n');
        continue;
      }
      if (!SrcRegDef->isImplicitDef()) {
        LLVM_DEBUG(dbgs() << "Nested INSERT_SUBREG is not supported\n");
        ++NumHazardsNotHandled;
        continue;
      }
      LLVM_DEBUG(dbgs() << "Candidate: " << MOP << '\n');
      ++NumHazardsFound;
      HazardCandidates[DQReg].push_back(&MOP);
    }
  }
}

DQRegDesc createDQReg(const DQRegDesc &DQReg,
                     MachineBasicBlock::iterator InsertPt,
                     MachineBasicBlock &MBB, const DebugLoc &DL,
                     MachineRegisterInfo &MRI, const TargetInstrInfo &TII) {
  assert(DQReg.SRegs.size() == 2 || DQReg.SRegs.size() == 4);

  bool IsDReg = DQReg.SRegs.size() == 2;
  const TargetRegisterClass *DRC = &ARM::DPRRegClass;

  DQRegDesc NewDQReg;
  Register DReg0 = MRI.createVirtualRegister(DRC);
  MachineInstr *ImplicitDef0 =
      BuildMI(MBB, InsertPt, DL, TII.get(TargetOpcode::IMPLICIT_DEF), DReg0);
  LLVM_DEBUG(dbgs() << "New instr: " << *ImplicitDef0);

  if (IsDReg){
    NewDQReg.DRegs.push_back(DReg0);
    return NewDQReg;
  }

  Register DReg1 = MRI.createVirtualRegister(DRC);
  MachineInstr *ImplicitDef1 =
      BuildMI(MBB, InsertPt, DL, TII.get(TargetOpcode::IMPLICIT_DEF), DReg1);
  LLVM_DEBUG(dbgs() << "New instr: " << *ImplicitDef1);

  NewDQReg.DRegs.push_back(DReg0);
  NewDQReg.DRegs.push_back(DReg1);
  return NewDQReg;
}

bool ARMSubregWrite::runOnBasicBlock(MachineBasicBlock &MBB,
                                     MachineRegisterInfo &MRI) {
  assert(MRI.isSSA());

  LLVM_DEBUG(dbgs() << "Running on MBB: " << MBB
                    << " - scanning instructions...\n");
  DQRegToUsersMap HazardCandidates;
  for (MachineInstr &MI : MBB) {
    findHazardCandidates(MI, MRI, HazardCandidates);
  }
  LLVM_DEBUG(dbgs() << "Scan complete, found " << HazardCandidates.size()
                    << " register forwarding hazards.\n");
  if (HazardCandidates.empty())
    return false;

  for (auto &KV : HazardCandidates) {
    const DQRegDesc &DQReg = KV.first;
    SmallVectorImpl<MachineOperand *> &FixOps = KV.second;
    assert(!FixOps.empty());

    MachineInstr *DQRegUser = FixOps[0]->getParent();
    MachineBasicBlock::iterator InsertPt(DQRegUser);
    const DebugLoc &DL = DQRegUser->getDebugLoc();

    DQRegDesc NewDQReg = createDQReg(DQReg, InsertPt, MBB, DL, MRI, *TII);

    for (unsigned I = 0; I < DQReg.SRegs.size(); ++I) {
      Register SReg = DQReg.SRegs[I];
      if (SReg) {
	rewriteSRegDef(NewDQReg, SReg, I, MBB, InsertPt, DL, *TII, MRI);
      }
    }
    Register NewReg;
    if (NewDQReg.DRegs.size() == 1) {
      NewReg = NewDQReg.DRegs[0];
    } else {
      assert(NewDQReg.DRegs.size() == 2);
      NewReg = MRI.createVirtualRegister(&ARM::MQPRRegClass);
      MachineInstr *RegSeq =
	BuildMI(MBB, InsertPt, DL, TII->get(ARM::REG_SEQUENCE), NewReg)
	.addReg(NewDQReg.DRegs[0])
	.addImm(ARM::dsub_0)
	.addReg(NewDQReg.DRegs[1])
	.addImm(ARM::dsub_1);
      LLVM_DEBUG(dbgs() << "New instr: " << *RegSeq);
    }
    for (MachineOperand *Op : FixOps) {
      Op->setReg(NewReg);
    }
  }

  LLVM_DEBUG(dbgs() << "Final MBB:\n" << MBB);
  return /*Changed*/ true;
}

FunctionPass *llvm::createARMSubregWrite() { return new ARMSubregWrite(); }
