//===- DXSABitwiseOps.td - DXSA bitwise ops -------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Bitwise instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSABITWISEOPS
#define MLIR_DIALECT_DXSA_IR_DXSABITWISEOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.and
//===----------------------------------------------------------------------===//

def DXSA_And : DXSA_BinaryOp<"and"> {
  let summary = "component-wise logical AND";
  let description = [{
    The `dxsa.and` operation computes the component-wise logical AND of
    each pair of 32-bit values, `$dst = $lhs & $rhs`.

    Example:

    ```mlir
    dxsa.and r<0>, r<1>, r<2>
    dxsa.and r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.or
//===----------------------------------------------------------------------===//

def DXSA_Or : DXSA_BinaryOp<"or"> {
  let summary = "component-wise logical OR";
  let description = [{
    The `dxsa.or` operation computes the component-wise logical OR of
    each pair of 32-bit values, `$dst = $lhs | $rhs`.

    Example:

    ```mlir
    dxsa.or r<0>, r<1>, r<2>
    dxsa.or r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.xor
//===----------------------------------------------------------------------===//

def DXSA_Xor : DXSA_BinaryOp<"xor"> {
  let summary = "component-wise logical XOR";
  let description = [{
    The `dxsa.xor` operation computes the component-wise logical XOR of
    each pair of 32-bit values, `$dst = $lhs ^ $rhs`.

    Example:

    ```mlir
    dxsa.xor r<0>, r<1>, r<2>
    dxsa.xor r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSABITWISEOPS
