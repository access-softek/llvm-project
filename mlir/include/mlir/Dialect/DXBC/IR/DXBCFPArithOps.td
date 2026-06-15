//===- DXBCFPArithOps.td - DXBC float arithmetic ops ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Floating-point arithmetic instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCFPARITHOPS
#define MLIR_DIALECT_DXBC_IR_DXBCFPARITHOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.add
//===----------------------------------------------------------------------===//

def DXBC_Add : DXBC_BinaryOp<"add"> {
  let summary = "component-wise floating-point add";
  let description = [{
    The `dxbc.add` operation computes the component-wise floating-point
    sum `$dst = $lhs + $rhs`.

    Example:

    ```mlir
    dxbc.add r<0>, r<1>, r<2>
    dxbc.add r<0>, -r<1>, -|r<2>|
    dxbc.add r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.add_sat
//===----------------------------------------------------------------------===//

def DXBC_AddSat : DXBC_BinaryOp<"add_sat"> {
  let summary = "component-wise floating-point add, saturated to [0, 1]";
  let description = [{
    The `dxbc.add_sat` operation computes the component-wise floating-point
    sum of `$lhs` and `$rhs`, clamps each component of the result to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.add_sat r<0>, r<1>, r<2>
    dxbc.add_sat r<0>, -r<1>, -|r<2>|
    dxbc.add_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.div
//===----------------------------------------------------------------------===//

def DXBC_Div : DXBC_BinaryOp<"div"> {
  let summary = "component-wise floating-point divide";
  let description = [{
    The `dxbc.div` operation computes the component-wise floating-point
    quotient `$dst = $lhs / $rhs`.

    Example:

    ```mlir
    dxbc.div r<0>, r<1>, r<2>
    dxbc.div r<0>, -r<1>, -|r<2>|
    dxbc.div r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.div_sat
//===----------------------------------------------------------------------===//

def DXBC_DivSat : DXBC_BinaryOp<"div_sat"> {
  let summary = "component-wise floating-point divide, saturated to [0, 1]";
  let description = [{
    The `dxbc.div_sat` operation computes the component-wise floating-point
    quotient of `$lhs` and `$rhs`, clamps each component of the result to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.div_sat r<0>, r<1>, r<2>
    dxbc.div_sat r<0>, -r<1>, -|r<2>|
    dxbc.div_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCFPARITHOPS
