//===- DXBCMoveOps.td - DXBC move ops --------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Move instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCMOVEOPS
#define MLIR_DIALECT_DXBC_IR_DXBCMOVEOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.mov
//===----------------------------------------------------------------------===//

def DXBC_Mov : DXBC_UnaryOp<"mov"> {
  let summary = "component-wise move";
  let description = [{
    The `dxbc.mov` operation copies each component of `$src` to `$dst`.
    Source modifiers other than swizzle assume floating-point data; without
    modifiers the bits are copied unaltered.

    Example:

    ```mlir
    dxbc.mov r<0>, r<1>
    dxbc.mov r<0>, -|r<1>|
    dxbc.mov r<0, <x, y>>, r<1, <y, z, x, w>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.mov_sat
//===----------------------------------------------------------------------===//

def DXBC_MovSat : DXBC_UnaryOp<"mov_sat"> {
  let summary = "component-wise move, saturated to [0, 1]";
  let description = [{
    The `dxbc.mov_sat` operation copies each component of `$src`, clamps the
    result to `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.mov_sat r<0>, r<1>
    dxbc.mov_sat r<0>, -|r<1>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmov
//===----------------------------------------------------------------------===//

def DXBC_DMov : DXBC_UnaryOp<"dmov"> {
  let summary = "component-wise double-precision move";
  let description = [{
    The `dxbc.dmov` operation copies each double-precision component of
    `$src` to `$dst`. Source modifiers other than swizzle assume
    floating-point data; without modifiers the bits are copied unaltered.

    The source encodes double values as component pairs: (x,y) holds the
    first double (x = low 32 bits, y = high 32 bits) and (z,w) holds the
    second. Valid source swizzles are .xyzw, .xyxy, .zwxy, and .zwzw.
    Valid destination write masks are .xy, .zw, and .xyzw.

    Example:

    ```mlir
    dxbc.dmov r<0>, r<1>
    dxbc.dmov r<0, <x, y>>, r<1, <z, w, x, y>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmov_sat
//===----------------------------------------------------------------------===//

def DXBC_DMovSat : DXBC_UnaryOp<"dmov_sat"> {
  let summary = "component-wise double-precision move, saturated to [0, 1]";
  let description = [{
    The `dxbc.dmov_sat` operation copies each double-precision component of
    `$src`, clamps the result to `[0.0, 1.0]`, and writes it to `$dst`.

    Example:

    ```mlir
    dxbc.dmov_sat r<0>, r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmovc
//===----------------------------------------------------------------------===//

class DXBC_DMovConditionalOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$condition,
      DXBC_SrcOperandAttr:$src1,
      DXBC_SrcOperandAttr:$src2,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat =
      "(`precise` $precise^)? $dst `,` $condition `,` $src1 `,` $src2 attr-dict";
}

def DXBC_DMovC : DXBC_DMovConditionalOp<"dmovc"> {
  let summary = "component-wise double-precision conditional move";
  let description = [{
    The `dxbc.dmovc` operation performs a component-wise double-precision
    conditional move:

    ```
    $dst = ($condition != 0) ? $src1 : $src2
    ```

    The first two post-swizzle components of `$condition` are treated as two
    independent 32-bit boolean values, one per output double. Doubles are
    encoded as component pairs (x = low 32 bits, y = high 32 bits) and
    (z = low 32 bits, w = high 32 bits). Valid `$dst` write masks are
    `.xy`, `.zw`, and `.xyzw`; valid `$src1`/`$src2` swizzles are `.xyzw`,
    `.xyxy`, `.zwxy`, and `.zwzw`.

    Example:

    ```mlir
    dxbc.dmovc r<0>, r<1>, r<2>, r<3>
    dxbc.dmovc r<0, <x, y>>, r<1>, r<2, <z, w, x, y>>, r<3>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmovc_sat
//===----------------------------------------------------------------------===//

def DXBC_DMovCSat : DXBC_DMovConditionalOp<"dmovc_sat"> {
  let summary =
      "component-wise double-precision conditional move, saturated to [0, 1]";
  let description = [{
    The `dxbc.dmovc_sat` operation performs a component-wise double-precision
    conditional move, clamps the result to `[0.0, 1.0]`, and writes it to
    `$dst`:

    ```
    $dst = clamp(($condition != 0) ? $src1 : $src2, 0.0, 1.0)
    ```

    Example:

    ```mlir
    dxbc.dmovc_sat r<0>, r<1>, r<2>, r<3>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.swapc
//===----------------------------------------------------------------------===//

def DXBC_SwapC : DXBC_Op<"swapc"> {
  let summary = "component-wise conditional swap of two values";
  let description = [{
    The `dxbc.swapc` operation performs a component-wise conditional swap of
    the values in `$src1` and `$src2`:

    ```
    $dst0 = ($condition != 0) ? $src2 : $src1
    $dst1 = ($condition != 0) ? $src1 : $src2
    ```

    Both destinations are updated atomically with respect to the source
    values, so reading and writing the same register is well-defined.

    Example:

    ```mlir
    dxbc.swapc r<0>, r<1>, r<2>, r<3>, r<4>
    dxbc.swapc r<0, <x, y>>, r<1, <z, w>>, r<2>, r<3>, r<4>
    ```
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst0,
      DXBC_DstOperandAttr:$dst1,
      DXBC_SrcOperandAttr:$condition,
      DXBC_SrcOperandAttr:$src1,
      DXBC_SrcOperandAttr:$src2,
      OptionalAttr<DXBC_ComponentMaskAttr>:$precise);
  let results = (outs);
  let assemblyFormat = [{
    (`precise` $precise^)? $dst0 `,` $dst1 `,` $condition `,` $src1 `,` $src2
    attr-dict
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCMOVEOPS
