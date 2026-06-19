//===- DXSATypeConversionOps.td - DXSA type conversion ops *- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Type conversion instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSATYPECONVERSIONOPS
#define MLIR_DIALECT_DXSA_IR_DXSATYPECONVERSIONOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.f16tof32
//===----------------------------------------------------------------------===//

def DXSA_F16ToF32 : DXSA_UnaryOp<"f16tof32"> {
  let summary = "component-wise float16 to float32 conversion";
  let description = [{
    The `dxsa.f16tof32` operation converts the component-wise float16 value
    stored in the low 16 bits of `$src` to float32 and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.f16tof32 r<0>, r<1>
    dxsa.f16tof32 r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.f32tof16
//===----------------------------------------------------------------------===//

def DXSA_F32ToF16 : DXSA_UnaryOp<"f32tof16"> {
  let summary = "component-wise float32 to float16 conversion";
  let description = [{
    The `dxsa.f32tof16` operation converts each float32 component of `$src` to
    float16, places the result in the low 16 bits of the corresponding `$dst`
    component, and sets the upper 16 bits to zero.

    Example:

    ```mlir
    dxsa.f32tof16 r<0>, r<1>
    dxsa.f32tof16 r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.ftoi
//===----------------------------------------------------------------------===//

def DXSA_FToI : DXSA_UnaryOp<"ftoi"> {
  let summary = "component-wise float to signed integer conversion";
  let description = [{
    The `dxsa.ftoi` operation converts each floating-point component of `$src`
    to a signed 32-bit integer, rounding towards zero, and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.ftoi r<0>, r<1>
    dxsa.ftoi r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.ftou
//===----------------------------------------------------------------------===//

def DXSA_FToU : DXSA_UnaryOp<"ftou"> {
  let summary = "component-wise float to unsigned integer conversion";
  let description = [{
    The `dxsa.ftou` operation converts each floating-point component of `$src`
    to an unsigned 32-bit integer, rounding towards zero, and writes it to
    `$dst`.

    Example:

    ```mlir
    dxsa.ftou r<0>, r<1>
    dxsa.ftou r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.itof
//===----------------------------------------------------------------------===//

def DXSA_IToF : DXSA_UnaryOp<"itof"> {
  let summary = "component-wise signed integer to float conversion";
  let description = [{
    The `dxsa.itof` operation converts each signed 32-bit integer component of
    `$src` to floating-point and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.itof r<0>, r<1>
    dxsa.itof r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.utof
//===----------------------------------------------------------------------===//

def DXSA_UToF : DXSA_UnaryOp<"utof"> {
  let summary = "component-wise unsigned integer to float conversion";
  let description = [{
    The `dxsa.utof` operation converts each unsigned 32-bit integer component
    of `$src` to floating-point and writes it to `$dst`.

    Example:

    ```mlir
    dxsa.utof r<0>, r<1>
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSATYPECONVERSIONOPS
