//===- DXBCOpBase.td - DXBC op base classes --------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Base classes shared by the DXBC operation families.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCOPBASE
#define MLIR_DIALECT_DXBC_IR_DXBCOPBASE

include "mlir/Dialect/DXBC/IR/DXBCDialect.td"
include "mlir/Dialect/DXBC/IR/DXBCOperand.td"

//===----------------------------------------------------------------------===//
// DXBC op base class
//===----------------------------------------------------------------------===//

// Base class for all operations in this dialect.
class DXBC_Op<string mnemonic, list<Trait> traits = []> :
    Op<DXBCDialect, mnemonic, traits>;

//===----------------------------------------------------------------------===//
// DXBC shared bases for ops with inline operands
//===----------------------------------------------------------------------===//

class DXBC_UnaryOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $src attr-dict";
}

class DXBC_BinaryOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $lhs `,` $rhs attr-dict";
}

class DXBC_TernaryOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src0,
      DXBC_SrcOperandAttr:$src1,
      DXBC_SrcOperandAttr:$src2,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $src0 `,` $src1 `,` $src2 attr-dict";
}

// Shared base for the multiply-add family: `$dst = $lhs * $rhs + $acc`.
class DXBC_MultiplyAddOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      DXBC_SrcOperandAttr:$acc,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $lhs `,` $rhs `,` $acc attr-dict";
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCOPBASE
