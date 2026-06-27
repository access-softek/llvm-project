//===- DXSAMoveOps.td - DXSA move ops --------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Move instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSAMOVEOPS
#define MLIR_DIALECT_DXSA_IR_DXSAMOVEOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.mov
//===----------------------------------------------------------------------===//

def DXSA_Mov : DXSA_UnaryOp<"mov"> {
  let summary = "component-wise move";
  let description = [{
    The `dxsa.mov` operation copies each component of `$src` to `$dst`.
    Source modifiers other than swizzle assume floating-point data; without
    modifiers the bits are copied unaltered.

    Example:

    ```mlir
    dxsa.mov r<0>, r<1>
    dxsa.mov r<0>, -|r<1>|
    dxsa.mov r<0, <x, y>>, r<1, <y, z, x, w>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.mov_sat
//===----------------------------------------------------------------------===//

def DXSA_MovSat : DXSA_UnaryOp<"mov_sat"> {
  let summary = "component-wise move, saturated to [0, 1]";
  let description = [{
    The `dxsa.mov_sat` operation copies each component of `$src`, clamps the
    result to `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.mov_sat r<0>, r<1>
    dxsa.mov_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dmov
//===----------------------------------------------------------------------===//

def DXSA_DMov : DXSA_UnaryOp<"dmov"> {
  let summary = "component-wise double-precision move";
  let description = [{
    The `dxsa.dmov` operation copies each double-precision component of
    `$src` to `$dst`. Source modifiers other than swizzle assume
    floating-point data; without modifiers the bits are copied unaltered.

    The source encodes double values as component pairs: (x,y) holds the
    first double (x = low 32 bits, y = high 32 bits) and (z,w) holds the
    second. Valid source swizzles are .xyzw, .xyxy, .zwxy, and .zwzw.
    Valid destination write masks are .xy, .zw, and .xyzw.

    Example:

    ```mlir
    dxsa.dmov r<0>, r<1>
    dxsa.dmov r<0, <x, y>>, r<1, <z, w, x, y>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.dmov_sat
//===----------------------------------------------------------------------===//

def DXSA_DMovSat : DXSA_UnaryOp<"dmov_sat"> {
  let summary = "component-wise double-precision move, saturated to [0, 1]";
  let description = [{
    The `dxsa.dmov_sat` operation copies each double-precision component of
    `$src`, clamps the result to `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.dmov_sat r<0>, r<1>
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAMOVEOPS
