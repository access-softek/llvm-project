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

//===----------------------------------------------------------------------===//
// dxsa.div
//===----------------------------------------------------------------------===//

def DXSA_Div : DXSA_BinaryOp<"div"> {
  let summary = "component-wise floating-point divide";
  let description = [{
    The `dxsa.div` operation computes the component-wise floating-point
    quotient `$dst = $lhs / $rhs`.

    Example:

    ```mlir
    dxsa.div r<0>, r<1>, r<2>
    dxsa.div r<0>, -r<1>, -|r<2>|
    dxsa.div r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.div_sat
//===----------------------------------------------------------------------===//

def DXSA_DivSat : DXSA_BinaryOp<"div_sat"> {
  let summary = "component-wise floating-point divide, saturated to [0, 1]";
  let description = [{
    The `dxsa.div_sat` operation computes the component-wise floating-point
    quotient of `$lhs` and `$rhs`, clamps each component of the result to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.div_sat r<0>, r<1>, r<2>
    dxsa.div_sat r<0>, -r<1>, -|r<2>|
    dxsa.div_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dp2
//===----------------------------------------------------------------------===//

def DXSA_Dp2 : DXSA_BinaryOp<"dp2"> {
  let summary = "2D floating-point dot product";
  let description = [{
    The `dxsa.dp2` operation computes the 2D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    two components are summed into a single scalar that is replicated to
    every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxsa.dp2 r<0>, r<1>, r<2>
    dxsa.dp2 r<0>, -r<1>, -|r<2>|
    dxsa.dp2 r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dp2_sat
//===----------------------------------------------------------------------===//

def DXSA_Dp2Sat : DXSA_BinaryOp<"dp2_sat"> {
  let summary = "2D floating-point dot product, saturated to [0, 1]";
  let description = [{
    The `dxsa.dp2_sat` operation computes the 2D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    two components are summed into a single scalar, clamped to `[0.0, 1.0]`,
    and replicated to every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxsa.dp2_sat r<0>, r<1>, r<2>
    dxsa.dp2_sat r<0>, -r<1>, -|r<2>|
    dxsa.dp2_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dp3
//===----------------------------------------------------------------------===//

def DXSA_Dp3 : DXSA_BinaryOp<"dp3"> {
  let summary = "3D floating-point dot product";
  let description = [{
    The `dxsa.dp3` operation computes the 3D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    three components are summed into a single scalar that is replicated to
    every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxsa.dp3 r<0>, r<1>, r<2>
    dxsa.dp3 r<0>, -r<1>, -|r<2>|
    dxsa.dp3 r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dp3_sat
//===----------------------------------------------------------------------===//

def DXSA_Dp3Sat : DXSA_BinaryOp<"dp3_sat"> {
  let summary = "3D floating-point dot product, saturated to [0, 1]";
  let description = [{
    The `dxsa.dp3_sat` operation computes the 3D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their first
    three components are summed into a single scalar, clamped to
    `[0.0, 1.0]`, and replicated to every component selected by the write
    mask of `$dst`.

    Example:

    ```mlir
    dxsa.dp3_sat r<0>, r<1>, r<2>
    dxsa.dp3_sat r<0>, -r<1>, -|r<2>|
    dxsa.dp3_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dp4
//===----------------------------------------------------------------------===//

def DXSA_Dp4 : DXSA_BinaryOp<"dp4"> {
  let summary = "4D floating-point dot product";
  let description = [{
    The `dxsa.dp4` operation computes the 4D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their four
    components are summed into a single scalar that is replicated to every
    component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxsa.dp4 r<0>, r<1>, r<2>
    dxsa.dp4 r<0>, -r<1>, -|r<2>|
    dxsa.dp4 r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dp4_sat
//===----------------------------------------------------------------------===//

def DXSA_Dp4Sat : DXSA_BinaryOp<"dp4_sat"> {
  let summary = "4D floating-point dot product, saturated to [0, 1]";
  let description = [{
    The `dxsa.dp4_sat` operation computes the 4D dot product of `$lhs` and
    `$rhs`. Each source is swizzled first, then the products of their four
    components are summed into a single scalar, clamped to `[0.0, 1.0]`, and
    replicated to every component selected by the write mask of `$dst`.

    Example:

    ```mlir
    dxsa.dp4_sat r<0>, r<1>, r<2>
    dxsa.dp4_sat r<0>, -r<1>, -|r<2>|
    dxsa.dp4_sat r<0, <x, y>>, r<1, <y, z, x, w>>, |r<2, <z, z, z, z>>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_ne
//===----------------------------------------------------------------------===//

def DXSA_RoundNe : DXSA_UnaryOp<"round_ne"> {
  let summary =
      "component-wise floating-point round to integral float, towards nearest even";
  let description = [{
    The `dxsa.round_ne` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards nearest even.

    Example:

    ```mlir
    dxsa.round_ne r<0>, r<1>
    dxsa.round_ne r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_ne_sat
//===----------------------------------------------------------------------===//

def DXSA_RoundNeSat : DXSA_UnaryOp<"round_ne_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "nearest even, saturated to [0, 1]";
  let description = [{
    The `dxsa.round_ne_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards nearest even.

    Example:

    ```mlir
    dxsa.round_ne_sat r<0>, r<1>
    dxsa.round_ne_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_ni
//===----------------------------------------------------------------------===//

def DXSA_RoundNi : DXSA_UnaryOp<"round_ni"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "negative infinity";
  let description = [{
    The `dxsa.round_ni` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards negative infinity (floor).

    Example:

    ```mlir
    dxsa.round_ni r<0>, r<1>
    dxsa.round_ni r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_ni_sat
//===----------------------------------------------------------------------===//

def DXSA_RoundNiSat : DXSA_UnaryOp<"round_ni_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "negative infinity, saturated to [0, 1]";
  let description = [{
    The `dxsa.round_ni_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards negative
    infinity (floor).

    Example:

    ```mlir
    dxsa.round_ni_sat r<0>, r<1>
    dxsa.round_ni_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_pi
//===----------------------------------------------------------------------===//

def DXSA_RoundPi : DXSA_UnaryOp<"round_pi"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "positive infinity";
  let description = [{
    The `dxsa.round_pi` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards positive infinity (ceil).

    Example:

    ```mlir
    dxsa.round_pi r<0>, r<1>
    dxsa.round_pi r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_pi_sat
//===----------------------------------------------------------------------===//

def DXSA_RoundPiSat : DXSA_UnaryOp<"round_pi_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "positive infinity, saturated to [0, 1]";
  let description = [{
    The `dxsa.round_pi_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards positive
    infinity (ceil).

    Example:

    ```mlir
    dxsa.round_pi_sat r<0>, r<1>
    dxsa.round_pi_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_z
//===----------------------------------------------------------------------===//

def DXSA_RoundZ : DXSA_UnaryOp<"round_z"> {
  let summary =
      "component-wise floating-point round to integral float, towards zero";
  let description = [{
    The `dxsa.round_z` operation performs a component-wise floating-point
    round of `$src` to an integral float, writing the integral floating-point
    values to `$dst`. Rounding is towards zero.

    Example:

    ```mlir
    dxsa.round_z r<0>, r<1>
    dxsa.round_z r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.round_z_sat
//===----------------------------------------------------------------------===//

def DXSA_RoundZSat : DXSA_UnaryOp<"round_z_sat"> {
  let summary = "component-wise floating-point round to integral float, towards "
                "zero, saturated to [0, 1]";
  let description = [{
    The `dxsa.round_z_sat` operation performs a component-wise floating-point
    round of `$src` to an integral float, clamps each resulting component to
    `[0.0, 1.0]`, and writes it to `$dst`. Rounding is towards zero.

    Example:

    ```mlir
    dxsa.round_z_sat r<0>, r<1>
    dxsa.round_z_sat r<0>, -|r<1>|
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAFPARITHOPS
