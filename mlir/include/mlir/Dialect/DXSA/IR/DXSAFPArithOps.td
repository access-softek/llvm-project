//===- DXSAFPArithOps.td - DXSA float arithmetic ops ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Floating-point arithmetic instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSAFPARITHOPS
#define MLIR_DIALECT_DXSA_IR_DXSAFPARITHOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.add
//===----------------------------------------------------------------------===//

def DXSA_Add : DXSA_BinaryOp<"add"> {
  let summary = "component-wise floating-point add";
  let description = [{
    The `dxsa.add` operation computes the component-wise floating-point
    sum `$dst = $lhs + $rhs`.

    Example:

    ```mlir
    dxsa.add r<0>, r<1>, r<2>
    dxsa.add r<0>, -r<1>, -|r<2>|
    dxsa.add r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.add_sat
//===----------------------------------------------------------------------===//

def DXSA_AddSat : DXSA_BinaryOp<"add_sat"> {
  let summary = "component-wise floating-point add, saturated to [0, 1]";
  let description = [{
    The `dxsa.add_sat` operation computes the component-wise floating-point
    sum of `$lhs` and `$rhs`, clamps each component of the result to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.add_sat r<0>, r<1>, r<2>
    dxsa.add_sat r<0>, -r<1>, -|r<2>|
    dxsa.add_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAFPARITHOPS
