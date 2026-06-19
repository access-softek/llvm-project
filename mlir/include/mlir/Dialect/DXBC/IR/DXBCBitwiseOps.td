//===- DXBCBitwiseOps.td - DXBC bitwise ops -------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Bitwise instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS
#define MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.and
//===----------------------------------------------------------------------===//

def DXBC_And : DXBC_BinaryOp<"and"> {
  let summary = "component-wise logical AND";
  let description = [{
    The `dxbc.and` operation computes the component-wise logical AND of
    each pair of 32-bit values, `$dst = $lhs & $rhs`.

    Example:

    ```mlir
    dxbc.and r<0>, r<1>, r<2>
    dxbc.and r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ishl
//===----------------------------------------------------------------------===//

def DXBC_IShl : DXBC_BinaryOp<"ishl"> {
  let summary = "component-wise shift left";
  let description = [{
    The `dxbc.ishl` operation computes the component-wise shift of
    each 32-bit value in $lhs left by $rhs, `$dst = $lhs << $rhs`.

    Example:

    ```mlir
    dxbc.ishl r<0>, r<1>, r<2>
    dxbc.ishl r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ishr
//===----------------------------------------------------------------------===//

def DXBC_IShr : DXBC_BinaryOp<"ishr"> {
  let summary = "component-wise arithmetic shift right";
  let description = [{
    The `dxbc.ishr` operation computes the component-wise arithmetic
    shift of each 32-bit value in $lhs right by $rhs,
    `$dst = $lhs >> $rhs`.

    Example:

    ```mlir
    dxbc.ishr r<0>, r<1>, r<2>
    dxbc.ishr r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.not
//===----------------------------------------------------------------------===//

def DXBC_Not : DXBC_UnaryOp<"not"> {
  let summary = "component-wise one's complement";
  let description = [{
    The `dxbc.not` operation performs a component-wise one's complement of
    each 32-bit value in $src, `$dst = ~$src`.

    Example:

    ```mlir
    dxbc.not o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.or
//===----------------------------------------------------------------------===//

def DXBC_Or : DXBC_BinaryOp<"or"> {
  let summary = "component-wise logical OR";
  let description = [{
    The `dxbc.or` operation computes the component-wise logical OR of
    each pair of 32-bit values, `$dst = $lhs | $rhs`.

    Example:

    ```mlir
    dxbc.or r<0>, r<1>, r<2>
    dxbc.or r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ushr
//===----------------------------------------------------------------------===//

def DXBC_UShr : DXBC_BinaryOp<"ushr"> {
  let summary = "component-wise logical shift right";
  let description = [{
    The `dxbc.ushr` operation computes the component-wise logical shift
    of each 32-bit value in $lhs right by $rhs,
    `$dst = $lhs >> $rhs`.

    Example:

    ```mlir
    dxbc.ushr r<0>, r<1>, r<2>
    dxbc.ushr r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.xor
//===----------------------------------------------------------------------===//

def DXBC_Xor : DXBC_BinaryOp<"xor"> {
  let summary = "component-wise logical XOR";
  let description = [{
    The `dxbc.xor` operation computes the component-wise logical XOR of
    each pair of 32-bit values, `$dst = $lhs ^ $rhs`.

    Example:

    ```mlir
    dxbc.xor r<0>, r<1>, r<2>
    dxbc.xor r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS
