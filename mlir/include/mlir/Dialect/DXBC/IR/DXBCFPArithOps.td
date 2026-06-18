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
// dxbc.exp
//===----------------------------------------------------------------------===//

def DXBC_Exp : DXBC_UnaryOp<"exp"> {
  let summary = "component-wise base-2 exponential";
  let description = [{
    The `dxbc.exp` operation computes the component-wise base-2 exponential
    `$dst = 2 ^ $src`.

    Example:

    ```mlir
    dxbc.exp r<0>, r<1>
    dxbc.exp r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.exp_sat
//===----------------------------------------------------------------------===//

def DXBC_ExpSat : DXBC_UnaryOp<"exp_sat"> {
  let summary = "component-wise base-2 exponential, saturated to [0, 1]";
  let description = [{
    The `dxbc.exp_sat` operation computes the component-wise base-2
    exponential of `$src`, clamps each component of the result to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.exp_sat r<0>, r<1>
    dxbc.exp_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.frc
//===----------------------------------------------------------------------===//

def DXBC_Frc : DXBC_UnaryOp<"frc"> {
  let summary = "component-wise fractional part";
  let description = [{
    The `dxbc.frc` operation extracts the component-wise fractional part of
    `$src` and writes it to `$dst`. The fractional part is `$src` minus its
    floor - `$dst` = `$rhs` - round_ni(`$lhs`), so every result component
    lies in `[0.0, 1.0)`.

    Example:

    ```mlir
    dxbc.frc r<0>, r<1>
    dxbc.frc r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.frc_sat
//===----------------------------------------------------------------------===//

def DXBC_FrcSat : DXBC_UnaryOp<"frc_sat"> {
  let summary = "component-wise fractional part, saturated to [0, 1]";
  let description = [{
    The `dxbc.frc_sat` operation extracts the component-wise fractional part
    of `$src`, clamps each component of the result to `[0.0, 1.0]`, and
    writes it to `$dst`.

    Example:

    ```mlir
    dxbc.frc_sat r<0>, r<1>
    dxbc.frc_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.log
//===----------------------------------------------------------------------===//

def DXBC_Log : DXBC_UnaryOp<"log"> {
  let summary = "component-wise base-2 logarithm";
  let description = [{
    The `dxbc.log` operation computes the component-wise base-2 logarithm
    `$dst = log2($src)`.

    Example:

    ```mlir
    dxbc.log r<0>, r<1>
    dxbc.log r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.log_sat
//===----------------------------------------------------------------------===//

def DXBC_LogSat : DXBC_UnaryOp<"log_sat"> {
  let summary = "component-wise base-2 logarithm, saturated to [0, 1]";
  let description = [{
    The `dxbc.log_sat` operation computes the component-wise base-2 logarithm
    of `$src`, clamps each component of the result to `[0.0, 1.0]`, and
    writes it to `$dst`.

    Example:

    ```mlir
    dxbc.log_sat r<0>, r<1>
    dxbc.log_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.rcp
//===----------------------------------------------------------------------===//

def DXBC_Rcp : DXBC_UnaryOp<"rcp"> {
  let summary = "component-wise reciprocal";
  let description = [{
    The `dxbc.rcp` operation computes the component-wise reciprocal
    `$dst = 1.0 / $src`.

    Example:

    ```mlir
    dxbc.rcp r<0>, r<1>
    dxbc.rcp r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.rcp_sat
//===----------------------------------------------------------------------===//

def DXBC_RcpSat : DXBC_UnaryOp<"rcp_sat"> {
  let summary = "component-wise reciprocal, saturated to [0, 1]";
  let description = [{
    The `dxbc.rcp_sat` operation computes the component-wise reciprocal of
    `$src`, clamps each component of the result to `[0.0, 1.0]`, and writes
    it to `$dst`.

    Example:

    ```mlir
    dxbc.rcp_sat r<0>, r<1>
    dxbc.rcp_sat r<0>, -|r<1>|
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

//===----------------------------------------------------------------------===//
// dxbc.rsq
//===----------------------------------------------------------------------===//

def DXBC_Rsq : DXBC_UnaryOp<"rsq"> {
  let summary = "component-wise reciprocal square root";
  let description = [{
    The `dxbc.rsq` operation computes the component-wise reciprocal square
    root `$dst = 1.0 / sqrt($src)`.

    Example:

    ```mlir
    dxbc.rsq r<0>, r<1>
    dxbc.rsq r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.rsq_sat
//===----------------------------------------------------------------------===//

def DXBC_RsqSat : DXBC_UnaryOp<"rsq_sat"> {
  let summary = "component-wise reciprocal square root, saturated to [0, 1]";
  let description = [{
    The `dxbc.rsq_sat` operation computes the component-wise reciprocal
    square root of `$src`, clamps each component of the result to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.rsq_sat r<0>, r<1>
    dxbc.rsq_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sqrt
//===----------------------------------------------------------------------===//

def DXBC_Sqrt : DXBC_UnaryOp<"sqrt"> {
  let summary = "component-wise square root";
  let description = [{
    The `dxbc.sqrt` operation computes the component-wise square root
    `$dst = sqrt($src)`.

    Example:

    ```mlir
    dxbc.sqrt r<0>, r<1>
    dxbc.sqrt r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sqrt_sat
//===----------------------------------------------------------------------===//

def DXBC_SqrtSat : DXBC_UnaryOp<"sqrt_sat"> {
  let summary = "component-wise square root, saturated to [0, 1]";
  let description = [{
    The `dxbc.sqrt_sat` operation computes the component-wise square root of
    `$src`, clamps each component of the result to `[0.0, 1.0]`, and writes
    it to `$dst`.

    Example:

    ```mlir
    dxbc.sqrt_sat r<0>, r<1>
    dxbc.sqrt_sat r<0>, -|r<1>|
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCFPARITHOPS
