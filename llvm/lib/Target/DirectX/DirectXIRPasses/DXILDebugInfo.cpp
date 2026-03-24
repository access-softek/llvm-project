//===- DXILDebugInfo.cpp - analysis and lowering for Debug info -*- C++ -*- -=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "DXILDebugInfo.h"
#include "DirectX.h"
#include "llvm/IR/Module.h"

#define DEBUG_TYPE "dxil-debug-info"

namespace llvm {
namespace DXILDebugInfo {

Result run(Module &M) { return {42}; }

} // namespace DXILDebugInfo
} // namespace llvm
