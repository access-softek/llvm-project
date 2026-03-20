//===- DXILDebugInfo.h - analysis and lowering for Debug info -*- C++ -*- -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// \file Analyze and downgrade debug info metadata to match DXIL (LLVM 3.7).
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_DIRECTX_DXILDEBUGINFO_H
#define LLVM_LIB_TARGET_DIRECTX_DXILDEBUGINFO_H

#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"

namespace llvm {

struct ValueEnumeratorOverride {};

struct DXILDebugInfoResult {
  int Val;
  ValueEnumeratorOverride VEOverride;
};

class DXILDebugInfo : public AnalysisInfoMixin<DXILDebugInfo> {
  friend AnalysisInfoMixin<DXILDebugInfo>;
  static AnalysisKey Key;

public:
  using Result = DXILDebugInfoResult;
  Result run(Module &M, ModuleAnalysisManager &MAM);
};

class DXILDebugInfoLegacy : public ModulePass {
public:
  const DXILDebugInfoResult &getResult() { return Result; }
  bool runOnModule(Module &M) override;

  StringRef getPassName() const override { return "DXIL Debug Info"; }
  DXILDebugInfoLegacy() : ModulePass(ID) {}

  static char ID; // Pass identification.
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

private:
  DXILDebugInfoResult Result;
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_DIRECTX_DXILDEBUGINFO_H
