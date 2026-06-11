//===- DXSAOpBase.td - DXSA op base classes --------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Base classes shared by the DXSA operation families.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSAOPBASE
#define MLIR_DIALECT_DXSA_IR_DXSAOPBASE

include "mlir/Dialect/DXSA/IR/DXSADialect.td"
include "mlir/Dialect/DXSA/IR/DXSAOperand.td"

//===----------------------------------------------------------------------===//
// DXSA op base class
//===----------------------------------------------------------------------===//

// Base class for all operations in this dialect.
class DXSA_Op<string mnemonic, list<Trait> traits = []> :
    Op<DXSADialect, mnemonic, traits>;

//===----------------------------------------------------------------------===//
// DXSA shared bases for ops with inline operands
//===----------------------------------------------------------------------===//

class DXSA_BinaryOp<string mnemonic> : DXSA_Op<mnemonic> {
  let arguments = (ins
      DXSA_DstOperandAttr:$dst,
      DXSA_SrcOperandAttr:$lhs,
      DXSA_SrcOperandAttr:$rhs,
      OptionalAttr<DXSA_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $lhs `,` $rhs attr-dict";
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAOPBASE
