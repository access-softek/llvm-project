//===- DXILDebugInfo.cpp - analysis and lowering for Debug info -*- C++ -*- -=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "DXILDebugInfo.h"
#include "DirectX.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/Module.h"

#define DEBUG_TYPE "dxil-debug-info"

namespace llvm {
namespace DXILDebugInfo {

static void dropDebugLabels(Module &M, DebugInfoFinder &DIF) {
  for (DISubprogram *SP : DIF.subprograms()) {
    if (MDTuple *RN = cast_or_null<MDTuple>(SP->getRawRetainedNodes())) {
      SmallVector<Metadata *> MDs(RN->operands());
      MDs.erase(std::remove_if(MDs.begin(), MDs.end(),
                               [](Metadata *M) { return isa<DILabel>(M); }),
                MDs.end());
      SP->replaceRetainedNodes(MDTuple::get(M.getContext(), MDs));
    }
  }
}

static void dropCommonBlocks(Module &M, DebugInfoFinder &DIF,
                             MDMap &VEReplace) {
  for (DIScope *Scope : DIF.scopes()) {
    if (const auto *CB = dyn_cast<DICommonBlock>(Scope)) {
      VEReplace[CB] = CB->getScope();
    }
  }
}

static void collectDISubprogramFunctions(Module &M, MDMap &VEExtra) {
  for (const Function &F : M) {
    if (const DISubprogram *SP = F.getSubprogram()) {
      auto *FunctionMD = ConstantAsMetadata::get(const_cast<Function *>(&F));
      VEExtra[SP] = FunctionMD;
    }
  }
}

static void collectDICompileUnitSubprograms(
    const Module &M, const DebugInfoFinder &DIF,
    DenseMap<const DICompileUnit *, const MDTuple *> &CUSubprograms,
    MDMap &VEExtra) {

  DenseMap<const DICompileUnit *, SmallVector<Metadata *, 16>> CUSub;
  for (DISubprogram *SP : DIF.subprograms()) {
    if (const DICompileUnit *CU = SP->getUnit())
      CUSub[CU].push_back(SP);
  }

  for (auto &[CU, Subprograms] : CUSub) {
    auto *SubprogramsMD = MDTuple::get(M.getContext(), Subprograms);
    CUSubprograms[CU] = SubprogramsMD;
    VEExtra[CU] = SubprogramsMD;
  }
}

Result run(Module &M) {
  Result Res;
  DebugInfoFinder DIF;
  DIF.processModule(M);

  dropDebugLabels(M, DIF);
  dropCommonBlocks(M, DIF, Res.VEReplace);
  collectDISubprogramFunctions(M, Res.VEExtra);
  collectDICompileUnitSubprograms(M, DIF, Res.CUSubprograms, Res.VEExtra);

  return Res;
}

} // namespace DXILDebugInfo
} // namespace llvm
