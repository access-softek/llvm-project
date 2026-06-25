//===- DXBCTypeConversionOps.td - DXBC type conversion ops *- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Type conversion instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCTYPECONVERSIONOPS
#define MLIR_DIALECT_DXBC_IR_DXBCTYPECONVERSIONOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.dtof
//===----------------------------------------------------------------------===//

def DXBC_DToF : DXBC_UnaryOp<"dtof"> {
  let summary = "component-wise double-precision to single-precision float conversion";
  let description = [{
    The `dxbc.dtof` operation converts each double-precision component of
    `$src` to a single-precision float using round-to-nearest-even rounding
    and writes the result to `$dst`.

    The source encodes double values as component pairs: (x,y) holds the
    first double (x = low 32 bits, y = high 32 bits) and (z,w) holds the
    second. Valid source swizzles are .xyzw, .xyxy, .zwxy, and .zwzw.
    Valid destination write masks are any one or two components.

    Example:

    ```mlir
    dxbc.dtof r<0, <x, y>>, r<1>
    dxbc.dtof r<0, <x, y>>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dtoi
//===----------------------------------------------------------------------===//

def DXBC_DToI : DXBC_UnaryOp<"dtoi"> {
  let summary = "component-wise double-precision float to signed int32 conversion";
  let description = [{
    The `dxbc.dtoi` operation converts each double-precision component of
    `$src` to a signed 32-bit integer, rounding toward zero, and writes it
    to `$dst`.

    The source encodes double values as component pairs: (x,y) holds the
    first double (x = low 32 bits, y = high 32 bits) and (z,w) holds the
    second. Valid source swizzles are .xyzw, .xyxy, .zwxy, and .zwzw.
    Valid destination write masks are any one or two components.

    Example:

    ```mlir
    dxbc.dtoi r<0, <x, y>>, r<1>
    dxbc.dtoi r<0, <x, y>>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dtou
//===----------------------------------------------------------------------===//

def DXBC_DToU : DXBC_UnaryOp<"dtou"> {
  let summary = "component-wise double-precision float to unsigned int32 conversion";
  let description = [{
    The `dxbc.dtou` operation converts each double-precision component of
    `$src` to an unsigned 32-bit integer, rounding toward zero, and writes
    it to `$dst`.

    The source encodes double values as component pairs: (x,y) holds the
    first double (x = low 32 bits, y = high 32 bits) and (z,w) holds the
    second. Valid source swizzles are .xyzw, .xyxy, .zwxy, and .zwzw.
    Valid destination write masks are any one or two components.

    Example:

    ```mlir
    dxbc.dtou r<0, <x, y>>, r<1>
    dxbc.dtou r<0, <x, y>>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.f16tof32
//===----------------------------------------------------------------------===//

def DXBC_F16ToF32 : DXBC_UnaryOp<"f16tof32"> {
  let summary = "component-wise float16 to float32 conversion";
  let description = [{
    The `dxbc.f16tof32` operation converts the component-wise float16 value
    stored in the low 16 bits of `$src` to float32 and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.f16tof32 r<0>, r<1>
    dxbc.f16tof32 r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.f32tof16
//===----------------------------------------------------------------------===//

def DXBC_F32ToF16 : DXBC_UnaryOp<"f32tof16"> {
  let summary = "component-wise float32 to float16 conversion";
  let description = [{
    The `dxbc.f32tof16` operation converts each float32 component of `$src` to
    float16, places the result in the low 16 bits of the corresponding `$dst`
    component, and sets the upper 16 bits to zero.

    Example:

    ```mlir
    dxbc.f32tof16 r<0>, r<1>
    dxbc.f32tof16 r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ftod
//===----------------------------------------------------------------------===//

def DXBC_FToD : DXBC_UnaryOp<"ftod"> {
  let summary = "component-wise single-precision float to double-precision conversion";
  let description = [{
    The `dxbc.ftod` operation converts each single-precision float component
    of `$src` to a double-precision float and writes the result to `$dst`.

    The destination encodes double values as component pairs: .xy receives
    the first conversion result (x = low 32 bits, y = high 32 bits) and .zw
    receives the second. Valid destination write masks are .xy, .zw, and
    .xyzw. The source provides two float32 components via x and y (z and w
    are ignored after swizzle).

    Example:

    ```mlir
    dxbc.ftod r<0>, r<1>
    dxbc.ftod r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ftoi
//===----------------------------------------------------------------------===//

def DXBC_FToI : DXBC_UnaryOp<"ftoi"> {
  let summary = "component-wise float to signed integer conversion";
  let description = [{
    The `dxbc.ftoi` operation converts each floating-point component of `$src`
    to a signed 32-bit integer, rounding towards zero, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.ftoi r<0>, r<1>
    dxbc.ftoi r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ftou
//===----------------------------------------------------------------------===//

def DXBC_FToU : DXBC_UnaryOp<"ftou"> {
  let summary = "component-wise float to unsigned integer conversion";
  let description = [{
    The `dxbc.ftou` operation converts each floating-point component of `$src`
    to an unsigned 32-bit integer, rounding towards zero, and writes it to
    `$dst`.

    Example:

    ```mlir
    dxbc.ftou r<0>, r<1>
    dxbc.ftou r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.itod
//===----------------------------------------------------------------------===//

def DXBC_IToD : DXBC_UnaryOp<"itod"> {
  let summary = "component-wise signed int32 to double-precision float conversion";
  let description = [{
    The `dxbc.itod` operation converts each signed 32-bit integer component
    of `$src` to a double-precision float and writes the result to `$dst`.

    The destination encodes double values as component pairs: .xy receives
    the first conversion result (x = low 32 bits, y = high 32 bits) and .zw
    receives the second. Valid destination write masks are .xy, .zw, and
    .xyzw. The source provides two int32 components via x and y (z and w
    are ignored after swizzle).

    Example:

    ```mlir
    dxbc.itod r<0>, r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.itof
//===----------------------------------------------------------------------===//

def DXBC_IToF : DXBC_UnaryOp<"itof"> {
  let summary = "component-wise signed integer to float conversion";
  let description = [{
    The `dxbc.itof` operation converts each signed 32-bit integer component of
    `$src` to floating-point and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.itof r<0>, r<1>
    dxbc.itof r<0>, -r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.utod
//===----------------------------------------------------------------------===//

def DXBC_UToD : DXBC_UnaryOp<"utod"> {
  let summary = "component-wise unsigned int32 to double-precision float conversion";
  let description = [{
    The `dxbc.utod` operation converts each unsigned 32-bit integer component
    of `$src` to a double-precision float and writes the result to `$dst`.

    The destination encodes double values as component pairs: .xy receives
    the first conversion result (x = low 32 bits, y = high 32 bits) and .zw
    receives the second. Valid destination write masks are .xy, .zw, and
    .xyzw. The source provides two uint32 components via x and y (z and w
    are ignored after swizzle).

    Example:

    ```mlir
    dxbc.utod r<0>, r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.utof
//===----------------------------------------------------------------------===//

def DXBC_UToF : DXBC_UnaryOp<"utof"> {
  let summary = "component-wise unsigned integer to float conversion";
  let description = [{
    The `dxbc.utof` operation converts each unsigned 32-bit integer component
    of `$src` to floating-point and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.utof r<0>, r<1>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCTYPECONVERSIONOPS
