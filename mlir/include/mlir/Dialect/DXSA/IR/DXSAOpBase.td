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

class DXSA_PlainOp<string mnemonic, int dsts, int srcs, bit hasprecise = 1> : DXSA_Op<mnemonic> {
  defvar dstnames = !cond(!eq(dsts, 1): ["dst"],
                          true: !foreach(n, !range(dsts), !strconcat("dst", !cast<string>(n))));
  defvar srcnames = !cond(!eq(srcs, 1): ["src"],
                          !eq(srcs, 2): ["lhs", "rhs"],
                          true: !foreach(n, !range(srcs), !strconcat("src", !cast<string>(n))));
  defvar precisename = !listsplat("precise", !cast<int>(hasprecise));
  defvar argnames = !listconcat(dstnames, srcnames, precisename);

  defvar args = !foldl(!dag(ins, ?, argnames),
      !range(!add(dsts, srcs, hasprecise)),
      acc, n,
      !cond(!lt(n, dsts): !setdagarg(acc, n, DXSA_DstOperandAttr),
            !lt(n, !add(dsts, srcs)): !setdagarg(acc, n, DXSA_SrcOperandAttr),
            true: !setdagarg(acc, n, OptionalAttr<DXSA_ComponentMaskAttr>)));
  let arguments = args;
  let results = (outs);
  let assemblyFormat = !interleave(!listconcat(
      !cond(hasprecise: ["(`precise` $precise^)?"], true: []<string>),
      !tail(!cond(!eq(!add(dsts, srcs), 0): [""], true: !listflatten(!foreach(n, !listconcat(dstnames, srcnames), ["`,`", !strconcat("$", n)])))),
      ["attr-dict"]), " ");
}

class DXSA_UnaryOp<string mnemonic> : DXSA_PlainOp<mnemonic, 1, 1>;
class DXSA_BinaryOp<string mnemonic> : DXSA_PlainOp<mnemonic, 1, 2>;
class DXSA_TernaryOp<string mnemonic> : DXSA_PlainOp<mnemonic, 1, 3>;

#endif // MLIR_DIALECT_DXSA_IR_DXSAOPBASE
