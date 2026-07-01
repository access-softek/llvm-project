//===----------------- DXBCTypes.td - DXBC dialect types ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCTYPES
#define MLIR_DIALECT_DXBC_IR_DXBCTYPES

include "mlir/IR/AttrTypeBase.td"
include "mlir/Dialect/DXBC/IR/DXBCDialect.td"

//===----------------------------------------------------------------------===//
// DXBC Types
//===----------------------------------------------------------------------===//

class DXBC_Type<string name, string typeMnemonic> : TypeDef<DXBCDialect,
                                                            name> {
  let mnemonic = typeMnemonic;
}

def DXBC_IndexType : DXBC_Type<"Index", "index"> {
  let summary = "dxbc index type";
  let description = [{
    TODO
  }];
}

def DXBC_OperandType : DXBC_Type<"Operand", "operand"> {
  let summary = "dxbc operand type";
  let description = [{
    TODO
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCTYPES
