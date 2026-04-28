//===-------- BinaryParser.h - Parse DXSA binary to MLIR  ---*- C++ -*-----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_TARGET_DXSA_BINARYPARSER_H
#define MLIR_TARGET_DXSA_BINARYPARSER_H

#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/OwningOpRef.h"
#include "llvm/Support/SourceMgr.h"

namespace mlir::dxsa {

/// Decode DXSA binary \p source and return an MLIR module.
OwningOpRef<ModuleOp> importDxsaBinaryToModule(llvm::SourceMgr &source,
                                               MLIRContext *context);
/// Encode \p source to DXSA binary.
LogicalResult exportModuleToDxsaBinary(ModuleOp source, raw_ostream &output);

/// Print \p source to DXSA text assembly.
LogicalResult exportModuleToDxsa(ModuleOp source, raw_ostream &output);

} // namespace mlir::dxsa

#endif // MLIR_TARGET_DXSA_BINARYPARSER_H
