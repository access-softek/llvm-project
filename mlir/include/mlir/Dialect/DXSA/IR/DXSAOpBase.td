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
// DXSA shared base for ops with inline operands
//===----------------------------------------------------------------------===//

class DXSA_PlainOp<string mnemonic, int dsts, int srcs> : DXSA_Op<mnemonic> {
  defvar args = !foldl(!dag(ins, !listsplat(0, !add(dsts, srcs, 1)), ?),
      !range(!add(dsts, srcs, 1)),
      acc, n,
      !cond(!lt(n, dsts):
              !setdagname(!setdagarg(acc, n, DXSA_DstOperandAttr), n, !cond(!eq(dsts, 1): "dst", true: !strconcat("dst", !cast<string>(n)))),
            !lt(n, !add(dsts, srcs)):
              !setdagname(!setdagarg(acc, n, DXSA_SrcOperandAttr), n, !cond(!eq(srcs, 1): "src",
                                                                            !and(!eq(srcs, 2), !eq(n, dsts)): "lhs",
                                                                            !eq(srcs, 2): "rhs",
                                                                            true: !strconcat("src", !cast<string>(!sub(n, dsts))))),
            true:
              !setdagname(!setdagarg(acc, n, OptionalAttr<DXSA_ComponentMaskAttr>), n, "precise")));
  let arguments = args;
  let results = (outs);
  let assemblyFormat =
      !strconcat(!foldl("(`precise` $precise^)?", !range(!add(dsts, srcs)), acc, n, !strconcat(acc, !cond(!eq(n, 0): " $", true: " `,` $"), !getdagname(args, n))), " attr-dict");
}

class DXSA_UnaryOp<string mnemonic> : DXSA_PlainOp<mnemonic, 1, 1>;
class DXSA_BinaryOp<string mnemonic> : DXSA_PlainOp<mnemonic, 1, 2>;
class DXSA_TernaryOp<string mnemonic> : DXSA_PlainOp<mnemonic, 1, 3>;

#endif // MLIR_DIALECT_DXSA_IR_DXSAOPBASE
