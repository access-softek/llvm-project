//===---------------- DXBCTypes.h - DXBC Dialect Types ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCTYPES_H_
#define MLIR_DIALECT_DXBC_IR_DXBCTYPES_H_

#include "mlir/IR/Types.h"

//===----------------------------------------------------------------------===//
// DXBC Dialect Types
//===----------------------------------------------------------------------===//

#define GET_TYPEDEF_CLASSES
#include "mlir/Dialect/DXBC/IR/DXBCOpsTypes.h.inc"

#endif // MLIR_DIALECT_DXBC_IR_DXBCTYPES_H_
