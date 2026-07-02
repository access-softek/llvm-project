//===- DXBCResourceOps.td - DXBC resource ops --------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Resource instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCRESOURCEOPS
#define MLIR_DIALECT_DXBC_IR_DXBCRESOURCEOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.eval_centroid
//===----------------------------------------------------------------------===//

def DXBC_EvalCentroid : DXBC_UnaryOp<"eval_centroid"> {
  let summary = "evaluate a pixel shader input at the centroid location";
  let description = [{
    The `dxbc.eval_centroid` operation samples the pixel shader input
    attribute `$src` at the centroid location within the pixel and writes
    the result to `$dst`.

    Example:

    ```mlir
    dxbc.eval_centroid r<0>, r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.eval_sample_index
//===----------------------------------------------------------------------===//

def DXBC_EvalSampleIndex : DXBC_BinaryOp<"eval_sample_index"> {
  let summary = "evaluate a pixel shader input at a given sample index";
  let description = [{
    The `dxbc.eval_sample_index` operation samples the pixel shader input
    attribute `$lhs` at the sample whose index is the scalar operand
    `$rhs` and writes the result to `$dst`. `$rhs` is either an integer
    immediate or a single-component register reference.

    Example:

    ```mlir
    dxbc.eval_sample_index r<0>, r<1>, l(0x2)
    dxbc.eval_sample_index r<0>, r<1>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.eval_snapped
//===----------------------------------------------------------------------===//

def DXBC_EvalSnapped : DXBC_BinaryOp<"eval_snapped"> {
  let summary = "evaluate a pixel shader input at a snapped pixel offset";
  let description = [{
    The `dxbc.eval_snapped` operation samples the pixel shader input
    attribute `$lhs` at a fractional pixel offset from the pixel center
    given by the int4 immediate operand `$rhs` (interpreted on a 16x16
    grid using the lowest 4 bits of its first two components) and writes
    the result to `$dst`.

    Example:

    ```mlir
    dxbc.eval_snapped r<0>, r<1>, l(0x2, 0x3, 0x0, 0x0)
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sample
//===----------------------------------------------------------------------===//

def DXBC_SampleOffsetAttr : AttrDef<DXBCDialect, "SampleOffset"> {
  let mnemonic = "sample_offset";
  let summary = "immediate offset for the texture coordinates for the sample";
  let description = [{
    The dxbc.sample_offset attribute indicates that the texture coordinates for
    the sample are to be offset by a set of provided immediate texel space
    integer constant values. The literal values are a set of 4 bit 2's
    complement numbers, having integer range [-8,7].
  }];
  let parameters = (ins "int32_t":$u, "int32_t":$v, "int32_t":$w);
  let assemblyFormat = "`<` struct(params) `>`";
  let genVerifyDecl = 1;
}

def DXBC_SampleClampFeedbackAttr : AttrDef<DXBCDialect, "SampleClampFeedback"> {
  let mnemonic = "sample_clamp_feedback";
  let summary = "optional LOD clamp and Tiled Resources shader feedback status output value";
  let description = [{
    The dxbc.sample_clamp_feed attribute is an optional pair of operands for
    dxbc.sample instruction.

    `lod_clamp` is an additional 32 bit scalar LOD clamp operand.

    `feedback` is a shader feedback status output value. The contents
    of the return value are opaque - direct reading by the shader
    program is disallowed.
  }];

  let parameters = (ins
    AttrParameter<"SrcOperandAttr", "lod_clamp">:$lod_clamp,
    AttrParameter<"DstOperandAttr", "feedback">:$feedback);

  let assemblyFormat = "`<` $lod_clamp `,` $feedback `>`";
}

def DXBC_Sample : DXBC_Op<"sample"> {
  let summary = "sample data from the specified texture using the filtering mode identified by the given sampler";
  let description = [{
    The dxbc.sample operation uses provided address, sample data from the
    specified Element/texture using the filtering mode identified by the given
    sampler. The source data may come from any Resource Type (5), other than
    Buffers.

    `src_address` provides the set of texture coordinates needed to perform the
    sample, as floating point values referencing normalized space in the texture.

    `src_resource` is a texture register (t). This is simply a
    placeholder for a texture, including the return data type of the
    resource being sampled.

    `src_sampler` is a sampler register (s).  This is simply a
    placeholder for a collection of filtering controls (such as point
    vs. linear, mipmapping and address wrapping controls).

    The optional `offset` operand suffix (address offset by immediate
    integer) indicates that the texture coordinates for the sample are
    to be offset by a set of provided immediate texel space integer
    constant values. The literal values are a set of 4 bit 2's
    complement numbers, having integer range [-8,7].
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler
    (`,` $offset^)?
    attr-dict
  }];
}

def DXBC_SampleClampFeedback : DXBC_Op<"sample_cl_s"> {
  let summary = "same as `dxbc.sample`, but with an additional LOD clamp and status output";
  let description = [{
    `src_address`, `src_resource`, `src_sampler`, `offset` operands
    are the same as in `dxbc.sample` instruction.

    The `clamp_feedback` operand appends an additional 32 bit scalar
    LOD clamp operand and an additional 32 bit scalar Tiled Resources
    shader feedback status output value.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SampleClampFeedbackAttr:$clamp_feedback,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $clamp_feedback
    (`,` $offset^)?
    attr-dict
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sample_b
//===----------------------------------------------------------------------===//

def DXBC_SampleB : DXBC_Op<"sample_b"> {
  let summary = "sample data from the specified texture with an additional bias applied to the LOD";
  let description = [{
    The `dxbc.sample_b` operation uses provided address, sample data from the
    specified Element/texture using the filtering mode identified by the given
    sampler. The source data may come from any Resource Type(5), other than
    Buffers. An additional bias is applied to the level of detail computed as
    part of the instruction execution.

    `src_address`, `src_resource`, `src_sampler` and `offset` operands
    are the same as in `dxbc.sample` instruction.

    The `src_lod_bias` value is added to the computed LOD on a per-pixel basis,
    along with the sampler MipLODBias value, prior to the clamp to MinLOD and
    MaxLOD.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_lod_bias,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_lod_bias
    (`,` $offset^)?
    attr-dict
  }];
}

def DXBC_SampleBClampFeedback : DXBC_Op<"sample_b_cl_s"> {
  let summary = "same as `dxbc.sample_b`, but with an additional LOD clamp and status output";
  let description = [{
    `src_address`, `src_resource`, `src_sampler`, `src_lod_bias` and
    `offset` operands are the same as in `dxbc.sample_b` instruction.

    The `clamp_feedback` operand appends an additional 32 bit scalar
    LOD clamp operand and an additional 32 bit scalar Tiled Resources
    shader feedback status output value.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_lod_bias,
      DXBC_SampleClampFeedbackAttr:$clamp_feedback,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_lod_bias `,` $clamp_feedback
    (`,` $offset^)?
    attr-dict
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sample_d
//===----------------------------------------------------------------------===//

def DXBC_SampleD : DXBC_Op<"sample_d"> {
  let summary = "sample data from the specified texture with derivatives for X and Y";
  let description = [{
    The `dxbc.sample_d` operation uses provided address, sample data from the
    specified Element/texture using the filtering mode identified by the given
    sampler. The source data may come from any Resource Type(5), other than
    Buffers.

    `src_address`, `src_resource`, `src_sampler` and `offset` operands
    are the same as in `dxbc.sample` instruction.

    Derivatives for the source address in the x direction and the y direction are
    provided by extra parameters, `src_x_derivatives` and `src_y_derivatives`,
    respectively. These derivatives are in normalized texture coordinate space.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_x_derivatives,
      DXBC_SrcOperandAttr:$src_y_derivatives,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler
    `,` $src_x_derivatives `,` $src_y_derivatives
    (`,` $offset^)?
    attr-dict
  }];
}

def DXBC_SampleDClampFeedback : DXBC_Op<"sample_d_cl_s"> {
  let summary = "same as `dxbc.sample_d`, but with an additional LOD clamp and status output";
  let description = [{
    `dst`, `src`_address, `src`_resource, `src`_sampler,
    `src`_x_derivatives, `src`_y_derivatives and `offset` operands are
    the same as in `dxbc.sample_d` instruction.

    The `clamp_feedback` operand appends an additional 32 bit scalar
    LOD clamp operand and an additional 32 bit scalar Tiled Resources
    shader feedback status output value.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_x_derivatives,
      DXBC_SrcOperandAttr:$src_y_derivatives,
      DXBC_SampleClampFeedbackAttr:$clamp_feedback,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler
    `,` $src_x_derivatives `,` $src_y_derivatives `,` $clamp_feedback
    (`,` $offset^)?
    attr-dict
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sample_l
//===----------------------------------------------------------------------===//

def DXBC_SampleL : DXBC_Op<"sample_l"> {
  let summary = "sample data from the specified texture with specific LOD";
  let description = [{
    `dxbc.sample_l` is identical to `dxbc.sample`, except that LOD is provided
    directly by the application as a scalar value, representing no anisotropy.

    `src_address`, `src_resource`, `src_sampler` and `offset` operands
    are the same as in `dxbc.sample` instruction.

    `src_lod` is the LOD value. If the LOD value is <= 0, the zero'th (biggest
    map) is chosen, with the magnify filter applied (if applicable based on the
    filter mode).  Since `src_lod` is a floating point value, the fractional
    value is used to interpolate (if the minify filter is LINEAR or with
    anisotropic filtering) between two mip levels.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_lod,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_lod
    (`,` $offset^)?
    attr-dict
  }];
}

def DXBC_SampleLFeedback : DXBC_Op<"sample_l_cl_s"> {
  let summary = "same as `dxbc.sample_l`, but with an additional LOD clamp and status output";
  let description = [{
    `dst`, `src_address`, `src_resource`,`src_sampler`, `src_lod` and
    `offset` operands are the same as in `dxbc.sample_l` instruction.

    The `clamp_feedback` operand appends an additional 32 bit scalar
    LOD clamp operand and an additional 32 bit scalar Tiled Resources
    shader feedback status output value.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_lod,
      DXBC_DstOperandAttr:$feedback,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_lod `,` $feedback
    (`,` $offset^)?
    attr-dict
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sample_c
//===----------------------------------------------------------------------===//

def DXBC_SampleC : DXBC_Op<"sample_c"> {
  let summary = "perform a comparison filter";
  let description = [{
    `dxbc.sample_c` is to provide a building-block for Percentage-Closer Depth
    filtering. The 'c' in sample_c stands for Comparison.

    The operands to `dxbc.sample_c` are identical to `dxbc.sample`, except that
    there is an additional float32 source operand, `src_reference_value`, which
    must be a register with single-component selected, or a scalar literal.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_reference_value,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_reference_value
    (`,` $offset^)?
    attr-dict
  }];
}

def DXBC_SampleCClampFeedback : DXBC_Op<"sample_c_cl_s"> {
  let summary = "same as `dxbc.sample_c`, but with an additional LOD clamp and status output";
  let description = [{
    `dst`,`src_address`,`src_resource`,`src_sampler`,`src_reference_value`
    and `offset operands are the same as in `dxbc.sample_c`
    instruction.

    The `clamp_feedback` operand appends an additional 32 bit scalar
    LOD clamp operand and an additional 32 bit scalar Tiled Resources
    shader feedback status output value.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_reference_value,
      DXBC_SampleClampFeedbackAttr:$clamp_feedback,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_reference_value `,` $clamp_feedback
    (`,` $offset^)?
    attr-dict
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.sample_c_lz
//===----------------------------------------------------------------------===//

def DXBC_SampleCLZ : DXBC_Op<"sample_c_lz"> {
  let summary = "perform a comparison filter with zero LOD";
  let description = [{
    Same as `dxbc.sample_c`, except LOD is 0, and derivatives are ignored (as if
    they are 0).  The 'lz' stands for level-zero.  Because derivatives are
    ignored, this instruction is available in shaders other than the Pixel
    Shader.

    `dxbc.sample_c` is to provide a building-block for Percentage-Closer Depth
    filtering. The 'c' in sample_c stands for Comparison.

    The operands to `dxbc.sample_c_lz` are identical to `dxbc.sample_c`.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_reference_value,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_reference_value
    (`,` $offset^)?
    attr-dict
  }];
}

def DXBC_SampleCLZFeedback : DXBC_Op<"sample_c_lz_s"> {
  let summary = "same as `dxbc.sample_c_lz`, but with an additional LOD clamp and status output";
  let description = [{
    `dst`, `src_address`, `src_resource`, `src_sampler`,
    `src_reference_value`, `offset` operands are the same as in
    `dxbc.sample` instruction.

    The `clamp_feedback` operand appends an additional 32 bit scalar
    LOD clamp operand and an additional 32 bit scalar Tiled Resources
    shader feedback status output value.
  }];

  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$src_address,
      DXBC_SrcOperandAttr:$src_resource,
      DXBC_SrcOperandAttr:$src_sampler,
      DXBC_SrcOperandAttr:$src_reference_value,
      DXBC_SampleClampFeedbackAttr:$feedback,
      OptionalAttr<DXBC_SampleOffsetAttr>:$offset);
  let results = (outs);

  let assemblyFormat = [{
    $dst `,` $src_address `,` $src_resource `,` $src_sampler `,` $src_reference_value `,` $feedback
    (`,` $offset^)?
    attr-dict
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCRESOURCEOPS
