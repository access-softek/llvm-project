//===- DXBCRasterOps.td - DXBC raster ops ------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Raster instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCRASTEROPS
#define MLIR_DIALECT_DXBC_IR_DXBCRASTEROPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

def DXBC_DerivRtx : DXBC_UnaryOp<"deriv_rtx"> {
  let summary = "computes the rate of change of components";
  let description = [{
    The `dxbc.deriv_rtx` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget x direction ("rtx").
    Only a single x,y derivative pair is computed for each 2x2 stamp of pixels.

    Pixel Shader always runs Shader over 2x2 quad of pixels in lockstep (even
    through flow control, masking disabled pixels). Quads always have even
    numbered pixel coordinates (both x and y) for top-left pixel. Dummy pixels
    run off primitive if primitive is too small to fill a 2x2 quad.

    `deriv_rtx` is computed by first choosing 2 pixels: the current pixel and
    the other pixel with the same `y` coordinate from the quad. Then, the result
    is calculated as: `$src`(odd x pixel) - `$src`(even x pixel)` [per-component].

    Example:

    ```mlir
    dxbc.deriv_rtx r<0>, v<1>
    dxbc.deriv_rtx r<0>, -|v<1>|
    dxbc.deriv_rtx r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtxSat : DXBC_UnaryOp<"deriv_rtx_sat"> {
  let summary =
      "computes the rate of change of components, saturated to [0, 1]";
  let description = [{
    The `dxbc.deriv_rtx_sat` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget x direction ("rtx").
    Only a single x,y derivative pair is computed for each 2x2 stamp of pixels.

    Pixel Shader always runs Shader over 2x2 quad of pixels in lockstep (even
    through flow control, masking disabled pixels). Quads always have even
    numbered pixel coordinates (both x and y) for top-left pixel. Dummy pixels
    run off primitive if primitive is too small to fill a 2x2 quad.

    `deriv_rtx_sat` is computed by first choosing 2 pixels: the current pixel and
    the other pixel with the same `y` coordinate from the quad. Then, the result
    is calculated as: `$src`(odd x pixel) - `$src`(even x pixel)` [per-component],
    and then clamped to `[0.0, 1.0]`.

    Example:

    ```mlir
    dxbc.deriv_rtx_sat r<0>, v<1>
    dxbc.deriv_rtx_sat r<0>, -|v<1>|
    dxbc.deriv_rtx_sat r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRty : DXBC_UnaryOp<"deriv_rty"> {
  let summary = "computes the rate of change of components";
  let description = [{
    The `dxbc.deriv_rty` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget y direction ("rty").
    Only a single x,y derivative pair is computed for each 2x2 stamp of pixels.

    Pixel Shader always runs Shader over 2x2 quad of pixels in lockstep (even
    through flow control, masking disabled pixels). Quads always have even
    numbered pixel coordinates (both x and y) for top-left pixel. Dummy pixels
    run off primitive if primitive is too small to fill a 2x2 quad.

    `deriv_rty` is computed by first choosing 2 pixels: the current pixel and
    the other pixel with the same `x` coordinate from the quad. Then, the result
    is calculated as: `$src`(odd y pixel) - `$src`(even y pixel)` [per-component].

    Example:

    ```mlir
    dxbc.deriv_rty r<0>, v<1>
    dxbc.deriv_rty r<0>, -|v<1>|
    dxbc.deriv_rty r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtySat : DXBC_UnaryOp<"deriv_rty_sat"> {
  let summary =
      "computes the rate of change of components, saturated to [0, 1]";
  let description = [{
    The `dxbc.deriv_rty_sat` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget y direction ("rty").
    Only a single x,y derivative pair is computed for each 2x2 stamp of pixels.

    Pixel Shader always runs Shader over 2x2 quad of pixels in lockstep (even
    through flow control, masking disabled pixels). Quads always have even
    numbered pixel coordinates (both x and y) for top-left pixel. Dummy pixels
    run off primitive if primitive is too small to fill a 2x2 quad.

    `deriv_rty_sat` is computed by first choosing 2 pixels: the current pixel and
    the other pixel with the same `x` coordinate from the quad. Then, the result
    is calculated as: `$src`(odd y pixel) - `$src`(even y pixel)` [per-component],
    and then clamped to `[0.0, 1.0]`.

    Example:

    ```mlir
    dxbc.deriv_rty_sat r<0>, v<1>
    dxbc.deriv_rty_sat r<0>, -|v<1>|
    dxbc.deriv_rty_sat r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtxCoarse : DXBC_UnaryOp<"deriv_rtx_coarse"> {
  let summary = "computes the rate of change of components";
  let description = [{
    The `dxbc.deriv_rtx_coarse` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget x direction ("rtx"); for the y direction, see
    `dxbc.deriv_rty_coarse`.
    Only a single x,y derivative pair is computed for each 2x2 stamp of pixels.

    The data in the current pixel shader invocation may or may not participate
    in the calculation of the requested derivative, because the derivative will
    be calculated only once per 2x2 quad. For example, the x derivative could
    be a delta from the top row of pixels, and the y direction (`deriv_rty_coarse`)
    could be a delta from the left column of pixels. The exact calculation is
    up to the hardware vendor. There is also no specification dictating how the
    2x2 quads will be aligned or tiled over a primitive.

    Derivatives are calculated at a coarse level, once per 2x2 pixel quad.
    This instruction and `deriv_rty_coarse` are alternatives to `deriv_rtx_fine`
    and `deriv_rty_fine`. These `_coarse` and `_fine` derivative instructions
    are a replacement for `deriv_rtx`/`deriv_rty` from previous shader models.

    Example:

    ```mlir
    dxbc.deriv_rtx_coarse r<0>, v<1>
    dxbc.deriv_rtx_coarse r<0>, -|v<1>|
    dxbc.deriv_rtx_coarse r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtxCoarseSat : DXBC_UnaryOp<"deriv_rtx_coarse_sat"> {
  let summary =
      "computes the rate of change of components, saturated to [0, 1]";
  let description = [{
    The `dxbc.deriv_rtx_coarse_sat` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget x direction ("rtx"); for the y direction, see
    `dxbc.deriv_rty_coarse`.
    Only a single x,y derivative pair is computed for each 2x2 stamp of pixels.
    The result is clamped to `[0.0, 1.0]`.

    The data in the current pixel shader invocation may or may not participate
    in the calculation of the requested derivative, because the derivative will
    be calculated only once per 2x2 quad. For example, the x derivative could
    be a delta from the top row of pixels, and the y direction (`deriv_rty_coarse`)
    could be a delta from the left column of pixels. The exact calculation is
    up to the hardware vendor. There is also no specification dictating how the
    2x2 quads will be aligned or tiled over a primitive.

    Derivatives are calculated at a coarse level, once per 2x2 pixel quad.
    This instruction and `deriv_rty_coarse` are alternatives to `deriv_rtx_fine`
    and `deriv_rty_fine`. These `_coarse` and `_fine` derivative instructions
    are a replacement for `deriv_rtx`/`deriv_rty` from previous shader models.

    Example:

    ```mlir
    dxbc.deriv_rtx_coarse_sat r<0>, v<1>
    dxbc.deriv_rtx_coarse_sat r<0>, -|v<1>|
    dxbc.deriv_rtx_coarse_sat r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtyCoarse : DXBC_UnaryOp<"deriv_rty_coarse"> {
  let summary = "computes the rate of change of components";
  let description = [{
    See `dxbc.deriv_rtx_coarse`.

    Example:

    ```mlir
    dxbc.deriv_rty_coarse r<0>, v<1>
    dxbc.deriv_rty_coarse r<0>, -|v<1>|
    dxbc.deriv_rty_coarse r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtyCoarseSat : DXBC_UnaryOp<"deriv_rty_coarse_sat"> {
  let summary =
      "computes the rate of change of components, saturated to [0, 1]";
  let description = [{
    See `dxbc.deriv_rtx_coarse_sat`.

    Example:

    ```mlir
    dxbc.deriv_rty_coarse_sat r<0>, v<1>
    dxbc.deriv_rty_coarse_sat r<0>, -|v<1>|
    dxbc.deriv_rty_coarse_sat r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtxFine : DXBC_UnaryOp<"deriv_rtx_fine"> {
  let summary = "computes the rate of change of components";
  let description = [{
    The `dxbc.deriv_rtx_fine` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget x direction ("rtx"); for the y direction, see
    `dxbc.deriv_rty_fine`.
    Each pixel in the 2x2 stamp gets a unique pair of x/y derivative calculations
    (looking at both `deriv_rtx_fine` and `deriv_rty_fine`).

    The data in the current Pixel Shader invocation always participates in the
    calculation of the requested derivative. In the 2x2 pixel quad the current
    pixel falls within, the x derivative is the delta of the row of 2 pixels
    including the current pixel. The y derivative is the delta of the column
    of 2 pixels including the current pixel. There is no specification
    dictating how the 2x2 quads will be aligned/tiled over a primitive.

    Derivatives calculated at a fine level (unique calculation of the x/y
    derivative pair for each pixel in a 2x2 quad).
    This instruction and `deriv_rty_fine` are alternatives to `deriv_rtx_coarse`
    and `deriv_rty_coarse`. These `_coarse` and `_fine` derivative instructions
    are a replacement for `deriv_rtx`/`deriv_rty` from previous shader models.

    Example:

    ```mlir
    dxbc.deriv_rtx_fine r<0>, v<1>
    dxbc.deriv_rtx_fine r<0>, -|v<1>|
    dxbc.deriv_rtx_fine r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtxFineSat : DXBC_UnaryOp<"deriv_rtx_fine_sat"> {
  let summary =
      "computes the rate of change of components, saturated to [0, 1]";
  let description = [{
    The `dxbc.deriv_rtx_fine_sat` operation computes the rate of change of contents
    of each float32 component of `$src` (post-swizzle), with regard to
    RenderTarget x direction ("rtx"); for the y direction, see
    `dxbc.deriv_rty_fine`.
    Each pixel in the 2x2 stamp gets a unique pair of x/y derivative calculations
    (looking at both `deriv_rtx_fine` and `deriv_rty_fine`).
    The result is clamped to `[0.0, 1.0]`.

    The data in the current Pixel Shader invocation always participates in the
    calculation of the requested derivative. In the 2x2 pixel quad the current
    pixel falls within, the x derivative is the delta of the row of 2 pixels
    including the current pixel. The y derivative is the delta of the column
    of 2 pixels including the current pixel. There is no specification
    dictating how the 2x2 quads will be aligned/tiled over a primitive.

    Derivatives calculated at a fine level (unique calculation of the x/y
    derivative pair for each pixel in a 2x2 quad).
    This instruction and `deriv_rty_fine` are alternatives to `deriv_rtx_coarse`
    and `deriv_rty_coarse`. These `_coarse` and `_fine` derivative instructions
    are a replacement for `deriv_rtx`/`deriv_rty` from previous shader models.

    Example:

    ```mlir
    dxbc.deriv_rtx_fine_sat r<0>, v<1>
    dxbc.deriv_rtx_fine_sat r<0>, -|v<1>|
    dxbc.deriv_rtx_fine_sat r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtyFine : DXBC_UnaryOp<"deriv_rty_fine"> {
  let summary = "computes the rate of change of components";
  let description = [{
    See `dxbc.deriv_rtx_fine`.

    Example:

    ```mlir
    dxbc.deriv_rty_fine r<0>, v<1>
    dxbc.deriv_rty_fine r<0>, -|v<1>|
    dxbc.deriv_rty_fine r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_DerivRtyFineSat : DXBC_UnaryOp<"deriv_rty_fine_sat"> {
  let summary =
      "computes the rate of change of components, saturated to [0, 1]";
  let description = [{
    See `dxbc.deriv_rtx_fine_sat`.

    Example:

    ```mlir
    dxbc.deriv_rty_fine_sat r<0>, v<1>
    dxbc.deriv_rty_fine_sat r<0>, -|v<1>|
    dxbc.deriv_rty_fine_sat r<0, <x>>, v<1, <y, z, w, y>>
    ```
  }];
}

def DXBC_LOD : DXBC_TernaryOp<"lod"> {
  let summary = "texture filtering LOD query";
  let description = [{
    The `dxbc.lod` operation returns the LOD (level of detail) that would be
    used for texture filtering. It behaves like the `dxbc.sample` instruction,
    but a filtered sample is not generated. The instruction computes the
    following vector (ClampedLOD, NonClampedLOD, 0, 0). NonClampedLOD is a
    computed LOD value that ignores any clamping from either the sampler or the
    texture (i.e., it can return negative values.)
    ClampedLOD is a computed LOD value that would be used by the actual sample
    instruction. The swizzle on `$src1` (the texture operand) allows the
    returned values to be swizzled arbitrarily before they are written to the
    destination.

    If there is no resource bound to the specified slot, 0 is returned.

    If the sampler is using anisotropic filtering the LOD should
    correspond to the fractional mip level based on the smaller
    axis of the elliptical footprint.

    This is valid for the following texture types: Texture1D, Texture2D,
    Texture3D and TextureCube.

    The `lod` instruction is not defined when used with a sampler that
    specifies point mip filtering, specifically, any `D3D10_FILTER` enum
    that ends in `MIP_POINT`.

    This instruction is valid only in Pixel Shaders.

    Example:

    ```mlir
    dxbc.lod r<0, <x>>, v<0, <x, y, x, x>>, t<0, vector, <x>>, s<0>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCRASTEROPS
