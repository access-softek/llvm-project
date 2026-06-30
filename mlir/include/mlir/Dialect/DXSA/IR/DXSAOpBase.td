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
// DXSA shared base for ops with all operands specified inline
//===----------------------------------------------------------------------===//

class DXSA_BaseOp<string mnemonic> : DXSA_Op<mnemonic> {
  dag dsts;
  dag srcs;
  string asmFormat;
  let dsts = (ins DXSA_DstOperandAttr:$dst);

  let arguments = !con(dsts, srcs, (ins OptionalAttr<DXSA_ComponentMaskAttr>:$precise));
  let results = (outs);
  let assemblyFormat = !strconcat("(`precise` $precise^)? ", asmFormat, " attr-dict");
}

class DXSA_NullaryOp<string mnemonic> : DXSA_BaseOp<mnemonic> {
  let srcs = (ins);
  let asmFormat = "$dst";
}

class DXSA_UnaryOp<string mnemonic> : DXSA_BaseOp<mnemonic> {
  let srcs = (ins DXSA_SrcOperandAttr:$src);
  let asmFormat = "$dst `,` $src";
}

class DXSA_BinaryOp<string mnemonic> : DXSA_BaseOp<mnemonic> {
  let srcs = (ins DXSA_SrcOperandAttr:$lhs, DXSA_SrcOperandAttr:$rhs);
  let asmFormat = "$dst `,` $lhs `,` $rhs";
}

class DXSA_TernaryOp<string mnemonic> : DXSA_BaseOp<mnemonic> {
  let srcs = (ins DXSA_SrcOperandAttr:$src0, DXSA_SrcOperandAttr:$src1, DXSA_SrcOperandAttr:$src2);
  let asmFormat = "$dst `,` $src0 `,` $src1 `,` $src2";
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAOPBASE
