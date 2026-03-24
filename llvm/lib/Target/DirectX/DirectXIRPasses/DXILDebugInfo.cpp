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

Result run(Module &M) {
  DebugInfoFinder DIF;
  DIF.processModule(M);

  dropDebugLabels(M, DIF);

  return {42};
}

} // namespace DXILDebugInfo
} // namespace llvm
