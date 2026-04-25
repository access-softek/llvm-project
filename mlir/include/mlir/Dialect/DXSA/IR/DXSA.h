//===------------------- DXSA.h - MLIR DXSA dialect -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSA_H
#define MLIR_DIALECT_DXSA_IR_DXSA_H

#include "mlir/Bytecode/BytecodeOpInterface.h"
#include "mlir/Dialect/DXSA/IR/DXSATypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpImplementation.h"

//===----------------------------------------------------------------------===//
// DXSA Dialect
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DXSA/IR/DXSAOpsDialect.h.inc"

//===----------------------------------------------------------------------===//
// DXSA Dialect Enum Attributes
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DXSA/IR/DXSAOpsEnums.h.inc"
#define GET_ATTRDEF_CLASSES
#include "mlir/Dialect/DXSA/IR/DXSAOpsAttributes.h.inc"

//===----------------------------------------------------------------------===//
// DXSA Dialect Operations
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "mlir/Dialect/DXSA/IR/DXSAOps.h.inc"

#endif // MLIR_DIALECT_DXSA_IR_DXSA_H
