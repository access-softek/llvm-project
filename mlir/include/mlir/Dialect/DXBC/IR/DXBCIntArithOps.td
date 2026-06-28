//===- DXBCIntArithOps.td - DXBC integer arithmetic ops -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Integer arithmetic instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCINTARITHOPS
#define MLIR_DIALECT_DXBC_IR_DXBCINTARITHOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.iadd
//===----------------------------------------------------------------------===//

def DXBC_IAdd : DXBC_BinaryOp<"iadd"> {
  let summary = "component-wise integer add";
  let description = [{
    The `dxbc.iadd` operation computes the component-wise sum of two 32-bit
    integers, `$dst = $lhs + $rhs`. No carry or borrow beyond the 32-bit
    value of each component is performed, so the result is not sensitive to
    the signedness of its operands.

    Example:

    ```mlir
    dxbc.iadd r<0>, r<1>, r<2>
    dxbc.iadd r<0>, -r<1>, -r<2>
    dxbc.iadd r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imax
//===----------------------------------------------------------------------===//

def DXBC_IMax : DXBC_BinaryOp<"imax"> {
  let summary = "component-wise signed integer maximum";
  let description = [{
    The `dxbc.imax` operation computes the component-wise maximum of two
    32-bit signed integers, `$dst = $lhs > $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxbc.imax r<0>, r<1>, r<2>
    dxbc.imax r<0>, -r<1>, -r<2>
    dxbc.imax r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imin
//===----------------------------------------------------------------------===//

def DXBC_IMin : DXBC_BinaryOp<"imin"> {
  let summary = "component-wise signed integer minimum";
  let description = [{
    The `dxbc.imin` operation computes the component-wise minimum of two
    32-bit signed integers, `$dst = $lhs < $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxbc.imin r<0>, r<1>, r<2>
    dxbc.imin r<0>, -r<1>, -r<2>
    dxbc.imin r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ineg
//===----------------------------------------------------------------------===//

def DXBC_INeg : DXBC_UnaryOp<"ineg"> {
  let summary = "component-wise integer two's complement";
  let description = [{
    The `dxbc.ineg` operation computes the component-wise two's complement of
    each 32-bit integer in `$src`, `$dst = -$src`.

    Example:

    ```mlir
    dxbc.ineg r<0>, r<1>
    dxbc.ineg r<0, <x>>, r<1, <y, z, w, y>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.umax
//===----------------------------------------------------------------------===//

def DXBC_UMax : DXBC_BinaryOp<"umax"> {
  let summary = "component-wise unsigned integer maximum";
  let description = [{
    The `dxbc.umax` operation computes the component-wise maximum of two
    32-bit unsigned integers, `$dst = $lhs > $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxbc.umax r<0>, r<1>, r<2>
    dxbc.umax r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.umin
//===----------------------------------------------------------------------===//

def DXBC_UMin : DXBC_BinaryOp<"umin"> {
  let summary = "component-wise unsigned integer minimum";
  let description = [{
    The `dxbc.umin` operation computes the component-wise minimum of two
    32-bit unsigned integers, `$dst = $lhs < $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxbc.umin r<0>, r<1>, r<2>
    dxbc.umin r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imad
//===----------------------------------------------------------------------===//

def DXBC_Imad : DXBC_MultiplyAddOp<"imad"> {
  let summary = "component-wise integer multiply-add";
  let description = [{
    The `dxbc.imad` operation computes the component-wise integer
    multiply-add `$dst = $lhs * $rhs + $acc`. No carry or borrow beyond the
    32-bit value of each component is performed, so the result is not
    sensitive to the signedness of its operands.

    Example:

    ```mlir
    dxbc.imad r<0>, r<1>, r<2>, r<3>
    dxbc.imad r<0>, -r<1>, r<2>, r<3>
    dxbc.imad r<0, <x>>, r<1, <y>>, r<2, <x>>, r<3, <z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imul
//===----------------------------------------------------------------------===//

def DXBC_Imul : DXBC_Op<"imul"> {
  let summary = "component-wise integer multiply";
  let description = [{
    The `dxbc.imul` operation computes the component-wise product
    `$lhs * $rhs` as a 64-bit integer and writes the high 32 bits to
    `$dstHi` and the low 32 bits to `$dstLo`. Either destination may be
    `null` when that half of the result is not needed.

    Example:

    ```mlir
    dxbc.imul r<0>, r<1>, r<2>, r<3>
    dxbc.imul null, r<0, <z>>, r<0, <y>>, -r<0, <x>>
    dxbc.imul r<7, <x, y, z>>, r<3, <x, y, z>>, r<3, <x, y, z, x>>, r<4, <x, y, z, x>>
    ```
  }];
  let arguments = (ins
      DXBC_DstOperandAttr:$dstHi,
      DXBC_DstOperandAttr:$dstLo,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dstHi `,` $dstLo `,` $lhs `,` $rhs attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.msad
//===----------------------------------------------------------------------===//

def DXBC_Msad : DXBC_TernaryOp<"msad"> {
  let summary = "component-wise masked sum of absolute differences";
  let description = [{
    The `dxbc.msad` operation computes the component-wise masked sum of
    absolute differences. For each 32-bit component, `$src0` and `$src1`
    each hold four packed 8-bit unsigned integers, and `$src2` supplies a
    32-bit unsigned accumulation value. The result is written to `$dst`.

    Example:

    ```mlir
    dxbc.msad r<0>, r<0>, r<1>, r<2>
    dxbc.msad r<1, <x>>, r<1, <x>>, r<1, <y>>, r<1, <z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.udiv
//===----------------------------------------------------------------------===//

def DXBC_UDiv : DXBC_Op<"udiv"> {
  let summary = "component-wise unsigned integer divide";
  let description = [{
    The `dxbc.udiv` operation computes the component-wise unsigned integer
    quotient `$dst_quotient = $lhs / $rhs` and remainder
    `$dst_remainder = $lhs % $rhs` of two 32-bit unsigned integers. Division
    by zero produces `0xffffffff` for both quotient and remainder. Either
    destination may be `null` when that result is not needed.

    Example:

    ```mlir
    dxbc.udiv r<0>, r<1>, r<2>, r<3>
    dxbc.udiv null, r<1>, r<2>, r<3>
    dxbc.udiv r<0>, null, r<2>, r<3>
    ```
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst_quotient,
      DXBC_DstOperandAttr:$dst_remainder,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst_quotient `,` $dst_remainder `,` $lhs `,` $rhs attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.umul
//===----------------------------------------------------------------------===//

def DXBC_UMul : DXBC_Op<"umul"> {
  let summary = "component-wise unsigned integer multiply";
  let description = [{
    The `dxbc.umul` operation computes the component-wise unsigned product
    `$lhs * $rhs` as a 64-bit integer and writes the high 32 bits to
    `$dst_hi` and the low 32 bits to `$dst_lo`. Either destination may be
    `null` when that half of the result is not needed.

    Example:

    ```mlir
    dxbc.umul r<0>, r<1>, r<2>, r<3>
    dxbc.umul null, r<1>, r<2>, r<3>
    dxbc.umul r<0>, null, r<2>, r<3>
    ```
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst_hi,
      DXBC_DstOperandAttr:$dst_lo,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst_hi `,` $dst_lo `,` $lhs `,` $rhs attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.umad
//===----------------------------------------------------------------------===//

def DXBC_UMad : DXBC_MultiplyAddOp<"umad"> {
  let summary = "component-wise unsigned integer multiply-add";
  let description = [{
    The `dxbc.umad` operation computes the component-wise unsigned integer
    multiply-add `$dst = $lhs * $rhs + $acc`, keeping only the low 32 bits
    of the multiply before adding `$acc`.

    Example:

    ```mlir
    dxbc.umad r<0>, r<1>, r<2>, r<3>
    dxbc.umad r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>, r<3>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.uaddc
//===----------------------------------------------------------------------===//

def DXBC_UAddc : DXBC_Op<"uaddc"> {
  let summary = "component-wise unsigned integer add with carry";
  let description = [{
    The `dxbc.uaddc` operation computes the component-wise unsigned integer
    sum `$dst = $lhs + $rhs` of two 32-bit operands and writes the carry
    (1 if the addition overflowed, 0 otherwise) to `$dst_carry`. The
    `$dst_carry` destination may be `null` when the carry is not needed.

    Example:

    ```mlir
    dxbc.uaddc r<0>, r<1>, r<2>, r<3>
    dxbc.uaddc r<0>, null, r<2>, r<3>
    ```
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_DstOperandAttr:$dst_carry,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $dst_carry `,` $lhs `,` $rhs attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.usubb
//===----------------------------------------------------------------------===//

def DXBC_USubb : DXBC_Op<"usubb"> {
  let summary = "component-wise unsigned integer subtract with borrow";
  let description = [{
    The `dxbc.usubb` operation computes the component-wise unsigned integer
    difference `$dst = $lhs - $rhs` of two 32-bit operands and writes the
    borrow (1 if the subtraction underflowed, 0 otherwise) to `$dst_borrow`.
    The `$dst_borrow` destination may be `null` when the borrow is not needed.

    Example:

    ```mlir
    dxbc.usubb r<0>, r<1>, r<2>, r<3>
    dxbc.usubb r<0>, null, r<2>, r<3>
    ```
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_DstOperandAttr:$dst_borrow,
      DXBC_SrcOperandAttr:$lhs,
      DXBC_SrcOperandAttr:$rhs,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $dst_borrow `,` $lhs `,` $rhs attr-dict";
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCINTARITHOPS
