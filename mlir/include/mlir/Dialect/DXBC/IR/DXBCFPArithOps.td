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

//===----------------------------------------------------------------------===//
// dxbc.dp2
//===----------------------------------------------------------------------===//

def DXBC_Dp2 : DXBC_BinaryOp<"dp2"> {
  let summary = "2D floating-point dot product";
  let description = [{
    The `dxbc.dp2` operation computes the 2D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    two components are summed into a single scalar that is replicated to
    every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxbc.dp2 r<0>, r<1>, r<2>
    dxbc.dp2 r<0>, -r<1>, -|r<2>|
    dxbc.dp2 r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dp2_sat
//===----------------------------------------------------------------------===//

def DXBC_Dp2Sat : DXBC_BinaryOp<"dp2_sat"> {
  let summary = "2D floating-point dot product, saturated to [0, 1]";
  let description = [{
    The `dxbc.dp2_sat` operation computes the 2D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    two components are summed into a single scalar, clamped to `[0.0, 1.0]`,
    and replicated to every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxbc.dp2_sat r<0>, r<1>, r<2>
    dxbc.dp2_sat r<0>, -r<1>, -|r<2>|
    dxbc.dp2_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dp3
//===----------------------------------------------------------------------===//

def DXBC_Dp3 : DXBC_BinaryOp<"dp3"> {
  let summary = "3D floating-point dot product";
  let description = [{
    The `dxbc.dp3` operation computes the 3D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    three components are summed into a single scalar that is replicated to
    every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxbc.dp3 r<0>, r<1>, r<2>
    dxbc.dp3 r<0>, -r<1>, -|r<2>|
    dxbc.dp3 r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dp3_sat
//===----------------------------------------------------------------------===//

def DXBC_Dp3Sat : DXBC_BinaryOp<"dp3_sat"> {
  let summary = "3D floating-point dot product, saturated to [0, 1]";
  let description = [{
    The `dxbc.dp3_sat` operation computes the 3D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    three components are summed into a single scalar, clamped to
    `[0.0, 1.0]`, and replicated to every component selected by the write
    mask of `$dst`.

    Example:

    ```mlir
    dxbc.dp3_sat r<0>, r<1>, r<2>
    dxbc.dp3_sat r<0>, -r<1>, -|r<2>|
    dxbc.dp3_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dp4
//===----------------------------------------------------------------------===//

def DXBC_Dp4 : DXBC_BinaryOp<"dp4"> {
  let summary = "4D floating-point dot product";
  let description = [{
    The `dxbc.dp4` operation computes the 4D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their four
    components are summed into a single scalar that is replicated to every
    component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxbc.dp4 r<0>, r<1>, r<2>
    dxbc.dp4 r<0>, -r<1>, -|r<2>|
    dxbc.dp4 r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dp4_sat
//===----------------------------------------------------------------------===//

def DXBC_Dp4Sat : DXBC_BinaryOp<"dp4_sat"> {
  let summary = "4D floating-point dot product, saturated to [0, 1]";
  let description = [{
    The `dxbc.dp4_sat` operation computes the 4D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their four
    components are summed into a single scalar, clamped to `[0.0, 1.0]`, and
    replicated to every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxbc.dp4_sat r<0>, r<1>, r<2>
    dxbc.dp4_sat r<0>, -r<1>, -|r<2>|
    dxbc.dp4_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_ne
//===----------------------------------------------------------------------===//

def DXBC_RoundNe : DXBC_UnaryOp<"round_ne"> {
  let summary =
      "component-wise floating-point round to integral float, towards nearest even";
  let description = [{
    The `dxbc.round_ne` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards nearest even.

    Example:

    ```mlir
    dxbc.round_ne r<0>, r<1>
    dxbc.round_ne r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_ne_sat
//===----------------------------------------------------------------------===//

def DXBC_RoundNeSat : DXBC_UnaryOp<"round_ne_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "nearest even, saturated to [0, 1]";
  let description = [{
    The `dxbc.round_ne_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards nearest even.

    Example:

    ```mlir
    dxbc.round_ne_sat r<0>, r<1>
    dxbc.round_ne_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_ni
//===----------------------------------------------------------------------===//

def DXBC_RoundNi : DXBC_UnaryOp<"round_ni"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "negative infinity";
  let description = [{
    The `dxbc.round_ni` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards negative infinity (floor).

    Example:

    ```mlir
    dxbc.round_ni r<0>, r<1>
    dxbc.round_ni r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_ni_sat
//===----------------------------------------------------------------------===//

def DXBC_RoundNiSat : DXBC_UnaryOp<"round_ni_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "negative infinity, saturated to [0, 1]";
  let description = [{
    The `dxbc.round_ni_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards negative
    infinity (floor).

    Example:

    ```mlir
    dxbc.round_ni_sat r<0>, r<1>
    dxbc.round_ni_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_pi
//===----------------------------------------------------------------------===//

def DXBC_RoundPi : DXBC_UnaryOp<"round_pi"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "positive infinity";
  let description = [{
    The `dxbc.round_pi` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards positive infinity (ceil).

    Example:

    ```mlir
    dxbc.round_pi r<0>, r<1>
    dxbc.round_pi r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_pi_sat
//===----------------------------------------------------------------------===//

def DXBC_RoundPiSat : DXBC_UnaryOp<"round_pi_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "positive infinity, saturated to [0, 1]";
  let description = [{
    The `dxbc.round_pi_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards positive
    infinity (ceil).

    Example:

    ```mlir
    dxbc.round_pi_sat r<0>, r<1>
    dxbc.round_pi_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_z
//===----------------------------------------------------------------------===//

def DXBC_RoundZ : DXBC_UnaryOp<"round_z"> {
  let summary =
      "component-wise floating-point round to integral float, towards zero";
  let description = [{
    The `dxbc.round_z` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards zero.

    Example:

    ```mlir
    dxbc.round_z r<0>, r<1>
    dxbc.round_z r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.round_z_sat
//===----------------------------------------------------------------------===//

def DXBC_RoundZSat : DXBC_UnaryOp<"round_z_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "zero, saturated to [0, 1]";
  let description = [{
    The `dxbc.round_z_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards zero.

    Example:

    ```mlir
    dxbc.round_z_sat r<0>, r<1>
    dxbc.round_z_sat r<0>, -|r<1>|
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCFPARITHOPS
