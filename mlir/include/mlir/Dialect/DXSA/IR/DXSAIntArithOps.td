//===- DXSAIntArithOps.td - DXSA integer arithmetic ops -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Integer arithmetic instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSAINTARITHOPS
#define MLIR_DIALECT_DXSA_IR_DXSAINTARITHOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.iadd
//===----------------------------------------------------------------------===//

def DXSA_IAdd : DXSA_BinaryOp<"iadd"> {
  let summary = "component-wise integer add";
  let description = [{
    The `dxsa.iadd` operation computes the component-wise sum of two 32-bit
    integers, `$dst = $lhs + $rhs`. No carry or borrow beyond the 32-bit
    value of each component is performed, so the result is not sensitive to
    the signedness of its operands.

    Example:

    ```mlir
    dxsa.iadd r<0>, r<1>, r<2>
    dxsa.iadd r<0>, -r<1>, -r<2>
    dxsa.iadd r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.imax
//===----------------------------------------------------------------------===//

def DXSA_IMax : DXSA_BinaryOp<"imax"> {
  let summary = "component-wise signed integer maximum";
  let description = [{
    The `dxsa.imax` operation computes the component-wise maximum of two
    32-bit signed integers, `$dst = $lhs > $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxsa.imax r<0>, r<1>, r<2>
    dxsa.imax r<0>, -r<1>, -r<2>
    dxsa.imax r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.imin
//===----------------------------------------------------------------------===//

def DXSA_IMin : DXSA_BinaryOp<"imin"> {
  let summary = "component-wise signed integer minimum";
  let description = [{
    The `dxsa.imin` operation computes the component-wise minimum of two
    32-bit signed integers, `$dst = $lhs < $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxsa.imin r<0>, r<1>, r<2>
    dxsa.imin r<0>, -r<1>, -r<2>
    dxsa.imin r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.ineg
//===----------------------------------------------------------------------===//

def DXSA_INeg : DXSA_UnaryOp<"ineg"> {
  let summary = "component-wise integer two's complement";
  let description = [{
    The `dxsa.ineg` operation computes the component-wise two's complement of
    each 32-bit integer in `$src`, `$dst = -$src`.

    Example:

    ```mlir
    dxsa.ineg r<0>, r<1>
    dxsa.ineg r<0, <x>>, r<1, <y, z, w, y>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.umax
//===----------------------------------------------------------------------===//

def DXSA_UMax : DXSA_BinaryOp<"umax"> {
  let summary = "component-wise unsigned integer maximum";
  let description = [{
    The `dxsa.umax` operation computes the component-wise maximum of two
    32-bit unsigned integers, `$dst = $lhs > $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxsa.umax r<0>, r<1>, r<2>
    dxsa.umax r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.umin
//===----------------------------------------------------------------------===//

def DXSA_UMin : DXSA_BinaryOp<"umin"> {
  let summary = "component-wise unsigned integer minimum";
  let description = [{
    The `dxsa.umin` operation computes the component-wise minimum of two
    32-bit unsigned integers, `$dst = $lhs < $rhs ? $lhs : $rhs`.

    Example:

    ```mlir
    dxsa.umin r<0>, r<1>, r<2>
    dxsa.umin r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAINTARITHOPS
