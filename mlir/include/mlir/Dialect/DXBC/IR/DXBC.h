//===------------------- DXBC.h - MLIR DXBC dialect -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBC_H
#define MLIR_DIALECT_DXBC_IR_DXBC_H

#include "mlir/Bytecode/BytecodeOpInterface.h"
#include "mlir/Dialect/DXBC/IR/DXBCTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpImplementation.h"

//===----------------------------------------------------------------------===//
// DXBC Dialect
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DXBC/IR/DXBCOpsDialect.h.inc"

//===----------------------------------------------------------------------===//
// DXBC Dialect Operations
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "mlir/Dialect/DXBC/IR/DXBCOps.h.inc"

#endif // MLIR_DIALECT_DXBC_IR_DXBC_H
