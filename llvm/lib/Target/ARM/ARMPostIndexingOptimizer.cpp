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

  bool canUsePostIncrementedAddressFrom(const LdStInfo &Predecessor) const;
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
  // Rewrite a memory address used by Second to use address of First incremented
  // by access size of First
  bool rewriteAddressCalculation(LdStInfo &First, LdStInfo &Second) const;
  bool runOnBasicBlock(BasicBlock &BB) const;

  const DataLayout *DL;
  const TargetLibraryInfo *TLInfo;
};

} // end anonymous namespace

char ARMPostIndexingOpt::ID = 0;

INITIALIZE_PASS(ARMPostIndexingOpt, DEBUG_TYPE, PASS_DESC, false, false)

bool ARMPostIndexingOpt::runOnFunction(Function &F) {
  // If MVE is available, skip this function.
  const auto &TPC = getAnalysis<TargetPassConfig>();
  const auto &TM = TPC.getTM<TargetMachine>();
  const auto &STI = TM.getSubtarget<ARMSubtarget>(F);
  if (STI.hasMVEIntegerOps())
    return false;

  DL = &F.getParent()->getDataLayout();
  TLInfo = &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI(F);

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

bool LdStInfo::canUsePostIncrementedAddressFrom(const LdStInfo &Predecessor) const {
  return IndirectBase == Predecessor.IndirectBase &&
      Offset == Predecessor.Offset + Predecessor.AccessSize;
}

bool ARMPostIndexingOpt::rewriteAddressCalculation(LdStInfo &First, LdStInfo &Second) const {
  LLVM_DEBUG(dbgs() << "Rewriting address for post-indexing: ";
             Second.LdSt->dump());

  IRBuilder<> IRB(Second.LdSt);
  PointerType *PtrTy = cast<PointerType>(Second.getBaseOperand()->getType());
  unsigned ElementSize = DL->getTypeSizeInBits(PtrTy->getElementType()) / 8;
  if (First.AccessSize % ElementSize != 0)
    return false; // Not yet handled
  unsigned ElementOffset = First.AccessSize / ElementSize;

  // In case GEPOperand matched ContantExpr, replace it by instruction to
  // prevent folding
  if (auto Const = dyn_cast<ConstantExpr>(First.getBaseOperand())) {
    auto Inst = Const->getAsInstruction();
    Inst->insertBefore(First.LdSt);
    First.LdSt->replaceUsesOfWith(Const, Inst);
  }

  Value *BaseCasted = IRB.CreatePointerCast(First.getBaseOperand(), PtrTy);
  Value *OldBaseExact = Second.getBaseOperand();
  Value *NewBaseExact = IRB.CreateConstGEP1_32(BaseCasted, ElementOffset,
                                               "postinc");
  Second.LdSt->replaceUsesOfWith(OldBaseExact, NewBaseExact);
  RecursivelyDeleteTriviallyDeadInstructions(OldBaseExact, TLInfo, nullptr);
  return true;
}

bool ARMPostIndexingOpt::runOnBasicBlock(BasicBlock &BB) const {
  SmallVector<LdStInfo, 16> Worklist;
  for (auto &I : BB) {
    Type *ValueTy;
    unsigned BaseOperandIndex;
    std::tie(ValueTy, BaseOperandIndex) = getDataTypeAndBaseIndex(&I);
    if (!ValueTy || !ValueTy->isVectorTy())
      continue;

    unsigned AccessSize = DL->getTypeSizeInBits(ValueTy) / 8;
    if (isPowerOf2_32(AccessSize))
      Worklist.emplace_back(*DL, &I, BaseOperandIndex, AccessSize);
  }

  bool Modified = false;
  for (auto I = Worklist.begin(), E = Worklist.end(); I != E; ++I) {
    // Find some other instruction that is after the current one and can use
    // post-incremented address value.
    auto Next = std::find_if(I, E, [I](LdStInfo Successor) {
      return Successor.canUsePostIncrementedAddressFrom(*I);
    });
    if (Next != E)
      Modified |= rewriteAddressCalculation(*I, *Next);
  }
  return Modified;
}

FunctionPass *llvm::createARMPostIndexingOptimizationPass() {
  return new ARMPostIndexingOpt();
}
