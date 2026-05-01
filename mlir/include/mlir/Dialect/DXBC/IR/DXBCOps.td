//===- DXBCOps.td - DXBC operations definition -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef DXBC_OPS
#define DXBC_OPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"
include "mlir/Dialect/DXBC/IR/DXBCTypes.td"
include "mlir/Dialect/DXBC/IR/DXBCFPArithOps.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/BuiltinAttributeInterfaces.td"
include "mlir/IR/EnumAttr.td"

//===----------------------------------------------------------------------===//
// DXBC module - top-level container op for a DXBC tokenized program
//===----------------------------------------------------------------------===//

def DXBC_ProgramType_PixelShader         : I32EnumAttrCase<"pixel_shader",         0>;
def DXBC_ProgramType_VertexShader        : I32EnumAttrCase<"vertex_shader",        1>;
def DXBC_ProgramType_GeometryShader      : I32EnumAttrCase<"geometry_shader",      2>;
def DXBC_ProgramType_HullShader          : I32EnumAttrCase<"hull_shader",          3>;
def DXBC_ProgramType_DomainShader        : I32EnumAttrCase<"domain_shader",        4>;
def DXBC_ProgramType_ComputeShader       : I32EnumAttrCase<"compute_shader",       5>;
def DXBC_ProgramType_MeshShader          : I32EnumAttrCase<"mesh_shader",         13>;
def DXBC_ProgramType_AmplificationShader : I32EnumAttrCase<"amplification_shader",14>;

def DXBC_ProgramType : I32EnumAttr<
    "ProgramType", "DXBC tokenized program type", [
      DXBC_ProgramType_PixelShader,
      DXBC_ProgramType_VertexShader,
      DXBC_ProgramType_GeometryShader,
      DXBC_ProgramType_HullShader,
      DXBC_ProgramType_DomainShader,
      DXBC_ProgramType_ComputeShader,
      DXBC_ProgramType_MeshShader,
      DXBC_ProgramType_AmplificationShader
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_ProgramTypeAttr :
    EnumAttr<DXBCDialect, DXBC_ProgramType, "program_type"> {
  let assemblyFormat = "$value";
}

def DXBC_ShaderVersionComponent :
    ConfinedAttr<I32Attr, [IntMinValue<0>, IntMaxValue<255>]>;

def DXBC_ModuleOp : DXBC_Op<"module", [
    IsolatedFromAbove, NoRegionArguments, NoTerminator, SingleBlock]> {
  let summary = "the top-level container for a shader program";
  let description = [{
    The `dxbc.module` operation models the top-level container of a single
    shader tokenized program (one SHEX section of the DXBC binary).

    The optional attributes are the shader program type and the major
    and minor version components. They are either all present (real
    binary with a SHEX header) or all absent (header-less raw token
    streams).

    Example:

    ```mlir
    // Binary content with a SHEX header
    dxbc.module pixel_shader 5 0 {
      dxbc.dcl_global_flags <refactoringAllowed>
    }

    // Binary content without a SHEX header
    dxbc.module {
      dxbc.dcl_global_flags <refactoringAllowed>
    }
    ```
  }];

  let arguments = (ins
    OptionalAttr<DXBC_ProgramTypeAttr>:$program_type,
    OptionalAttr<DXBC_ShaderVersionComponent>:$major_version,
    OptionalAttr<DXBC_ShaderVersionComponent>:$minor_version);
  let regions = (region SizedRegion<1>:$body);

  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;

  let extraClassDeclaration = [{
    ::mlir::Block *getBodyBlock() { return &getBody().front(); }
  }];
}

//===----------------------------------------------------------------------===//
// DXBC enum definitions
//===----------------------------------------------------------------------===//

// Global shader flags for 'dcl_globalFlags' instruction.
def DXBC_GlobalFlags_RefactoringAllowed            : I32BitEnumAttrCaseBit<"refactoringAllowed",            0>;
def DXBC_GlobalFlags_EnableDoublePrecisionFloatOps : I32BitEnumAttrCaseBit<"enableDoublePrecisionFloatOps", 1>;
def DXBC_GlobalFlags_ForceEarlyDepthStencil        : I32BitEnumAttrCaseBit<"forceEarlyDepthStencil",        2>;
def DXBC_GlobalFlags_EnableRawAndStructuredBuffers : I32BitEnumAttrCaseBit<"enableRawAndStructuredBuffers", 3>;
def DXBC_GlobalFlags_SkipOptimization              : I32BitEnumAttrCaseBit<"skipOptimization",              4>;
def DXBC_GlobalFlags_EnableMinimumPrecision        : I32BitEnumAttrCaseBit<"enableMinimumPrecision",        5>;
def DXBC_GlobalFlags_EnableDoubleExtensions        : I32BitEnumAttrCaseBit<"enableDoubleExtensions",        6>;
def DXBC_GlobalFlags_EnableShaderExtensions        : I32BitEnumAttrCaseBit<"enableShaderExtensions",        7>;
def DXBC_GlobalFlags_AllResourcesBound             : I32BitEnumAttrCaseBit<"allResourcesBound",             8>;

def DXBC_GlobalFlags : I32BitEnumAttr<
    "GlobalFlags", "global shader flags", [
      DXBC_GlobalFlags_RefactoringAllowed,
      DXBC_GlobalFlags_EnableDoublePrecisionFloatOps,
      DXBC_GlobalFlags_ForceEarlyDepthStencil,
      DXBC_GlobalFlags_EnableRawAndStructuredBuffers,
      DXBC_GlobalFlags_SkipOptimization,
      DXBC_GlobalFlags_EnableMinimumPrecision,
      DXBC_GlobalFlags_EnableDoubleExtensions,
      DXBC_GlobalFlags_EnableShaderExtensions,
      DXBC_GlobalFlags_AllResourcesBound
    ]> {
  let separator = "|";
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
  let printBitEnumPrimaryGroups = 1;
}

def DXBC_GlobalFlagsAttr :
    EnumAttr<DXBCDialect, DXBC_GlobalFlags, "global_flags"> {
  let assemblyFormat = "`<` $value `>`";
}

def DXBC_TessellatorDomain_Isoline : I32EnumAttrCase<"domain_isoline", 1>;
def DXBC_TessellatorDomain_Tri     : I32EnumAttrCase<"domain_tri",     2>;
def DXBC_TessellatorDomain_Quad    : I32EnumAttrCase<"domain_quad",    3>;

def DXBC_TessellatorDomain : I32EnumAttr<
    "TessellatorDomain", "tessellator domain", [
      DXBC_TessellatorDomain_Isoline,
      DXBC_TessellatorDomain_Tri,
      DXBC_TessellatorDomain_Quad
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_TessellatorDomainAttr :
    EnumAttr<DXBCDialect, DXBC_TessellatorDomain, "tessellator_domain"> {
  let assemblyFormat = "$value";
}

def DXBC_TessellatorOutputPrimitiveType_OutputPoint       : I32EnumAttrCase<"output_point",        1>;
def DXBC_TessellatorOutputPrimitiveType_OutputLine        : I32EnumAttrCase<"output_line",         2>;
def DXBC_TessellatorOutputPrimitiveType_OutputTriangleCw  : I32EnumAttrCase<"output_triangle_cw",  3>;
def DXBC_TessellatorOutputPrimitiveType_OutputTriangleCcw : I32EnumAttrCase<"output_triangle_ccw", 4>;

def DXBC_TessellatorOutputPrimitiveType : I32EnumAttr<
    "TessellatorOutputPrimitiveType", "tessellator output primitive type", [
      DXBC_TessellatorOutputPrimitiveType_OutputPoint,
      DXBC_TessellatorOutputPrimitiveType_OutputLine,
      DXBC_TessellatorOutputPrimitiveType_OutputTriangleCw,
      DXBC_TessellatorOutputPrimitiveType_OutputTriangleCcw
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_TessellatorOutputPrimitiveTypeAttr :
    EnumAttr<DXBCDialect, DXBC_TessellatorOutputPrimitiveType,
             "tessellator_output_primitive_type"> {
  let assemblyFormat = "$value";
}

def DXBC_OutputPrimitiveTopology_PointList     : I32EnumAttrCase<"pointlist",     1>;
def DXBC_OutputPrimitiveTopology_LineStrip     : I32EnumAttrCase<"linestrip",     3>;
def DXBC_OutputPrimitiveTopology_TriangleStrip : I32EnumAttrCase<"trianglestrip", 5>;

def DXBC_OutputPrimitiveTopology : I32EnumAttr<
    "OutputPrimitiveTopology", "shader output primitive topology", [
      DXBC_OutputPrimitiveTopology_PointList,
      DXBC_OutputPrimitiveTopology_LineStrip,
      DXBC_OutputPrimitiveTopology_TriangleStrip
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_OutputPrimitiveTopologyAttr :
    EnumAttr<DXBCDialect, DXBC_OutputPrimitiveTopology,
             "output_primitive_topology"> {
  let assemblyFormat = "$value";
}

def DXBC_TessellatorPartitioningMode_Integer        : I32EnumAttrCase<"partitioning_integer",         1>;
def DXBC_TessellatorPartitioningMode_Pow2           : I32EnumAttrCase<"partitioning_pow2",            2>;
def DXBC_TessellatorPartitioningMode_FractionalOdd  : I32EnumAttrCase<"partitioning_fractional_odd",  3>;
def DXBC_TessellatorPartitioningMode_FractionalEven : I32EnumAttrCase<"partitioning_fractional_even", 4>;

def DXBC_TessellatorPartitioningMode : I32EnumAttr<
    "TessellatorPartitioningMode", "tessellator partitioning mode", [
      DXBC_TessellatorPartitioningMode_Integer,
      DXBC_TessellatorPartitioningMode_Pow2,
      DXBC_TessellatorPartitioningMode_FractionalOdd,
      DXBC_TessellatorPartitioningMode_FractionalEven
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_TessellatorPartitioningModeAttr :
    EnumAttr<DXBCDialect, DXBC_TessellatorPartitioningMode,
             "tessellator_partitioning_mode"> {
  let assemblyFormat = "$value";
}

def DXBC_InputPrimitive_Point        : I32EnumAttrCase<"point",         1>;
def DXBC_InputPrimitive_Line         : I32EnumAttrCase<"line",          2>;
def DXBC_InputPrimitive_Triangle     : I32EnumAttrCase<"triangle",      3>;
def DXBC_InputPrimitive_LineAdj      : I32EnumAttrCase<"line_adj",      6>;
def DXBC_InputPrimitive_TriangleAdj  : I32EnumAttrCase<"triangle_adj",  7>;
foreach i = !range(1, 33) in {
  def DXBC_InputPrimitive_Patch#i :
      I32EnumAttrCase<"patch" # i, !add(i, 7)>;
}

def DXBC_InputPrimitive : I32EnumAttr<
    "InputPrimitive", "geometry shader input primitive type",
    !listconcat(
      [DXBC_InputPrimitive_Point,
       DXBC_InputPrimitive_Line,
       DXBC_InputPrimitive_Triangle,
       DXBC_InputPrimitive_LineAdj,
       DXBC_InputPrimitive_TriangleAdj],
      !foreach(i, !range(1, 33),
        !cast<I32EnumAttrCase>("DXBC_InputPrimitive_Patch" # i)))> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_InputPrimitiveAttr :
    EnumAttr<DXBCDialect, DXBC_InputPrimitive, "input_primitive"> {
  let assemblyFormat = "$value";
}

def DXBC_InterpolationMode_Constant                    : I32EnumAttrCase<"constant",                    1>;
def DXBC_InterpolationMode_Linear                      : I32EnumAttrCase<"linear",                      2>;
def DXBC_InterpolationMode_LinearCentroid              : I32EnumAttrCase<"linearCentroid",              3>;
def DXBC_InterpolationMode_LinearNoPerspective         : I32EnumAttrCase<"linearNoPerspective",         4>;
def DXBC_InterpolationMode_LinearNoPerspectiveCentroid : I32EnumAttrCase<"linearNoPerspectiveCentroid", 5>;
def DXBC_InterpolationMode_LinearSample                : I32EnumAttrCase<"linearSample",                6>;
def DXBC_InterpolationMode_LinearNoPerspectiveSample   : I32EnumAttrCase<"linearNoPerspectiveSample",   7>;

def DXBC_InterpolationMode : I32EnumAttr<
    "InterpolationMode", "pixel shader interpolation mode", [
      DXBC_InterpolationMode_Constant,
      DXBC_InterpolationMode_Linear,
      DXBC_InterpolationMode_LinearCentroid,
      DXBC_InterpolationMode_LinearNoPerspective,
      DXBC_InterpolationMode_LinearNoPerspectiveCentroid,
      DXBC_InterpolationMode_LinearSample,
      DXBC_InterpolationMode_LinearNoPerspectiveSample
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_InterpolationModeAttr :
    EnumAttr<DXBCDialect, DXBC_InterpolationMode, "interpolation_mode"> {
  let assemblyFormat = "$value";
}

def DXBC_SystemValueName_Position                       : I32EnumAttrCase<"position",                       1>;
def DXBC_SystemValueName_ClipDistance                   : I32EnumAttrCase<"clipDistance",                   2>;
def DXBC_SystemValueName_CullDistance                   : I32EnumAttrCase<"cullDistance",                   3>;
def DXBC_SystemValueName_RenderTargetArrayIndex         : I32EnumAttrCase<"renderTargetArrayIndex",         4>;
def DXBC_SystemValueName_ViewportArrayIndex             : I32EnumAttrCase<"viewportArrayIndex",             5>;
def DXBC_SystemValueName_VertexId                       : I32EnumAttrCase<"vertexID",                       6>;
def DXBC_SystemValueName_PrimitiveId                    : I32EnumAttrCase<"primitiveID",                    7>;
def DXBC_SystemValueName_InstanceId                     : I32EnumAttrCase<"instanceID",                     8>;
def DXBC_SystemValueName_IsFrontFace                    : I32EnumAttrCase<"isFrontFace",                    9>;
def DXBC_SystemValueName_SampleIndex                    : I32EnumAttrCase<"sampleIndex",                   10>;
def DXBC_SystemValueName_FinalQuadUeq0EdgeTessFactor    : I32EnumAttrCase<"finalQuadUeq0EdgeTessFactor",   11>;
def DXBC_SystemValueName_FinalQuadVeq0EdgeTessFactor    : I32EnumAttrCase<"finalQuadVeq0EdgeTessFactor",   12>;
def DXBC_SystemValueName_FinalQuadUeq1EdgeTessFactor    : I32EnumAttrCase<"finalQuadUeq1EdgeTessFactor",   13>;
def DXBC_SystemValueName_FinalQuadVeq1EdgeTessFactor    : I32EnumAttrCase<"finalQuadVeq1EdgeTessFactor",   14>;
def DXBC_SystemValueName_FinalQuadUInsideTessFactor     : I32EnumAttrCase<"finalQuadUInsideTessFactor",    15>;
def DXBC_SystemValueName_FinalQuadVInsideTessFactor     : I32EnumAttrCase<"finalQuadVInsideTessFactor",    16>;
def DXBC_SystemValueName_FinalTriUeq0EdgeTessFactor     : I32EnumAttrCase<"finalTriUeq0EdgeTessFactor",    17>;
def DXBC_SystemValueName_FinalTriVeq0EdgeTessFactor     : I32EnumAttrCase<"finalTriVeq0EdgeTessFactor",    18>;
def DXBC_SystemValueName_FinalTriWeq0EdgeTessFactor     : I32EnumAttrCase<"finalTriWeq0EdgeTessFactor",    19>;
def DXBC_SystemValueName_FinalTriInsideTessFactor       : I32EnumAttrCase<"finalTriInsideTessFactor",      20>;
def DXBC_SystemValueName_FinalLineDetailTessFactor      : I32EnumAttrCase<"finalLineDetailTessFactor",     21>;
def DXBC_SystemValueName_FinalLineDensityTessFactor     : I32EnumAttrCase<"finalLineDensityTessFactor",    22>;
def DXBC_SystemValueName_Barycentrics                   : I32EnumAttrCase<"barycentrics",                  23>;
def DXBC_SystemValueName_ShadingRate                    : I32EnumAttrCase<"shadingRate",                   24>;
def DXBC_SystemValueName_CullPrimitive                  : I32EnumAttrCase<"cullPrimitive",                 25>;

def DXBC_SystemValueName : I32EnumAttr<
    "SystemValueName", "DXBC system interpreted/generated value name", [
      DXBC_SystemValueName_Position,
      DXBC_SystemValueName_ClipDistance,
      DXBC_SystemValueName_CullDistance,
      DXBC_SystemValueName_RenderTargetArrayIndex,
      DXBC_SystemValueName_ViewportArrayIndex,
      DXBC_SystemValueName_VertexId,
      DXBC_SystemValueName_PrimitiveId,
      DXBC_SystemValueName_InstanceId,
      DXBC_SystemValueName_IsFrontFace,
      DXBC_SystemValueName_SampleIndex,
      DXBC_SystemValueName_FinalQuadUeq0EdgeTessFactor,
      DXBC_SystemValueName_FinalQuadVeq0EdgeTessFactor,
      DXBC_SystemValueName_FinalQuadUeq1EdgeTessFactor,
      DXBC_SystemValueName_FinalQuadVeq1EdgeTessFactor,
      DXBC_SystemValueName_FinalQuadUInsideTessFactor,
      DXBC_SystemValueName_FinalQuadVInsideTessFactor,
      DXBC_SystemValueName_FinalTriUeq0EdgeTessFactor,
      DXBC_SystemValueName_FinalTriVeq0EdgeTessFactor,
      DXBC_SystemValueName_FinalTriWeq0EdgeTessFactor,
      DXBC_SystemValueName_FinalTriInsideTessFactor,
      DXBC_SystemValueName_FinalLineDetailTessFactor,
      DXBC_SystemValueName_FinalLineDensityTessFactor,
      DXBC_SystemValueName_Barycentrics,
      DXBC_SystemValueName_ShadingRate,
      DXBC_SystemValueName_CullPrimitive
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_SystemValueNameAttr :
    EnumAttr<DXBCDialect, DXBC_SystemValueName, "system_value_name"> {
  let assemblyFormat = "`<` $value `>`";
}

def DXBC_ResourceDimension_Buffer           : I32EnumAttrCase<"buffer",           1>;
def DXBC_ResourceDimension_Texture1D        : I32EnumAttrCase<"texture1d",        2>;
def DXBC_ResourceDimension_Texture2D        : I32EnumAttrCase<"texture2d",        3>;
def DXBC_ResourceDimension_Texture2DMS      : I32EnumAttrCase<"texture2dms",      4>;
def DXBC_ResourceDimension_Texture3D        : I32EnumAttrCase<"texture3d",        5>;
def DXBC_ResourceDimension_TextureCube      : I32EnumAttrCase<"texturecube",      6>;
def DXBC_ResourceDimension_Texture1DArray   : I32EnumAttrCase<"texture1darray",   7>;
def DXBC_ResourceDimension_Texture2DArray   : I32EnumAttrCase<"texture2darray",   8>;
def DXBC_ResourceDimension_Texture2DMSArray : I32EnumAttrCase<"texture2dmsarray", 9>;
def DXBC_ResourceDimension_TextureCubeArray : I32EnumAttrCase<"texturecubearray", 10>;

def DXBC_ResourceDimension : I32EnumAttr<
    "ResourceDimension", "input resource dimension", [
      DXBC_ResourceDimension_Buffer,
      DXBC_ResourceDimension_Texture1D,
      DXBC_ResourceDimension_Texture2D,
      DXBC_ResourceDimension_Texture2DMS,
      DXBC_ResourceDimension_Texture3D,
      DXBC_ResourceDimension_TextureCube,
      DXBC_ResourceDimension_Texture1DArray,
      DXBC_ResourceDimension_Texture2DArray,
      DXBC_ResourceDimension_Texture2DMSArray,
      DXBC_ResourceDimension_TextureCubeArray
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_ResourceDimensionAttr :
    EnumAttr<DXBCDialect, DXBC_ResourceDimension, "resource_dimension"> {
  let assemblyFormat = "$value";
}

// `float` is a reserved C++ keyword, so the symbolic (C++ enum case) names use
// PascalCase while the printable asm form stays lowercase.
def DXBC_ResourceReturnType_Unorm : I32EnumAttrCase<"Unorm", 1, "unorm">;
def DXBC_ResourceReturnType_Snorm : I32EnumAttrCase<"Snorm", 2, "snorm">;
def DXBC_ResourceReturnType_Sint  : I32EnumAttrCase<"Sint",  3, "sint">;
def DXBC_ResourceReturnType_Uint  : I32EnumAttrCase<"Uint",  4, "uint">;
def DXBC_ResourceReturnType_Float : I32EnumAttrCase<"Float", 5, "float">;

def DXBC_ResourceReturnType : I32EnumAttr<
    "ResourceReturnType", "input resource per-component return type", [
      DXBC_ResourceReturnType_Unorm,
      DXBC_ResourceReturnType_Snorm,
      DXBC_ResourceReturnType_Sint,
      DXBC_ResourceReturnType_Uint,
      DXBC_ResourceReturnType_Float
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_ResourceReturnTypeAttr :
    EnumAttr<DXBCDialect, DXBC_ResourceReturnType, "resource_return_type"> {
  let assemblyFormat = "$value";
}

def DXBC_ConstantBufferAccessPattern_ImmediateIndexed : I32EnumAttrCase<"immediateIndexed", 0>;
def DXBC_ConstantBufferAccessPattern_DynamicIndexed   : I32EnumAttrCase<"dynamicIndexed",   1>;

def DXBC_ConstantBufferAccessPattern : I32EnumAttr<
    "ConstantBufferAccessPattern", "constant buffer access pattern", [
      DXBC_ConstantBufferAccessPattern_ImmediateIndexed,
      DXBC_ConstantBufferAccessPattern_DynamicIndexed
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_ConstantBufferAccessPatternAttr :
    EnumAttr<DXBCDialect, DXBC_ConstantBufferAccessPattern,
             "constant_buffer_access_pattern"> {
  let assemblyFormat = "`<` $value `>`";
}

// `default` is a reserved C++ keyword, so the symbolic (C++ enum case) names
// use PascalCase while the printable asm form stays lowercase.
def DXBC_SamplerMode_Default    : I32EnumAttrCase<"Default",    0, "default">;
def DXBC_SamplerMode_Comparison : I32EnumAttrCase<"Comparison", 1, "comparison">;
def DXBC_SamplerMode_Mono       : I32EnumAttrCase<"Mono",       2, "mono">;

def DXBC_SamplerMode : I32EnumAttr<
    "SamplerMode", "sampler mode", [
      DXBC_SamplerMode_Default,
      DXBC_SamplerMode_Comparison,
      DXBC_SamplerMode_Mono
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_SamplerModeAttr :
    EnumAttr<DXBCDialect, DXBC_SamplerMode, "sampler_mode"> {
  let assemblyFormat = "$value";
}

//===----------------------------------------------------------------------===//
// DXBC attribute Constraints
//===----------------------------------------------------------------------===//

// This constraint does not treat the most significant bit as a sign bit,
// so it is safe to use on unsigned integer attributes.
def DXBC_UIntNonZero : AttrConstraint<
    CPred<"!::llvm::cast<::mlir::IntegerAttr>($_self).getValue().isZero()">,
    "whose value is non-zero">;

//===----------------------------------------------------------------------===//
// DXBC op definitions
//===----------------------------------------------------------------------===//

def DXBC_Operand : DXBC_Op<"operand"> {
  let summary = "defines an operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXBC_IndexType>:$operands,
                       I32Attr:$type,
                       I32Attr:$num_components,
		       OptionalAttr<I32Attr>:$one,
		       OptionalAttr<I32Attr>:$mask,
		       OptionalAttr<I32ElementsAttr>:$swizzle,
		       OptionalAttr<I32Attr>:$modifier,
		       OptionalAttr<I32Attr>:$min_precision,
		       OptionalAttr<I32Attr>:$non_uniform);
  let results = (outs DXBC_LegacyOperandType:$operand);
  let assemblyFormat = "$operands attr-dict";
}

def DXBC_OperandImm : DXBC_Op<"operand.imm"> {
  let summary = "defines an immediate operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32ElementsAttr, I64ElementsAttr]>:$imm);
  let results = (outs DXBC_LegacyOperandType:$operand);
  let assemblyFormat = "attr-dict";
}

def DXBC_IndexImm : DXBC_Op<"index.imm"> {
  let summary = "defines an immediate index";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32Attr, I64Attr]>:$imm);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "attr-dict";
}

def DXBC_IndexRel : DXBC_Op<"index.rel"> {
  let summary = "defines an operand index";
  let description = [{
    TODO
  }];

  let arguments = (ins DXBC_LegacyOperandType:$operand);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_IndexRelImm : DXBC_Op<"index.rel.imm"> {
  let summary = "defines an operand index with an immediate attribute";
  let description = [{
    TODO
  }];

  let arguments = (ins DXBC_LegacyOperandType:$operand, StrAttr:$op, I64Attr:$imm);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_Instruction : DXBC_Op<"instruction"> {
  let summary = "defines an instruction with zero or more operands";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXBC_LegacyOperandType>:$operands, StrAttr:$mnemonic);
  let results = (outs);
  let assemblyFormat = "$mnemonic $operands attr-dict";
}

def DXBC_Unknown : DXBC_Op<"unknown"> {
  let summary = "raw tokens fallback for an undecodable instruction";
  let description = [{
    The `dxbc.unknown` operation represents one instruction whose raw
    tokens could not be decoded into a structured op - unknown opcode,
    undecodable payload, length mismatch, truncated tail, etc. It acts
    as a disassembler-style fallback so the surrounding well-formed
    instructions still appear in IR.

    Example:

    ```mlir
    dxbc.unknown <tokens = [0x030000FF, 0xDEADBEEF, 0x12345678]>
    ```
  }];

  let arguments = (ins DenseI32ArrayAttr:$tokens);
  let results = (outs);
  let hasVerifier = 1;
  let assemblyFormat = "custom<HexTokens>($tokens) attr-dict";
}

def DXBC_InlineOperandType_Temp                          : I32EnumAttrCase<"temp",                                  0>;
def DXBC_InlineOperandType_Input                         : I32EnumAttrCase<"input",                                 1>;
def DXBC_InlineOperandType_Output                        : I32EnumAttrCase<"output",                                2>;
def DXBC_InlineOperandType_IndexableTemp                 : I32EnumAttrCase<"indexable_temp",                        3>;
def DXBC_InlineOperandType_Immediate32                   : I32EnumAttrCase<"immediate32",                           4>;
def DXBC_InlineOperandType_Immediate64                   : I32EnumAttrCase<"immediate64",                           5>;
def DXBC_InlineOperandType_Sampler                       : I32EnumAttrCase<"sampler",                               6>;
def DXBC_InlineOperandType_Resource                      : I32EnumAttrCase<"resource",                              7>;
def DXBC_InlineOperandType_ConstantBuffer                : I32EnumAttrCase<"constant_buffer",                       8>;
def DXBC_InlineOperandType_ImmediateConstantBuffer       : I32EnumAttrCase<"immediate_constant_buffer",             9>;
def DXBC_InlineOperandType_Label                         : I32EnumAttrCase<"label",                                10>;
def DXBC_InlineOperandType_InputPrimitiveId              : I32EnumAttrCase<"input_primitive_id",                   11>;
def DXBC_InlineOperandType_OutputDepth                   : I32EnumAttrCase<"output_depth",                         12>;
def DXBC_InlineOperandType_Null                          : I32EnumAttrCase<"null",                                 13>;
def DXBC_InlineOperandType_Rasterizer                    : I32EnumAttrCase<"rasterizer",                           14>;
def DXBC_InlineOperandType_OutputCoverageMask            : I32EnumAttrCase<"output_coverage_mask",                 15>;
def DXBC_InlineOperandType_Stream                        : I32EnumAttrCase<"stream",                               16>;
def DXBC_InlineOperandType_FunctionBody                  : I32EnumAttrCase<"function_body",                        17>;
def DXBC_InlineOperandType_FunctionTable                 : I32EnumAttrCase<"function_table",                       18>;
def DXBC_InlineOperandType_Interface                     : I32EnumAttrCase<"interface",                            19>;
def DXBC_InlineOperandType_FunctionInput                 : I32EnumAttrCase<"function_input",                       20>;
def DXBC_InlineOperandType_FunctionOutput                : I32EnumAttrCase<"function_output",                      21>;
def DXBC_InlineOperandType_OutputControlPointId          : I32EnumAttrCase<"output_control_point_id",              22>;
def DXBC_InlineOperandType_InputForkInstanceId           : I32EnumAttrCase<"input_fork_instance_id",               23>;
def DXBC_InlineOperandType_InputJoinInstanceId           : I32EnumAttrCase<"input_join_instance_id",               24>;
def DXBC_InlineOperandType_InputControlPoint             : I32EnumAttrCase<"input_control_point",                  25>;
def DXBC_InlineOperandType_OutputControlPoint            : I32EnumAttrCase<"output_control_point",                 26>;
def DXBC_InlineOperandType_InputPatchConstant            : I32EnumAttrCase<"input_patch_constant",                 27>;
def DXBC_InlineOperandType_InputDomainPoint              : I32EnumAttrCase<"input_domain_point",                   28>;
def DXBC_InlineOperandType_ThisPointer                   : I32EnumAttrCase<"this_pointer",                         29>;
def DXBC_InlineOperandType_Uav                           : I32EnumAttrCase<"uav",                                  30>;
def DXBC_InlineOperandType_ThreadGroupSharedMemory       : I32EnumAttrCase<"thread_group_shared_memory",           31>;
def DXBC_InlineOperandType_InputThreadId                 : I32EnumAttrCase<"input_thread_id",                      32>;
def DXBC_InlineOperandType_InputThreadGroupId            : I32EnumAttrCase<"input_thread_group_id",                33>;
def DXBC_InlineOperandType_InputThreadIdInGroup          : I32EnumAttrCase<"input_thread_id_in_group",             34>;
def DXBC_InlineOperandType_InputCoverageMask             : I32EnumAttrCase<"input_coverage_mask",                  35>;
def DXBC_InlineOperandType_InputThreadIdInGroupFlattened : I32EnumAttrCase<"input_thread_id_in_group_flattened",   36>;
def DXBC_InlineOperandType_InputGsInstanceId             : I32EnumAttrCase<"input_gs_instance_id",                 37>;
def DXBC_InlineOperandType_OutputDepthGe                 : I32EnumAttrCase<"output_depth_ge",                      38>;
def DXBC_InlineOperandType_OutputDepthLe                 : I32EnumAttrCase<"output_depth_le",                      39>;
def DXBC_InlineOperandType_CycleCounter                  : I32EnumAttrCase<"cycle_counter",                        40>;
def DXBC_InlineOperandType_OutputStencilRef              : I32EnumAttrCase<"output_stencil_ref",                   41>;
def DXBC_InlineOperandType_InnerCoverage                 : I32EnumAttrCase<"inner_coverage",                       42>;

def DXBC_InlineOperandType : I32EnumAttr<
    "InlineOperandType", "operand type", [
      DXBC_InlineOperandType_Temp,
      DXBC_InlineOperandType_Input,
      DXBC_InlineOperandType_Output,
      DXBC_InlineOperandType_IndexableTemp,
      DXBC_InlineOperandType_Immediate32,
      DXBC_InlineOperandType_Immediate64,
      DXBC_InlineOperandType_Sampler,
      DXBC_InlineOperandType_Resource,
      DXBC_InlineOperandType_ConstantBuffer,
      DXBC_InlineOperandType_ImmediateConstantBuffer,
      DXBC_InlineOperandType_Label,
      DXBC_InlineOperandType_InputPrimitiveId,
      DXBC_InlineOperandType_OutputDepth,
      DXBC_InlineOperandType_Null,
      DXBC_InlineOperandType_Rasterizer,
      DXBC_InlineOperandType_OutputCoverageMask,
      DXBC_InlineOperandType_Stream,
      DXBC_InlineOperandType_FunctionBody,
      DXBC_InlineOperandType_FunctionTable,
      DXBC_InlineOperandType_Interface,
      DXBC_InlineOperandType_FunctionInput,
      DXBC_InlineOperandType_FunctionOutput,
      DXBC_InlineOperandType_OutputControlPointId,
      DXBC_InlineOperandType_InputForkInstanceId,
      DXBC_InlineOperandType_InputJoinInstanceId,
      DXBC_InlineOperandType_InputControlPoint,
      DXBC_InlineOperandType_OutputControlPoint,
      DXBC_InlineOperandType_InputPatchConstant,
      DXBC_InlineOperandType_InputDomainPoint,
      DXBC_InlineOperandType_ThisPointer,
      DXBC_InlineOperandType_Uav,
      DXBC_InlineOperandType_ThreadGroupSharedMemory,
      DXBC_InlineOperandType_InputThreadId,
      DXBC_InlineOperandType_InputThreadGroupId,
      DXBC_InlineOperandType_InputThreadIdInGroup,
      DXBC_InlineOperandType_InputCoverageMask,
      DXBC_InlineOperandType_InputThreadIdInGroupFlattened,
      DXBC_InlineOperandType_InputGsInstanceId,
      DXBC_InlineOperandType_OutputDepthGe,
      DXBC_InlineOperandType_OutputDepthLe,
      DXBC_InlineOperandType_CycleCounter,
      DXBC_InlineOperandType_OutputStencilRef,
      DXBC_InlineOperandType_InnerCoverage
    ]> {
  let cppNamespace = "::mlir::dxbc";
  let genSpecializedAttr = 0;
}

def DXBC_InlineOperandAttr : AttrDef<DXBCDialect, "InlineOperand"> {
  let mnemonic = "inline_operand";
  let summary = "inline operand of an instruction";
  let description = [{
    The `#dxbc.inline_operand` attribute carries a fully decoded operand token

    Example:

    ```mlir
    dxbc.dcl_output <type = output, components = 4, mask = <x, y, z, w>, index = [0]>
    dxbc.dcl_output <type = output_depth, components = 1>
    ```
  }];
  let parameters = (ins
      EnumParameter<DXBC_InlineOperandType>:$type,
      "uint32_t":$components,
      OptionalParameter<"::mlir::dxbc::ComponentMaskAttr">:$mask,
      OptionalParameter<"::mlir::DenseI64ArrayAttr">:$index);
  let assemblyFormat = "`<` struct(params) `>`";
}

def DXBC_DclGlobalFlags : DXBC_Op<"dcl_global_flags"> {
  let summary = "declares global shader flags";
  let description = [{
    The `dxbc.dcl_global_flags` operation declares a set of flags that
    affect the entire shader.

    Example:

    ```mlir
    dxbc.dcl_global_flags <refactoringAllowed|forceEarlyDepthStencil>
    ```
  }];
  let arguments = (ins DXBC_GlobalFlagsAttr:$flags);
  let assemblyFormat = "$flags attr-dict";
}

def DXBC_DclTemps : DXBC_Op<"dcl_temps"> {
  let summary = "declares the number of temporary registers";
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntPositive, IntMaxValue<4096>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXBC_DclInputControlPointCount :
    DXBC_Op<"dcl_input_control_point_count"> {
  let summary = "declares the hull shader input control point count";
  let description = [{
    The `dxbc.dcl_input_control_point_count` operation declares the number of
    input control points for the hull shader.

    The count must be in [1, 32].

    Example:

    ```mlir
    dxbc.dcl_input_control_point_count 3
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntPositive, IntMaxValue<32>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXBC_DclOutputControlPointCount :
    DXBC_Op<"dcl_output_control_point_count"> {
  let summary = "declares the hull shader output control point count";
  let description = [{
    The `dxbc.dcl_output_control_point_count` operation declares the number
    of output control points for the hull shader.

    The count must be in [0, 32].

    Example:

    ```mlir
    dxbc.dcl_output_control_point_count 4
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntNonNegative, IntMaxValue<32>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXBC_DclTessellatorDomain : DXBC_Op<"dcl_tessellator_domain"> {
  let summary = "declares the tessellator domain";
  let description = [{
    The `dxbc.dcl_tessellator_domain` operation declares the tessellator
    domain.

    Example:

    ```mlir
    dxbc.dcl_tessellator_domain domain_quad
    ```
  }];

  let arguments = (ins DXBC_TessellatorDomainAttr:$domain);
  let assemblyFormat = "$domain attr-dict";
}

def DXBC_DclTessellatorOutputPrimitive
    : DXBC_Op<"dcl_tessellator_output_primitive"> {
  let summary = "declares the tessellator output primitive type";
  let description = [{
    The `dxbc.dcl_tessellator_output_primitive` operation declares the
    tessellator output primitive type.

    Example:

    ```mlir
    dxbc.dcl_tessellator_output_primitive output_triangle_cw
    ```
  }];
  let arguments = (ins DXBC_TessellatorOutputPrimitiveTypeAttr:$type);
  let assemblyFormat = "$type attr-dict";
}

def DXBC_DclOutputTopology : DXBC_Op<"dcl_output_topology"> {
  let summary = "declare what primitive topology the shader generates as output";
  let description = [{
    The `dxbc.dcl_output_topology` operation declares the primitive topology
    that the shader generates as output.

    Example:

    ```mlir
    dxbc.dcl_output_topology trianglestrip
    ```
  }];
  let arguments = (ins DXBC_OutputPrimitiveTopologyAttr:$topology);
  let assemblyFormat = "$topology attr-dict";
}

def DXBC_DclTessellatorPartitioning
    : DXBC_Op<"dcl_tessellator_partitioning"> {
  let summary = "declares the tessellator partitioning mode";
  let description = [{
    The `dxbc.dcl_tessellator_partitioning` operation declares the
    tessellator partitioning mode in a Hull Shader declaration section.

    Example:

    ```mlir
    dxbc.dcl_tessellator_partitioning partitioning_integer
    ```
  }];
  let arguments = (ins DXBC_TessellatorPartitioningModeAttr:$partitioningMode);
  let assemblyFormat = "$partitioningMode attr-dict";
}

def DXBC_DclInputPrimitive : DXBC_Op<"dcl_input_primitive"> {
  let summary = "declares the shader input primitive type";
  let description = [{
    The `dxbc.dcl_input_primitive` operation declares the input primitive
    type that the shader is invoked with.

    Example:

    ```mlir
    dxbc.dcl_input_primitive triangle
    ```
  }];
  let arguments = (ins DXBC_InputPrimitiveAttr:$type);
  let assemblyFormat = "$type attr-dict";
}

def DXBC_DclInputPs : DXBC_Op<"dcl_input_ps"> {
  let summary = "declares a pixel shader input";
  let description = [{
    The `dxbc.dcl_input_ps` operation declares a pixel shader input
    with the given attribute interpolation mode.

    Example:

    ```mlir
    dxbc.dcl_input_ps linear %v0
    ```
  }];
  let arguments = (ins DXBC_InterpolationModeAttr:$mode,
                       DXBC_LegacyOperandType:$operand);
  let assemblyFormat = "$mode $operand attr-dict";
}

def DXBC_DclInputPsSiv : DXBC_Op<"dcl_input_ps_siv"> {
  let summary = "declares a pixel shader system-interpreted input";
  let description = [{
    The `dxbc.dcl_input_ps_siv` operation declares a pixel shader input
    that receives a System Interpreted Value, with the given attribute
    interpolation mode.

    Example:

    ```mlir
    dxbc.dcl_input_ps_siv linear %v0, <position>
    ```
  }];
  let arguments = (ins DXBC_InterpolationModeAttr:$mode,
                       DXBC_LegacyOperandType:$operand,
                       DXBC_SystemValueNameAttr:$name);
  let assemblyFormat = "$mode $operand `,` $name attr-dict";
}

def DXBC_DclInputPsSgv : DXBC_Op<"dcl_input_ps_sgv"> {
  let summary = "declares a pixel shader system-generated input";
  let description = [{
    The `dxbc.dcl_input_ps_sgv` operation declares a pixel shader input
    that receives a System Generated Value.

    Example:

    ```mlir
    dxbc.dcl_input_ps_sgv %v0, <sampleIndex>
    ```
  }];
  let arguments = (ins DXBC_LegacyOperandType:$operand,
                       DXBC_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXBC_DclInput : DXBC_Op<"dcl_input"> {
  let summary = "declares a shader input register";
  let description = [{
    The `dxbc.dcl_input` operation declares a shader input register.

    The register operand can be either an indexed input register
    or a special scalar input.

    Example:

    ```mlir
    dxbc.dcl_input <type = input, components = 4, mask = <x>, index = [0]>
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_DclOutput : DXBC_Op<"dcl_output"> {
  let summary = "declares a shader output register";
  let description = [{
    The `dxbc.dcl_output` operation declares a shader output register.

    The register operand can be either an indexed output register
    or a special scalar output.

    Example:

    ```mlir
    dxbc.dcl_output <type = output, components = 4, mask = <x, y, z, w>, index = [0]>
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_DclIndexRange : DXBC_Op<"dcl_index_range"> {
  let summary = "declares a range of input or output registers to be indexed";
  let description = [{
    The `dxbc.dcl_index_range` operation declares a range of input or output
    registers to be indexed.

    Example:

    ```mlir
    dxbc.dcl_index_range <type = output, components = 4, mask = <x>, index = [0]>, 4
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       ConfinedAttr<I32Attr, [IntPositive]>:$count);
  let assemblyFormat = "$operand `,` $count attr-dict";
  let hasVerifier = 1;
}

def DXBC_DclInputSgv : DXBC_Op<"dcl_input_sgv"> {
  let summary = "declares an input register as a System Generated Value";
  let description = [{
    The `dxbc.dcl_input_sgv` operation declares an input register
    that expects a System Generated Value to be provided
    from the upstream stage.

    Example:

    ```mlir
    dxbc.dcl_input_sgv <type = input, components = 4, mask = <x>, index = [0]>, <vertexID>
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       DXBC_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXBC_DclInputSiv : DXBC_Op<"dcl_input_siv"> {
  let summary = "declares an input register as a System Interpreted Value";
  let description = [{
    The `dxbc.dcl_input_siv` operation declares an input register
    that expects a System Interpreted Value to be provided
    from the upstream Stage.

    Example:

    ```mlir
    dxbc.dcl_input_siv <type = input, components = 4, mask = <x, y, z, w>, index = [0]>, <position>
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       DXBC_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXBC_DclOutputSgv : DXBC_Op<"dcl_output_sgv"> {
  let summary = "declares an output as a System Generated Value";
  let description = [{
    The `dxbc.dcl_output_sgv` operation declares an output to be written
    that represents a System Generated Value.

    Example:

    ```mlir
    dxbc.dcl_output_sgv <type = output, components = 1, mask = <x>, index = [4]>, <primitiveID>
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       DXBC_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXBC_DclOutputSiv : DXBC_Op<"dcl_output_siv"> {
  let summary = "declares an output as a System Interpreted Value";
  let description = [{
    The `dxbc.dcl_output_siv` operation declares an output to be written
    that represents a System Interpreted Value.
    
    Example:

    ```mlir
    dxbc.dcl_output_siv <type = output, components = 4, mask = <x, y, z, w>, index = [3]>, <position>
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       DXBC_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXBC_DclHsMaxTessFactor : DXBC_Op<"dcl_hs_max_tessfactor"> {
  let summary = "declares the MaxTessFactor for the patch";
  let description = [{
    The `dxbc.dcl_hs_max_tessfactor` operation declares the MaxTessFactor
    for the patch.

    The `$max_tessfactor` is a float32 value in the range [1.0, 64.0].

    Example:

    ```mlir
    dxbc.dcl_hs_max_tessfactor 4.200000e+01
    ```
  }];
  let arguments = (ins F32Attr:$max_tessfactor);
  let assemblyFormat = "$max_tessfactor attr-dict";
  let hasVerifier = 1;
}

def DXBC_DclHsJoinPhaseInstanceCount :
    DXBC_Op<"dcl_hs_join_phase_instance_count"> {
  let summary = "declares the Join Phase instance count";
  let description = [{
    The `dxbc.dcl_hs_join_phase_instance_count` operation declares
    the Join Phase instance count.

    The `$count` must be a positive 32-bit unsigned integer in the range [1, 2^32 - 1].

    Example:

    ```mlir
    dxbc.dcl_hs_join_phase_instance_count 42
    ```
  }];
  let arguments = (ins ConfinedAttr<UI32Attr, [DXBC_UIntNonZero]>:$count);
  let assemblyFormat = "$count attr-dict";
}

def DXBC_DclHsForkPhaseInstanceCount :
    DXBC_Op<"dcl_hs_fork_phase_instance_count"> {
  let summary = "declares the Fork Phase instance count";
  let description = [{
    The `dxbc.dcl_hs_fork_phase_instance_count` operation declares
    the Fork Phase instance count.

    The `$count` must be a positive 32-bit unsigned integer in the range [1, 2^32 - 1].

    Example:

    ```mlir
    dxbc.dcl_hs_fork_phase_instance_count 42
    ```
  }];
  let arguments = (ins ConfinedAttr<UI32Attr, [DXBC_UIntNonZero]>:$count);
  let assemblyFormat = "$count attr-dict";
}

def DXBC_DclGsInstanceCount : DXBC_Op<"dcl_gs_instance_count"> {
  let summary = "declares instance count for the geometry shader";
  let description = [{
    The `dxbc.dcl_gs_instance_count` operation declares declares instance count
    for the geometry shader.

    The `$count` must be in [1, 32].

    Example:

    ```mlir
    dxbc.dcl_gs_instance_count 4
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntPositive, IntMaxValue<32>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXBC_DclMaxOutputVertexCount :
    DXBC_Op<"dcl_max_output_vertex_count"> {
  let summary = "declares the geometry shader maximum output vertex count";
  let description = [{
    The `dxbc.dcl_max_output_vertex_count` operation declares the maximum
    number of vertices that a single invocation of the geometry shader will
    emit.

    The count must be in [1, 1024].

    Example:

    ```mlir
    dxbc.dcl_max_output_vertex_count 42
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntPositive, IntMaxValue<1024>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXBC_DclTgsmRaw : DXBC_Op<"dcl_tgsm_raw"> {
  let summary = "declares a reference to a Thread Group Shared Memory region";
  let description = [{
    The `dxbc.dcl_tgsm_raw` operation declares a reference to a Thread Group Shared Memory region.

    The `$operand` is the `g#` register being declared.
    The `$byte_count$ is the size of the block of untyped shared memory;
    must be a multiple of 4.

    Example:

    ```mlir
    dxbc.dcl_tgsm_raw <type = thread_group_shared_memory, components = 0, index = [0]>, 1024
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       ConfinedAttr<I32Attr,
                           [IntPositive, IntMaxValue<32768>]>:$byte_count);
  let assemblyFormat = "$operand `,` $byte_count attr-dict";
  let hasVerifier = 1;
}

def DXBC_DclTgsmStructured : DXBC_Op<"dcl_tgsm_structured"> {
  let summary = "declares a reference to a Thread Group Shared Memory region";
  let description = [{
    The `dxbc.dcl_tgsm_structured` operation declares a reference to a Thread Group Shared Memory region.
    The memory is viewed as an array of structures.

    The `$operand` is the `g#` register being declared.
    The `$struct_byte_stride` is a uint in bytes and must be a multiple of 4.
    The `$struct_count` is the number of structures.
    The total size `$struct_byte_stride * $struct_count` must not exceed
    32 KB.

    Example:

    ```mlir
    dxbc.dcl_tgsm_structured <type = thread_group_shared_memory, components = 0, index = [0]>, 16, 64
    ```
  }];
  let arguments = (ins DXBC_InlineOperandAttr:$operand,
                       ConfinedAttr<I32Attr,
                           [IntPositive, IntMaxValue<32768>]>:$struct_byte_stride,
                       ConfinedAttr<I32Attr,
                           [IntPositive, IntMaxValue<8192>]>:$struct_count);
  let assemblyFormat =
      "$operand `,` $struct_byte_stride `,` $struct_count attr-dict";
  let hasVerifier = 1;
}

def DXBC_DclConstantBuffer : DXBC_Op<"dcl_constant_buffer"> {
  let summary = "declares a constant buffer";
  let description = [{
    The `dxbc.dcl_constant_buffer` operation declares a constant buffer
    with its access pattern.

    Examples:

    ```mlir
    dxbc.dcl_constant_buffer <id = 0, size = 1>, <immediateIndexed>
    dxbc.dcl_constant_buffer <id = 0, size = 4, lbound = 0, ubound = 3, space = 1>, <dynamicIndexed>
    ```
  }];
  let arguments = (ins
      I32Attr:$id,
      I32Attr:$size,
      OptionalAttr<I32Attr>:$lbound,
      OptionalAttr<I32Attr>:$ubound,
      OptionalAttr<I32Attr>:$space,
      DXBC_ConstantBufferAccessPatternAttr:$access_pattern);
  let assemblyFormat = [{
    ` ` `<` `id` `=` $id `,` `size` `=` $size
            (`,` `lbound` `=` $lbound^ `,` `ubound` `=` $ubound
             `,` `space` `=` $space)?
    `>` `,` $access_pattern attr-dict
  }];
  let hasVerifier = 1;
}

def DXBC_DclSampler : DXBC_Op<"dcl_sampler"> {
  let summary = "declares a sampler that will be referenced in the shader";
  let description = [{
    The `dxbc.dcl_sampler` operation declares sampler that will be referenced in the shader.

    Examples:

    ```mlir
    dxbc.dcl_sampler <id = 3, mode = default>
    dxbc.dcl_sampler <id = 0, mode = comparison, lbound = 0, ubound = 3, space = 1>
    ```
  }];

  let arguments = (ins
      I32Attr:$id,
      DXBC_SamplerModeAttr:$mode,
      OptionalAttr<I32Attr>:$lbound,
      OptionalAttr<I32Attr>:$ubound,
      OptionalAttr<I32Attr>:$space);
  let assemblyFormat = [{
    ` ` `<` `id` `=` $id `,` `mode` `=` $mode
            (`,` `lbound` `=` $lbound^ `,` `ubound` `=` $ubound
             `,` `space` `=` $space)?
    `>` attr-dict
  }];
  let hasVerifier = 1;
}

def DXBC_DclStream : DXBC_Op<"dcl_stream"> {
  let summary = "declares a geometry shader (GS) output stream";
  let description = [{
    The `dxbc.dcl_stream` operation declares a geometry shader (GS) output stream.

    The `$index` must be in the range [0, 3].

    Example:

    ```mlir
    dxbc.dcl_stream 0
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntNonNegative, IntMaxValue<3>]>:$index);
  let assemblyFormat = [{ $index attr-dict }];
}

def DXBC_DclResource : DXBC_Op<"dcl_resource"> {
  let summary = "declares a shader input resource bound to a register";
  let description = [{
    The `dxbc.dcl_resource` operation declares a shader input resource
    bound to a register.

    Example:

    ```mlir
    dxbc.dcl_resource <id = 0>, <dim = buffer>,
        <x = unorm, y = snorm, z = sint, w = uint>
    dxbc.dcl_resource <id = 5>, <dim = texture2dms, sample_count = 4>,
        <x = float, y = float, z = float, w = float>
    dxbc.dcl_resource <id = 0, lbound = 0, ubound = 3, space = 1>,
        <dim = texture3d>, <x = float, y = float, z = float, w = float>
    ```
  }];

  let arguments = (ins
      I32Attr:$id,
      DXBC_ResourceDimensionAttr:$dim,
      DXBC_ResourceReturnTypeAttr:$x,
      DXBC_ResourceReturnTypeAttr:$y,
      DXBC_ResourceReturnTypeAttr:$z,
      DXBC_ResourceReturnTypeAttr:$w,
      OptionalAttr<ConfinedAttr<I32Attr,
          [IntPositive, IntMaxValue<127>]>>:$sample_count,
      OptionalAttr<I32Attr>:$lbound,
      OptionalAttr<I32Attr>:$ubound,
      OptionalAttr<I32Attr>:$space);
  let assemblyFormat = [{
    ` ` `<` `id` `=` $id
            (`,` `lbound` `=` $lbound^ `,` `ubound` `=` $ubound
             `,` `space` `=` $space)? `>` `,`
    `<` `dim` `=` $dim
         (`,` `sample_count` `=` $sample_count^)? `>` `,`
    `<` `x` `=` $x `,` `y` `=` $y `,` `z` `=` $z `,` `w` `=` $w `>`
    attr-dict
  }];
  let hasVerifier = 1;
}

def DXBC_DclResourceStructured : DXBC_Op<"dcl_resource_structured"> {
  let summary = "declares a structured buffer shader input resource bound to a register";
  let description = [{
    The `dxbc.dcl_resource_structured` operation declares a structured
    buffer shader input resource bound to a register.

    Example:

    ```mlir
    dxbc.dcl_resource_structured <id = 3, struct_byte_stride = 16>
    dxbc.dcl_resource_structured
        <id = 0, struct_byte_stride = 32, lbound = 0, ubound = 3, space = 1>
    ```
  }];

  let arguments = (ins
      I32Attr:$id,
      ConfinedAttr<I32Attr, [IntPositive]>:$struct_byte_stride,
      OptionalAttr<I32Attr>:$lbound,
      OptionalAttr<I32Attr>:$ubound,
      OptionalAttr<I32Attr>:$space);
  let assemblyFormat = [{
    ` ` `<` `id` `=` $id `,` `struct_byte_stride` `=` $struct_byte_stride
            (`,` `lbound` `=` $lbound^ `,` `ubound` `=` $ubound
             `,` `space` `=` $space)? `>`
    attr-dict
  }];
  let hasVerifier = 1;
}

def DXBC_DclResourceRaw : DXBC_Op<"dcl_resource_raw"> {
  let summary = "declares a raw buffer shader input resource bound to a register";
  let description = [{
    The `dxbc.dcl_resource_raw` operation declares a raw buffer shader
    input resource bound to a register.

    Example:

    ```mlir
    dxbc.dcl_resource_raw <id = 3>
    dxbc.dcl_resource_raw <id = 0, lbound = 0, ubound = 3, space = 1>
    ```
  }];

  let arguments = (ins
      I32Attr:$id,
      OptionalAttr<I32Attr>:$lbound,
      OptionalAttr<I32Attr>:$ubound,
      OptionalAttr<I32Attr>:$space);
  let assemblyFormat = [{
    ` ` `<` `id` `=` $id
            (`,` `lbound` `=` $lbound^ `,` `ubound` `=` $ubound
             `,` `space` `=` $space)? `>`
    attr-dict
  }];
  let hasVerifier = 1;
}

def DXBC_DclIndexableTemp : DXBC_Op<"dcl_indexable_temp"> {
  let summary = "declares a temporary register array";
  let description = [{
    The `dxbc.dcl_indexable_temp` operation declares a temporary register array.
    Each temporary register array to be used in the shader must be declared.
    - `$id` identifies the `x#` register being declared.
    - `$size` is an integer that defines how many elements are in
    this array of 32-bit 4-component indexable temp storage that is being declared.
    - `$num_components` is the number of components (1..4) used per element;
    omitted from the textual form when equal to 4.

    Example:

    ```mlir
    dxbc.dcl_indexable_temp x<0>[1], 1
    dxbc.dcl_indexable_temp x<1>[23], 2
    dxbc.dcl_indexable_temp x<7>[4096]
    ```
  }];
  let arguments = (ins
      I32Attr:$id,
      ConfinedAttr<I32Attr, [IntPositive, IntMaxValue<4096>]>:$size,
      DefaultValuedAttr<
          ConfinedAttr<I32Attr, [IntPositive, IntMaxValue<4>]>,
          "4">:$num_components);
  let assemblyFormat = "`x` `<` $id `>` `` `[` $size `]` (`,` $num_components^)? attr-dict";
}

def DXBC_DclThreadGroup : DXBC_Op<"dcl_thread_group"> {
  let summary = "declares compute shader thread group dimensions";
  let description = [{
    The `dxbc.dcl_thread_group` operation declares the `$x`, `$y` and `$z`
    dimensions of a compute shader thread group.

    The product `$x` * `$y` * `$z` must not exceed 1024.

    Example:

    ```mlir
    dxbc.dcl_thread_group <x = 1, y = 1, z = 1>
    ```
  }];
  let arguments = (ins
      ConfinedAttr<I32Attr, [IntPositive, IntMaxValue<1024>]>:$x,
      ConfinedAttr<I32Attr, [IntPositive, IntMaxValue<1024>]>:$y,
      ConfinedAttr<I32Attr, [IntPositive, IntMaxValue<64>]>:$z);
  let assemblyFormat = "` ` `<` `x` `=` $x `,` `y` `=` $y `,` `z` `=` $z `>` attr-dict";
  let hasVerifier = 1;
}

#endif // DXBC_OPS
