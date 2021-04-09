//===- ARMPostIndexingOptimizer.cpp - Prepare ld/st for post-indexing -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file This file contains a pass that makes address computation for
/// load / store operations that are likely to be emitted as NEON instructions
/// more post-indexing friendly.
///
/// Unlike MVE and AArch64 ASIMD, NEON has rather restricted set of modes for
/// address computation, specifically it lacks immediate offsets for vld1/vst1.
/// In some cases this makes codegen emit some ad-hoc address computation code
/// instead of simply adjusting the base address and emitting a sequence of
/// post-indexed load / store instructions afterwards.
//
//===----------------------------------------------------------------------===//

#include "ARM.h"
#include "ARMSubtarget.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicsARM.h"
#include "llvm/Pass.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

#define DEBUG_TYPE "arm-post-indexing-opt"
#define PASS_DESC "ARM post-indexed access optimizer"

namespace {

// This class stores an information about the base address and immediate offset
// of a memory access obtained by a best-effort heuristic as well as other
// useful instruction properties.
struct LdStInfo {
  LdStInfo(const DataLayout &DL, Instruction *LdSt, unsigned BaseOperandIndex,
           int AccessSize);
  // A memory access in question
  Instruction *LdSt;
  // An actual operand of LdSt can be updated throughout this pass execution,
  // so store an index instead
  unsigned BaseOperandIndex;
  // A guessed base address
  Value *IndirectBase;
  // An immediate offset to add to IndirectBase
  int32_t Offset;
  // An access size that can be used for post-indexed addressing mode
  int AccessSize;

  // Returns current *direct* base operand
  Value *getBaseOperand() { return LdSt->getOperand(BaseOperandIndex); }
};

struct ARMPostIndexingOpt : public FunctionPass {
  static char ID;

  ARMPostIndexingOpt() : FunctionPass(ID) {}

  StringRef getPassName() const override { return PASS_DESC; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<TargetLibraryInfoWrapperPass>();
    AU.addRequired<TargetPassConfig>();
    AU.setPreservesCFG();
  }

  bool runOnFunction(Function &F) override;

private:
  // Returns (nullptr, 0) for instructions not handled by this pass
  std::pair<Type *, unsigned> getDataTypeAndBaseIndex(Instruction *I) const;
  // Guess a common stride (aside from post-incrementing by access size) that
  // is suitable for "[Rn], Rm" addressing mode, if any
  int32_t guessCustomAccessStride(ArrayRef<LdStInfo> Instructions) const;
  // Rewrite a memory address used by Second to use address of First incremented
  // by a constant value
  bool rewriteAddressCalculation(LdStInfo &First, LdStInfo &Second, int32_t RegStride) const;
  bool runOnBasicBlock(BasicBlock &BB) const;

  const DataLayout *DL;
  const TargetLibraryInfo *TLInfo;
  PointerType *BytePtrTy;
};

} // end anonymous namespace

char ARMPostIndexingOpt::ID = 0;

INITIALIZE_PASS(ARMPostIndexingOpt, DEBUG_TYPE, PASS_DESC, false, false)

bool ARMPostIndexingOpt::runOnFunction(Function &F) {
  if (skipFunction(F))
    return false;
  // If MVE is available, skip this function.
  const auto &TPC = getAnalysis<TargetPassConfig>();
  const auto &TM = TPC.getTM<TargetMachine>();
  const auto &STI = TM.getSubtarget<ARMSubtarget>(F);
  if (STI.hasMVEIntegerOps())
    return false;

  LLVMContext &C = F.getContext();
  DL = &F.getParent()->getDataLayout();
  TLInfo = &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);
  Type *Int8Ty = IntegerType::get(C, 8);
  BytePtrTy = PointerType::get(Int8Ty, /* AddressSpace = */ 0);

  bool Modified = false;
  for (auto &BB : F)
    Modified |= runOnBasicBlock(BB);
  return Modified;
}

std::pair<Type *, unsigned> ARMPostIndexingOpt::
getDataTypeAndBaseIndex(Instruction *I) const {
  if (LoadInst *Load = dyn_cast<LoadInst>(I))
    return std::make_pair(Load->getType(), 0);
  if (StoreInst *Store = dyn_cast<StoreInst>(I))
    return std::make_pair(Store->getValueOperand()->getType(), 1);

  if (IntrinsicInst *Intrinsic = dyn_cast<IntrinsicInst>(I)) {
    switch (Intrinsic->getIntrinsicID()) {
    case Intrinsic::arm_neon_vld1:
    case Intrinsic::arm_neon_vld2:
    case Intrinsic::arm_neon_vld3:
    case Intrinsic::arm_neon_vld4:
      return std::make_pair(Intrinsic->getType(), 0);
    case Intrinsic::arm_neon_vst1:
    case Intrinsic::arm_neon_vst2:
    case Intrinsic::arm_neon_vst3:
    case Intrinsic::arm_neon_vst4:
      return std::make_pair(Intrinsic->getOperand(1)->getType(), 0);
    default:
      break;
    }
  }
  return std::make_pair(nullptr, 0);
}

LdStInfo::LdStInfo(const DataLayout &DL, Instruction *LdSt,
                   unsigned BaseOperandIndex, int AccessSize)
    : LdSt(LdSt), BaseOperandIndex(BaseOperandIndex), Offset(0),
      AccessSize(AccessSize) {
  IndirectBase = LdSt->getOperand(BaseOperandIndex);
  for (;;) {
    IndirectBase = IndirectBase->stripPointerCasts();
    // Match GetElementPtrInst as well as corresponding ContantExpr
    if (auto *GEP = dyn_cast<GEPOperator>(IndirectBase)) {
      APInt APOffset(32, 0, /* isSigned = */ true);
      if (GEP->accumulateConstantOffset(DL, APOffset)) {
        IndirectBase = GEP->getPointerOperand();
        Offset += APOffset.getSExtValue();
        continue;
      }
    }
    return;
  }
}

int32_t ARMPostIndexingOpt::guessCustomAccessStride(ArrayRef<LdStInfo> Instructions) const {
  int32_t Stride = 0; // not decided
  assert(!Instructions.empty());
  for (auto I = Instructions.begin(), End = Instructions.end(); std::next(I) != End; ++I) {
    int32_t ThisStride = std::next(I)->Offset - I->Offset;
    // Check if "[Rn]!" addressing mode can be used
    if (ThisStride == I->AccessSize)
      continue;
    // If this is the first instruction requiring a register operand,
    // request this stride value
    if (Stride == 0)
      Stride = ThisStride;
    // If multiple different stride values have to be used,
    // conservatively refrain from using "[Rn], Rm" addressing mode
    if (Stride != ThisStride)
      return 0;
  }
  return Stride;
}

bool ARMPostIndexingOpt::rewriteAddressCalculation(LdStInfo &First, LdStInfo &Second, int32_t RegStride) const {
  LLVM_DEBUG(dbgs() << "Rewriting address for post-indexing: ";
             Second.LdSt->dump());

  IRBuilder<> IRB(Second.LdSt);

  int32_t Stride = Second.Offset - First.Offset;
  if (Stride != First.AccessSize && Stride != RegStride)
    return false;

  // In case GEPOperand matched ContantExpr, replace it by instruction to
  // prevent folding
  if (auto Const = dyn_cast<ConstantExpr>(First.getBaseOperand())) {
    auto Inst = Const->getAsInstruction();
    Inst->insertBefore(First.LdSt);
    First.LdSt->replaceUsesOfWith(Const, Inst);
  }

  Value *FirstBase = First.getBaseOperand();
  Value *OldSecondBase = Second.getBaseOperand();
  PointerType *FirstBaseTy = cast<PointerType>(FirstBase->getType());
  PointerType *SecondBaseTy = cast<PointerType>(OldSecondBase->getType());
  assert(FirstBaseTy->getAddressSpace() == 0 && "Unexpected address space");
  assert(SecondBaseTy->getAddressSpace() == 0 && "Unexpected address space");

  int32_t FirstElementSize = DL->getTypeSizeInBits(FirstBaseTy->getElementType()) / 8;

  Value *NewSecondBase;
  if (FirstBaseTy == SecondBaseTy && Stride % FirstElementSize == 0) {
    int32_t ElementStride = Stride / FirstElementSize;
    NewSecondBase = IRB.CreateConstGEP1_32(FirstBase, ElementStride, "postinc");
  } else {
    Value *FirstBaseBytePtr = IRB.CreateBitCast(FirstBase, BytePtrTy, "oldbase.byteptr");
    Value *NewSecondBaseBytePtr = IRB.CreateConstGEP1_32(FirstBaseBytePtr, Stride, "postinc.byteptr");
    NewSecondBase = IRB.CreateBitCast(NewSecondBaseBytePtr, SecondBaseTy, "postinc");
  }
  Second.LdSt->replaceUsesOfWith(OldSecondBase, NewSecondBase);
  RecursivelyDeleteTriviallyDeadInstructions(OldSecondBase, TLInfo, nullptr);
  return true;
}

bool ARMPostIndexingOpt::runOnBasicBlock(BasicBlock &BB) const {
  DenseMap<Value *, SmallVector<LdStInfo, 16>> LdStMap;

  // Collect relevant load/store instructions, grouped by guessed base address
  for (auto &I : BB) {
    Type *ValueTy;
    unsigned BaseOperandIndex;
    std::tie(ValueTy, BaseOperandIndex) = getDataTypeAndBaseIndex(&I);
    if (!ValueTy || !ValueTy->isVectorTy())
      continue;

    unsigned AccessSize = DL->getTypeSizeInBits(ValueTy) / 8;
    if (isPowerOf2_32(AccessSize)) {
      LdStInfo LSI(*DL, &I, BaseOperandIndex, AccessSize);
      LdStMap[LSI.IndirectBase].push_back(std::move(LSI));
    }
  }

  // For each group, form a chain of address increments
  bool Modified = false;
  for (auto BaseAndWorklist : LdStMap) {
    auto Worklist = BaseAndWorklist.second;
    int32_t RegStride = guessCustomAccessStride(Worklist);
    assert(!Worklist.empty());
    for (auto I = Worklist.begin(), E = Worklist.end(); std::next(I) != E; ++I)
      Modified |= rewriteAddressCalculation(*I, *std::next(I), RegStride);
  }
  return Modified;
}

FunctionPass *llvm::createARMPostIndexingOptimizationPass() {
  return new ARMPostIndexingOpt();
}
