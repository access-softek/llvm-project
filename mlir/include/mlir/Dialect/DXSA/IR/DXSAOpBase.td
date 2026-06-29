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

class DXSA_BaseOp<string mnemonic, list<string> dstnames, list<string> srcnames> : DXSA_Op<mnemonic> {
  let arguments = !setdagarg(!dag(ins,
    !listconcat(!listsplat(DXSA_DstOperandAttr, !size(dstnames)),
                !listsplat(DXSA_SrcOperandAttr, !add(!size(srcnames), 1))),
    !listconcat(dstnames, srcnames, ["precise"])),
    !add(!size(dstnames), !size(srcnames)), OptionalAttr<DXSA_ComponentMaskAttr>);
  let results = (outs);
  let assemblyFormat = !interleave(!listconcat(
      ["(`precise` $precise^)?"],
      !tail(!cond(
          !and(!empty(dstnames), !empty(srcnames)): [""],
          true: !listflatten(!foreach(name, !listconcat(dstnames, srcnames), ["`,`", !strconcat("$", name)])))),
      ["attr-dict"]), " ");
}

class DXSA_NullaryOp <string mnemonic, list<string> dstnames = ["dst"]> : DXSA_BaseOp<mnemonic, dstnames, []>;
class DXSA_UnaryOp   <string mnemonic, list<string> dstnames = ["dst"]> : DXSA_BaseOp<mnemonic, dstnames, ["src"]>;
class DXSA_BinaryOp  <string mnemonic, list<string> dstnames = ["dst"]> : DXSA_BaseOp<mnemonic, dstnames, ["lhs", "rhs"]>;
class DXSA_TernaryOp <string mnemonic, list<string> dstnames = ["dst"]> : DXSA_BaseOp<mnemonic, dstnames, ["src0", "src1", "src2"]>;

#endif // MLIR_DIALECT_DXSA_IR_DXSAOPBASE
