//===-------- BinaryParser.h - Parse DXSA binary to MLIR  ---*- C++ -*-----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_TARGET_DXSA_BINARYPARSER_H
#define MLIR_TARGET_DXSA_BINARYPARSER_H

#include "mlir/Dialect/DXSA/IR/DXSA.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/OwningOpRef.h"
#include "llvm/Support/SourceMgr.h"

namespace mlir::dxsa {
/// Deserializes the given binary \p source and creates a MLIR ModuleOp in the
/// given \p context.
OwningOpRef<dxsa::ModuleOp> deserialize(llvm::SourceMgr &source,
                                        MLIRContext *context);

/// Deserializes a textual listing of little-endian hex DWORDs,
/// separated by whitespace or comma.
/// This method is used in tests to store hexadeciman tokens representation
/// right inside the text body.
OwningOpRef<dxsa::ModuleOp> deserializeHex(llvm::SourceMgr &source,
                                           MLIRContext *context);

/// Serializes the given MLIR \p moduleOp and writes to \p output.
LogicalResult serialize(mlir::ModuleOp moduleOp, raw_ostream &output);
} // namespace mlir::dxsa

#endif // MLIR_TARGET_DXSA_BINARYPARSER_H
