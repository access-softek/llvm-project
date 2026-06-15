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

#endif // MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS
