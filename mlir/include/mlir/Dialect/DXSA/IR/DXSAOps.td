//===- DXSAOps.td - DXSA operations definition -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef DXSA_OPS
#define DXSA_OPS

include "mlir/Dialect/DXSA/IR/DXSADialect.td"
include "mlir/Dialect/DXSA/IR/DXSATypes.td"
include "mlir/IR/EnumAttr.td"

//===----------------------------------------------------------------------===//
// DXSA enum definitions
//===----------------------------------------------------------------------===//

// Global shader flags for 'dcl_globalFlags' instruction.
def DXSA_GlobalFlags_RefactoringAllowed            : I32BitEnumAttrCaseBit<"refactoringAllowed",            0>;
def DXSA_GlobalFlags_EnableDoublePrecisionFloatOps : I32BitEnumAttrCaseBit<"enableDoublePrecisionFloatOps", 1>;
def DXSA_GlobalFlags_ForceEarlyDepthStencil        : I32BitEnumAttrCaseBit<"forceEarlyDepthStencil",        2>;
def DXSA_GlobalFlags_EnableRawAndStructuredBuffers : I32BitEnumAttrCaseBit<"enableRawAndStructuredBuffers", 3>;
def DXSA_GlobalFlags_SkipOptimization              : I32BitEnumAttrCaseBit<"skipOptimization",              4>;
def DXSA_GlobalFlags_EnableMinimumPrecision        : I32BitEnumAttrCaseBit<"enableMinimumPrecision",        5>;
def DXSA_GlobalFlags_EnableDoubleExtensions        : I32BitEnumAttrCaseBit<"enableDoubleExtensions",        6>;
def DXSA_GlobalFlags_EnableShaderExtensions        : I32BitEnumAttrCaseBit<"enableShaderExtensions",        7>;
def DXSA_GlobalFlags_AllResourcesBound             : I32BitEnumAttrCaseBit<"allResourcesBound",             8>;

def DXSA_GlobalFlags : I32BitEnumAttr<
    "GlobalFlags", "global shader flags", [
      DXSA_GlobalFlags_RefactoringAllowed,
      DXSA_GlobalFlags_EnableDoublePrecisionFloatOps,
      DXSA_GlobalFlags_ForceEarlyDepthStencil,
      DXSA_GlobalFlags_EnableRawAndStructuredBuffers,
      DXSA_GlobalFlags_SkipOptimization,
      DXSA_GlobalFlags_EnableMinimumPrecision,
      DXSA_GlobalFlags_EnableDoubleExtensions,
      DXSA_GlobalFlags_EnableShaderExtensions,
      DXSA_GlobalFlags_AllResourcesBound
    ]> {
  let separator = "|";
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
  let printBitEnumPrimaryGroups = 1;
}

def DXSA_GlobalFlagsAttr :
    EnumAttr<DXSADialect, DXSA_GlobalFlags, "global_flags"> {
  let assemblyFormat = "`<` $value `>`";
}

def DXSA_TessellatorDomain_Isoline : I32EnumAttrCase<"domain_isoline", 1>;
def DXSA_TessellatorDomain_Tri     : I32EnumAttrCase<"domain_tri",     2>;
def DXSA_TessellatorDomain_Quad    : I32EnumAttrCase<"domain_quad",    3>;

def DXSA_TessellatorDomain : I32EnumAttr<
    "TessellatorDomain", "tessellator domain", [
      DXSA_TessellatorDomain_Isoline,
      DXSA_TessellatorDomain_Tri,
      DXSA_TessellatorDomain_Quad
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_TessellatorDomainAttr :
    EnumAttr<DXSADialect, DXSA_TessellatorDomain, "tessellator_domain"> {
  let assemblyFormat = "$value";
}

def DXSA_TessellatorOutputPrimitiveType_OutputPoint       : I32EnumAttrCase<"output_point",        1>;
def DXSA_TessellatorOutputPrimitiveType_OutputLine        : I32EnumAttrCase<"output_line",         2>;
def DXSA_TessellatorOutputPrimitiveType_OutputTriangleCw  : I32EnumAttrCase<"output_triangle_cw",  3>;
def DXSA_TessellatorOutputPrimitiveType_OutputTriangleCcw : I32EnumAttrCase<"output_triangle_ccw", 4>;

def DXSA_TessellatorOutputPrimitiveType : I32EnumAttr<
    "TessellatorOutputPrimitiveType", "tessellator output primitive type", [
      DXSA_TessellatorOutputPrimitiveType_OutputPoint,
      DXSA_TessellatorOutputPrimitiveType_OutputLine,
      DXSA_TessellatorOutputPrimitiveType_OutputTriangleCw,
      DXSA_TessellatorOutputPrimitiveType_OutputTriangleCcw
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_TessellatorOutputPrimitiveTypeAttr :
    EnumAttr<DXSADialect, DXSA_TessellatorOutputPrimitiveType,
             "tessellator_output_primitive_type"> {
  let assemblyFormat = "$value";
}

def DXSA_OutputPrimitiveTopology_PointList     : I32EnumAttrCase<"pointlist",     1>;
def DXSA_OutputPrimitiveTopology_LineStrip     : I32EnumAttrCase<"linestrip",     3>;
def DXSA_OutputPrimitiveTopology_TriangleStrip : I32EnumAttrCase<"trianglestrip", 5>;

def DXSA_OutputPrimitiveTopology : I32EnumAttr<
    "OutputPrimitiveTopology", "shader output primitive topology", [
      DXSA_OutputPrimitiveTopology_PointList,
      DXSA_OutputPrimitiveTopology_LineStrip,
      DXSA_OutputPrimitiveTopology_TriangleStrip
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_OutputPrimitiveTopologyAttr :
    EnumAttr<DXSADialect, DXSA_OutputPrimitiveTopology,
             "output_primitive_topology"> {
  let assemblyFormat = "$value";
}

def DXSA_TessellatorPartitioningMode_Integer        : I32EnumAttrCase<"partitioning_integer",         1>;
def DXSA_TessellatorPartitioningMode_Pow2           : I32EnumAttrCase<"partitioning_pow2",            2>;
def DXSA_TessellatorPartitioningMode_FractionalOdd  : I32EnumAttrCase<"partitioning_fractional_odd",  3>;
def DXSA_TessellatorPartitioningMode_FractionalEven : I32EnumAttrCase<"partitioning_fractional_even", 4>;

def DXSA_TessellatorPartitioningMode : I32EnumAttr<
    "TessellatorPartitioningMode", "tessellator partitioning mode", [
      DXSA_TessellatorPartitioningMode_Integer,
      DXSA_TessellatorPartitioningMode_Pow2,
      DXSA_TessellatorPartitioningMode_FractionalOdd,
      DXSA_TessellatorPartitioningMode_FractionalEven
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_TessellatorPartitioningModeAttr :
    EnumAttr<DXSADialect, DXSA_TessellatorPartitioningMode,
             "tessellator_partitioning_mode"> {
  let assemblyFormat = "$value";
}

def DXSA_InputPrimitive_Point        : I32EnumAttrCase<"point",         1>;
def DXSA_InputPrimitive_Line         : I32EnumAttrCase<"line",          2>;
def DXSA_InputPrimitive_Triangle     : I32EnumAttrCase<"triangle",      3>;
def DXSA_InputPrimitive_LineAdj      : I32EnumAttrCase<"line_adj",      6>;
def DXSA_InputPrimitive_TriangleAdj  : I32EnumAttrCase<"triangle_adj",  7>;
foreach i = !range(1, 33) in {
  def DXSA_InputPrimitive_Patch#i :
      I32EnumAttrCase<"patch" # i, !add(i, 7)>;
}

def DXSA_InputPrimitive : I32EnumAttr<
    "InputPrimitive", "geometry shader input primitive type",
    !listconcat(
      [DXSA_InputPrimitive_Point,
       DXSA_InputPrimitive_Line,
       DXSA_InputPrimitive_Triangle,
       DXSA_InputPrimitive_LineAdj,
       DXSA_InputPrimitive_TriangleAdj],
      !foreach(i, !range(1, 33),
        !cast<I32EnumAttrCase>("DXSA_InputPrimitive_Patch" # i)))> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_InputPrimitiveAttr :
    EnumAttr<DXSADialect, DXSA_InputPrimitive, "input_primitive"> {
  let assemblyFormat = "$value";
}

def DXSA_InterpolationMode_Constant                    : I32EnumAttrCase<"constant",                    1>;
def DXSA_InterpolationMode_Linear                      : I32EnumAttrCase<"linear",                      2>;
def DXSA_InterpolationMode_LinearCentroid              : I32EnumAttrCase<"linearCentroid",              3>;
def DXSA_InterpolationMode_LinearNoPerspective         : I32EnumAttrCase<"linearNoPerspective",         4>;
def DXSA_InterpolationMode_LinearNoPerspectiveCentroid : I32EnumAttrCase<"linearNoPerspectiveCentroid", 5>;
def DXSA_InterpolationMode_LinearSample                : I32EnumAttrCase<"linearSample",                6>;
def DXSA_InterpolationMode_LinearNoPerspectiveSample   : I32EnumAttrCase<"linearNoPerspectiveSample",   7>;

def DXSA_InterpolationMode : I32EnumAttr<
    "InterpolationMode", "pixel shader interpolation mode", [
      DXSA_InterpolationMode_Constant,
      DXSA_InterpolationMode_Linear,
      DXSA_InterpolationMode_LinearCentroid,
      DXSA_InterpolationMode_LinearNoPerspective,
      DXSA_InterpolationMode_LinearNoPerspectiveCentroid,
      DXSA_InterpolationMode_LinearSample,
      DXSA_InterpolationMode_LinearNoPerspectiveSample
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_InterpolationModeAttr :
    EnumAttr<DXSADialect, DXSA_InterpolationMode, "interpolation_mode"> {
  let assemblyFormat = "$value";
}

def DXSA_SystemValueName_Position                       : I32EnumAttrCase<"position",                       1>;
def DXSA_SystemValueName_ClipDistance                   : I32EnumAttrCase<"clipDistance",                   2>;
def DXSA_SystemValueName_CullDistance                   : I32EnumAttrCase<"cullDistance",                   3>;
def DXSA_SystemValueName_RenderTargetArrayIndex         : I32EnumAttrCase<"renderTargetArrayIndex",         4>;
def DXSA_SystemValueName_ViewportArrayIndex             : I32EnumAttrCase<"viewportArrayIndex",             5>;
def DXSA_SystemValueName_VertexId                       : I32EnumAttrCase<"vertexID",                       6>;
def DXSA_SystemValueName_PrimitiveId                    : I32EnumAttrCase<"primitiveID",                    7>;
def DXSA_SystemValueName_InstanceId                     : I32EnumAttrCase<"instanceID",                     8>;
def DXSA_SystemValueName_IsFrontFace                    : I32EnumAttrCase<"isFrontFace",                    9>;
def DXSA_SystemValueName_SampleIndex                    : I32EnumAttrCase<"sampleIndex",                   10>;
def DXSA_SystemValueName_FinalQuadUeq0EdgeTessFactor    : I32EnumAttrCase<"finalQuadUeq0EdgeTessFactor",   11>;
def DXSA_SystemValueName_FinalQuadVeq0EdgeTessFactor    : I32EnumAttrCase<"finalQuadVeq0EdgeTessFactor",   12>;
def DXSA_SystemValueName_FinalQuadUeq1EdgeTessFactor    : I32EnumAttrCase<"finalQuadUeq1EdgeTessFactor",   13>;
def DXSA_SystemValueName_FinalQuadVeq1EdgeTessFactor    : I32EnumAttrCase<"finalQuadVeq1EdgeTessFactor",   14>;
def DXSA_SystemValueName_FinalQuadUInsideTessFactor     : I32EnumAttrCase<"finalQuadUInsideTessFactor",    15>;
def DXSA_SystemValueName_FinalQuadVInsideTessFactor     : I32EnumAttrCase<"finalQuadVInsideTessFactor",    16>;
def DXSA_SystemValueName_FinalTriUeq0EdgeTessFactor     : I32EnumAttrCase<"finalTriUeq0EdgeTessFactor",    17>;
def DXSA_SystemValueName_FinalTriVeq0EdgeTessFactor     : I32EnumAttrCase<"finalTriVeq0EdgeTessFactor",    18>;
def DXSA_SystemValueName_FinalTriWeq0EdgeTessFactor     : I32EnumAttrCase<"finalTriWeq0EdgeTessFactor",    19>;
def DXSA_SystemValueName_FinalTriInsideTessFactor       : I32EnumAttrCase<"finalTriInsideTessFactor",      20>;
def DXSA_SystemValueName_FinalLineDetailTessFactor      : I32EnumAttrCase<"finalLineDetailTessFactor",     21>;
def DXSA_SystemValueName_FinalLineDensityTessFactor     : I32EnumAttrCase<"finalLineDensityTessFactor",    22>;
def DXSA_SystemValueName_Barycentrics                   : I32EnumAttrCase<"barycentrics",                  23>;
def DXSA_SystemValueName_ShadingRate                    : I32EnumAttrCase<"shadingRate",                   24>;
def DXSA_SystemValueName_CullPrimitive                  : I32EnumAttrCase<"cullPrimitive",                 25>;

def DXSA_SystemValueName : I32EnumAttr<
    "SystemValueName", "DXBC system interpreted/generated value name", [
      DXSA_SystemValueName_Position,
      DXSA_SystemValueName_ClipDistance,
      DXSA_SystemValueName_CullDistance,
      DXSA_SystemValueName_RenderTargetArrayIndex,
      DXSA_SystemValueName_ViewportArrayIndex,
      DXSA_SystemValueName_VertexId,
      DXSA_SystemValueName_PrimitiveId,
      DXSA_SystemValueName_InstanceId,
      DXSA_SystemValueName_IsFrontFace,
      DXSA_SystemValueName_SampleIndex,
      DXSA_SystemValueName_FinalQuadUeq0EdgeTessFactor,
      DXSA_SystemValueName_FinalQuadVeq0EdgeTessFactor,
      DXSA_SystemValueName_FinalQuadUeq1EdgeTessFactor,
      DXSA_SystemValueName_FinalQuadVeq1EdgeTessFactor,
      DXSA_SystemValueName_FinalQuadUInsideTessFactor,
      DXSA_SystemValueName_FinalQuadVInsideTessFactor,
      DXSA_SystemValueName_FinalTriUeq0EdgeTessFactor,
      DXSA_SystemValueName_FinalTriVeq0EdgeTessFactor,
      DXSA_SystemValueName_FinalTriWeq0EdgeTessFactor,
      DXSA_SystemValueName_FinalTriInsideTessFactor,
      DXSA_SystemValueName_FinalLineDetailTessFactor,
      DXSA_SystemValueName_FinalLineDensityTessFactor,
      DXSA_SystemValueName_Barycentrics,
      DXSA_SystemValueName_ShadingRate,
      DXSA_SystemValueName_CullPrimitive
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_SystemValueNameAttr :
    EnumAttr<DXSADialect, DXSA_SystemValueName, "system_value_name"> {
  let assemblyFormat = "$value";
}

//===----------------------------------------------------------------------===//
// DXSA op definitions
//===----------------------------------------------------------------------===//

// Base class for the operation in this dialect
class DXSA_Op<string mnemonic, list<Trait> traits = []> :
    Op<DXSADialect, mnemonic, traits>;

def DXSA_Operand : DXSA_Op<"operand"> {
  let summary = "defines an operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXSA_IndexType>:$operands,
                       I32Attr:$type,
                       I32Attr:$num_components,
		       OptionalAttr<I32Attr>:$one,
		       OptionalAttr<I32Attr>:$mask,
		       OptionalAttr<I32ElementsAttr>:$swizzle,
		       OptionalAttr<I32Attr>:$modifier,
		       OptionalAttr<I32Attr>:$min_precision,
		       OptionalAttr<I32Attr>:$non_uniform);
  let results = (outs DXSA_OperandType:$operand);
  let assemblyFormat = "$operands attr-dict";
}

def DXSA_OperandImm : DXSA_Op<"operand.imm"> {
  let summary = "defines an immediate operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32ElementsAttr, I64ElementsAttr]>:$imm);
  let results = (outs DXSA_OperandType:$operand);
  let assemblyFormat = "attr-dict";
}

def DXSA_IndexImm : DXSA_Op<"index.imm"> {
  let summary = "defines an immediate index";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32Attr, I64Attr]>:$imm);
  let results = (outs DXSA_IndexType:$index);
  let assemblyFormat = "attr-dict";
}

def DXSA_IndexRel : DXSA_Op<"index.rel"> {
  let summary = "defines an operand index";
  let description = [{
    TODO
  }];

  let arguments = (ins DXSA_OperandType:$operand);
  let results = (outs DXSA_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXSA_IndexRelImm : DXSA_Op<"index.rel.imm"> {
  let summary = "defines an operand index with an immediate attribute";
  let description = [{
    TODO
  }];

  let arguments = (ins DXSA_OperandType:$operand, StrAttr:$op, I64Attr:$imm);
  let results = (outs DXSA_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXSA_Instruction : DXSA_Op<"instruction"> {
  let summary = "defines an instruction with zero or more operands";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXSA_OperandType>:$operands, StrAttr:$mnemonic);
  let results = (outs);
  let assemblyFormat = "$mnemonic $operands attr-dict";
}

def DXSA_DclGlobalFlags : DXSA_Op<"dcl_global_flags"> {
  let summary = "declares global shader flags";
  let description = [{
    The `dxsa.dcl_global_flags` operation declares a set of flags that
    affect the entire shader.

    Example:

    ```mlir
    dxsa.dcl_global_flags <refactoringAllowed|forceEarlyDepthStencil>
    ```
  }];
  let arguments = (ins DXSA_GlobalFlagsAttr:$flags);
  let assemblyFormat = "$flags attr-dict";
}

def DXSA_DclTemps : DXSA_Op<"dcl_temps"> {
  let summary = "declares the number of temporary registers";
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntPositive, IntMaxValue<4096>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXSA_DclInputControlPointCount :
    DXSA_Op<"dcl_input_control_point_count"> {
  let summary = "declares the hull shader input control point count";
  let description = [{
    The `dxsa.dcl_input_control_point_count` operation declares the number of
    input control points for the hull shader.

    The count must be in [1, 32].

    Example:

    ```mlir
    dxsa.dcl_input_control_point_count 3
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntPositive, IntMaxValue<32>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXSA_DclOutputControlPointCount :
    DXSA_Op<"dcl_output_control_point_count"> {
  let summary = "declares the hull shader output control point count";
  let description = [{
    The `dxsa.dcl_output_control_point_count` operation declares the number
    of output control points for the hull shader.

    The count must be in [0, 32].

    Example:

    ```mlir
    dxsa.dcl_output_control_point_count 4
    ```
  }];
  let arguments = (ins ConfinedAttr<I32Attr,
      [IntNonNegative, IntMaxValue<32>]>:$count);
  let assemblyFormat = [{ $count attr-dict }];
}

def DXSA_DclTessellatorDomain : DXSA_Op<"dcl_tessellator_domain"> {
  let summary = "declares the tessellator domain";
  let description = [{
    The `dxsa.dcl_tessellator_domain` operation declares the tessellator
    domain.

    Example:

    ```mlir
    dxsa.dcl_tessellator_domain domain_quad
    ```
  }];

  let arguments = (ins DXSA_TessellatorDomainAttr:$domain);
  let assemblyFormat = "$domain attr-dict";
}

def DXSA_DclTessellatorOutputPrimitive
    : DXSA_Op<"dcl_tessellator_output_primitive"> {
  let summary = "declares the tessellator output primitive type";
  let description = [{
    The `dxsa.dcl_tessellator_output_primitive` operation declares the
    tessellator output primitive type.

    Example:

    ```mlir
    dxsa.dcl_tessellator_output_primitive output_triangle_cw
    ```
  }];
  let arguments = (ins DXSA_TessellatorOutputPrimitiveTypeAttr:$type);
  let assemblyFormat = "$type attr-dict";
}

def DXSA_DclOutputTopology : DXSA_Op<"dcl_output_topology"> {
  let summary = "declare what primitive topology the shader generates as output";
  let description = [{
    The `dxsa.dcl_output_topology` operation declares the primitive topology
    that the shader generates as output.

    Example:

    ```mlir
    dxsa.dcl_output_topology trianglestrip
    ```
  }];
  let arguments = (ins DXSA_OutputPrimitiveTopologyAttr:$topology);
  let assemblyFormat = "$topology attr-dict";
}

def DXSA_DclTessellatorPartitioning
    : DXSA_Op<"dcl_tessellator_partitioning"> {
  let summary = "declares the tessellator partitioning mode";
  let description = [{
    The `dxsa.dcl_tessellator_partitioning` operation declares the
    tessellator partitioning mode in a Hull Shader declaration section.

    Example:

    ```mlir
    dxsa.dcl_tessellator_partitioning partitioning_integer
    ```
  }];
  let arguments = (ins DXSA_TessellatorPartitioningModeAttr:$partitioningMode);
  let assemblyFormat = "$partitioningMode attr-dict";
}

def DXSA_DclInputPrimitive : DXSA_Op<"dcl_input_primitive"> {
  let summary = "declares the shader input primitive type";
  let description = [{
    The `dxsa.dcl_input_primitive` operation declares the input primitive
    type that the shader is invoked with.

    Example:

    ```mlir
    dxsa.dcl_input_primitive triangle
    ```
  }];
  let arguments = (ins DXSA_InputPrimitiveAttr:$type);
  let assemblyFormat = "$type attr-dict";
}

def DXSA_DclInputPs : DXSA_Op<"dcl_input_ps"> {
  let summary = "declares a pixel shader input";
  let description = [{
    The `dxsa.dcl_input_ps` operation declares a pixel shader input
    with the given attribute interpolation mode.

    Example:

    ```mlir
    dxsa.dcl_input_ps linear %v0
    ```
  }];
  let arguments = (ins DXSA_InterpolationModeAttr:$mode,
                       DXSA_OperandType:$operand);
  let assemblyFormat = "$mode $operand attr-dict";
}

def DXSA_DclInputPsSiv : DXSA_Op<"dcl_input_ps_siv"> {
  let summary = "declares a pixel shader system-interpreted input";
  let description = [{
    The `dxsa.dcl_input_ps_siv` operation declares a pixel shader input
    that receives a System Interpreted Value, with the given attribute
    interpolation mode.

    Example:

    ```mlir
    dxsa.dcl_input_ps_siv linear %v0, position
    ```
  }];
  let arguments = (ins DXSA_InterpolationModeAttr:$mode,
                       DXSA_OperandType:$operand,
                       DXSA_SystemValueNameAttr:$name);
  let assemblyFormat = "$mode $operand `,` $name attr-dict";
}

def DXSA_DclInputPsSgv : DXSA_Op<"dcl_input_ps_sgv"> {
  let summary = "declares a pixel shader system-generated input";
  let description = [{
    The `dxsa.dcl_input_ps_sgv` operation declares a pixel shader input
    that receives a System Generated Value.

    Example:

    ```mlir
    dxsa.dcl_input_ps_sgv %v0, sampleIndex
    ```
  }];
  let arguments = (ins DXSA_OperandType:$operand,
                       DXSA_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXSA_DclInput : DXSA_Op<"dcl_input"> {
  let summary = "declares a shader input register";
  let description = [{
    The `dxsa.dcl_input` operation declares a shader input register.

    The register operand can be either an indexed input register
    or a special scalar input.

    Example:

    ```mlir

    dxsa.dcl_input %v0
    ```
  }];
  let arguments = (ins DXSA_OperandType:$operand);
  let assemblyFormat = "$operand attr-dict";
}

def DXSA_DclOutput : DXSA_Op<"dcl_output"> {
  let summary = "declares a shader output register";
  let description = [{
    The `dxsa.dcl_output` operation declares a shader output register.

    The register operand can be either an indexed output register
    or a special scalar output.

    Example:

    ```mlir
    dxsa.dcl_output %o0
    ```
  }];
  let arguments = (ins DXSA_OperandType:$operand);
  let assemblyFormat = "$operand attr-dict";
}

#endif // DXSA_OPS
