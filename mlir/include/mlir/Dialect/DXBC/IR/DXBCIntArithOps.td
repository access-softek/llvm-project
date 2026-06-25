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

#endif // MLIR_DIALECT_DXBC_IR_DXBCINTARITHOPS
