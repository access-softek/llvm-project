//===- DXBCOps.td - DXBC operations definition -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef DXBC_OPS
#define DXBC_OPS

include "mlir/Dialect/DXBC/IR/DXBCDialect.td"
include "mlir/Dialect/DXBC/IR/DXBCTypes.td"

//===----------------------------------------------------------------------===//
// DXBC op definitions
//===----------------------------------------------------------------------===//

// Base class for the operation in this dialect
class DXBC_Op<string mnemonic, list<Trait> traits = []> :
    Op<DXBCDialect, mnemonic, traits>;

def DXBC_Operand : DXBC_Op<"operand"> {
  let summary = "defines an operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXBC_IndexType>:$operands,
                       I32Attr:$type,
                       I32Attr:$num_components,
		       OptionalAttr<I32Attr>:$one,
		       OptionalAttr<I32Attr>:$mask,
		       OptionalAttr<I32ElementsAttr>:$swizzle,
		       OptionalAttr<I32Attr>:$modifier,
		       OptionalAttr<I32Attr>:$min_precision,
		       OptionalAttr<I32Attr>:$non_uniform);
  let results = (outs DXBC_OperandType:$operand);
  let assemblyFormat = "$operands attr-dict";
}

def DXBC_OperandImm : DXBC_Op<"operand.imm"> {
  let summary = "defines an immediate operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32ElementsAttr, I64ElementsAttr]>:$imm);
  let results = (outs DXBC_OperandType:$operand);
  let assemblyFormat = "attr-dict";
}

def DXBC_IndexImm : DXBC_Op<"index.imm"> {
  let summary = "defines an immediate index";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32Attr, I64Attr]>:$imm);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "attr-dict";
}

def DXBC_IndexRel : DXBC_Op<"index.rel"> {
  let summary = "defines an operand index";
  let description = [{
    TODO
  }];

  let arguments = (ins DXBC_OperandType:$operand);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_IndexRelImm : DXBC_Op<"index.rel.imm"> {
  let summary = "defines an operand index with an immediate attribute";
  let description = [{
    TODO
  }];

  let arguments = (ins DXBC_OperandType:$operand, StrAttr:$op, I64Attr:$imm);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_Instruction : DXBC_Op<"instruction"> {
  let summary = "defines an instruction with zero or more operands";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXBC_OperandType>:$operands, StrAttr:$mnemonic);
  let results = (outs);
  let assemblyFormat = "$mnemonic $operands attr-dict";
}

#endif // DXBC_OPS
