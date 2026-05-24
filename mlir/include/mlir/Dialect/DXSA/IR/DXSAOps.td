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
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/BuiltinAttributeInterfaces.td"
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
  let assemblyFormat = "`<` $value `>`";
}

//===----------------------------------------------------------------------===//
// DXSA ComponentMask bit-enum (mask field of operand, normalized to bits 0..3)
//===----------------------------------------------------------------------===//

def DXSA_ComponentMask_X : I32BitEnumAttrCaseBit<"x", 0>;
def DXSA_ComponentMask_Y : I32BitEnumAttrCaseBit<"y", 1>;
def DXSA_ComponentMask_Z : I32BitEnumAttrCaseBit<"z", 2>;
def DXSA_ComponentMask_W : I32BitEnumAttrCaseBit<"w", 3>;

def DXSA_ComponentMask : I32BitEnumAttr<
    "ComponentMask", "component mask (subset of x, y, z, w)", [
      DXSA_ComponentMask_X,
      DXSA_ComponentMask_Y,
      DXSA_ComponentMask_Z,
      DXSA_ComponentMask_W
    ]> {
  let separator = ", ";
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_ComponentMaskAttr :
    EnumAttr<DXSADialect, DXSA_ComponentMask, "component_mask"> {
  let assemblyFormat = "`<` $value `>`";
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

def DXSA_InlineOperandType_Temp                          : I32EnumAttrCase<"temp",                                  0>;
def DXSA_InlineOperandType_Input                         : I32EnumAttrCase<"input",                                 1>;
def DXSA_InlineOperandType_Output                        : I32EnumAttrCase<"output",                                2>;
def DXSA_InlineOperandType_IndexableTemp                 : I32EnumAttrCase<"indexable_temp",                        3>;
def DXSA_InlineOperandType_Immediate32                   : I32EnumAttrCase<"immediate32",                           4>;
def DXSA_InlineOperandType_Immediate64                   : I32EnumAttrCase<"immediate64",                           5>;
def DXSA_InlineOperandType_Sampler                       : I32EnumAttrCase<"sampler",                               6>;
def DXSA_InlineOperandType_Resource                      : I32EnumAttrCase<"resource",                              7>;
def DXSA_InlineOperandType_ConstantBuffer                : I32EnumAttrCase<"constant_buffer",                       8>;
def DXSA_InlineOperandType_ImmediateConstantBuffer       : I32EnumAttrCase<"immediate_constant_buffer",             9>;
def DXSA_InlineOperandType_Label                         : I32EnumAttrCase<"label",                                10>;
def DXSA_InlineOperandType_InputPrimitiveId              : I32EnumAttrCase<"input_primitive_id",                   11>;
def DXSA_InlineOperandType_OutputDepth                   : I32EnumAttrCase<"output_depth",                         12>;
def DXSA_InlineOperandType_Null                          : I32EnumAttrCase<"null",                                 13>;
def DXSA_InlineOperandType_Rasterizer                    : I32EnumAttrCase<"rasterizer",                           14>;
def DXSA_InlineOperandType_OutputCoverageMask            : I32EnumAttrCase<"output_coverage_mask",                 15>;
def DXSA_InlineOperandType_Stream                        : I32EnumAttrCase<"stream",                               16>;
def DXSA_InlineOperandType_FunctionBody                  : I32EnumAttrCase<"function_body",                        17>;
def DXSA_InlineOperandType_FunctionTable                 : I32EnumAttrCase<"function_table",                       18>;
def DXSA_InlineOperandType_Interface                     : I32EnumAttrCase<"interface",                            19>;
def DXSA_InlineOperandType_FunctionInput                 : I32EnumAttrCase<"function_input",                       20>;
def DXSA_InlineOperandType_FunctionOutput                : I32EnumAttrCase<"function_output",                      21>;
def DXSA_InlineOperandType_OutputControlPointId          : I32EnumAttrCase<"output_control_point_id",              22>;
def DXSA_InlineOperandType_InputForkInstanceId           : I32EnumAttrCase<"input_fork_instance_id",               23>;
def DXSA_InlineOperandType_InputJoinInstanceId           : I32EnumAttrCase<"input_join_instance_id",               24>;
def DXSA_InlineOperandType_InputControlPoint             : I32EnumAttrCase<"input_control_point",                  25>;
def DXSA_InlineOperandType_OutputControlPoint            : I32EnumAttrCase<"output_control_point",                 26>;
def DXSA_InlineOperandType_InputPatchConstant            : I32EnumAttrCase<"input_patch_constant",                 27>;
def DXSA_InlineOperandType_InputDomainPoint              : I32EnumAttrCase<"input_domain_point",                   28>;
def DXSA_InlineOperandType_ThisPointer                   : I32EnumAttrCase<"this_pointer",                         29>;
def DXSA_InlineOperandType_Uav                           : I32EnumAttrCase<"uav",                                  30>;
def DXSA_InlineOperandType_ThreadGroupSharedMemory       : I32EnumAttrCase<"thread_group_shared_memory",           31>;
def DXSA_InlineOperandType_InputThreadId                 : I32EnumAttrCase<"input_thread_id",                      32>;
def DXSA_InlineOperandType_InputThreadGroupId            : I32EnumAttrCase<"input_thread_group_id",                33>;
def DXSA_InlineOperandType_InputThreadIdInGroup          : I32EnumAttrCase<"input_thread_id_in_group",             34>;
def DXSA_InlineOperandType_InputCoverageMask             : I32EnumAttrCase<"input_coverage_mask",                  35>;
def DXSA_InlineOperandType_InputThreadIdInGroupFlattened : I32EnumAttrCase<"input_thread_id_in_group_flattened",   36>;
def DXSA_InlineOperandType_InputGsInstanceId             : I32EnumAttrCase<"input_gs_instance_id",                 37>;
def DXSA_InlineOperandType_OutputDepthGe                 : I32EnumAttrCase<"output_depth_ge",                      38>;
def DXSA_InlineOperandType_OutputDepthLe                 : I32EnumAttrCase<"output_depth_le",                      39>;
def DXSA_InlineOperandType_CycleCounter                  : I32EnumAttrCase<"cycle_counter",                        40>;
def DXSA_InlineOperandType_OutputStencilRef              : I32EnumAttrCase<"output_stencil_ref",                   41>;
def DXSA_InlineOperandType_InnerCoverage                 : I32EnumAttrCase<"inner_coverage",                       42>;

def DXSA_InlineOperandType : I32EnumAttr<
    "InlineOperandType", "operand type", [
      DXSA_InlineOperandType_Temp,
      DXSA_InlineOperandType_Input,
      DXSA_InlineOperandType_Output,
      DXSA_InlineOperandType_IndexableTemp,
      DXSA_InlineOperandType_Immediate32,
      DXSA_InlineOperandType_Immediate64,
      DXSA_InlineOperandType_Sampler,
      DXSA_InlineOperandType_Resource,
      DXSA_InlineOperandType_ConstantBuffer,
      DXSA_InlineOperandType_ImmediateConstantBuffer,
      DXSA_InlineOperandType_Label,
      DXSA_InlineOperandType_InputPrimitiveId,
      DXSA_InlineOperandType_OutputDepth,
      DXSA_InlineOperandType_Null,
      DXSA_InlineOperandType_Rasterizer,
      DXSA_InlineOperandType_OutputCoverageMask,
      DXSA_InlineOperandType_Stream,
      DXSA_InlineOperandType_FunctionBody,
      DXSA_InlineOperandType_FunctionTable,
      DXSA_InlineOperandType_Interface,
      DXSA_InlineOperandType_FunctionInput,
      DXSA_InlineOperandType_FunctionOutput,
      DXSA_InlineOperandType_OutputControlPointId,
      DXSA_InlineOperandType_InputForkInstanceId,
      DXSA_InlineOperandType_InputJoinInstanceId,
      DXSA_InlineOperandType_InputControlPoint,
      DXSA_InlineOperandType_OutputControlPoint,
      DXSA_InlineOperandType_InputPatchConstant,
      DXSA_InlineOperandType_InputDomainPoint,
      DXSA_InlineOperandType_ThisPointer,
      DXSA_InlineOperandType_Uav,
      DXSA_InlineOperandType_ThreadGroupSharedMemory,
      DXSA_InlineOperandType_InputThreadId,
      DXSA_InlineOperandType_InputThreadGroupId,
      DXSA_InlineOperandType_InputThreadIdInGroup,
      DXSA_InlineOperandType_InputCoverageMask,
      DXSA_InlineOperandType_InputThreadIdInGroupFlattened,
      DXSA_InlineOperandType_InputGsInstanceId,
      DXSA_InlineOperandType_OutputDepthGe,
      DXSA_InlineOperandType_OutputDepthLe,
      DXSA_InlineOperandType_CycleCounter,
      DXSA_InlineOperandType_OutputStencilRef,
      DXSA_InlineOperandType_InnerCoverage
    ]> {
  let cppNamespace = "::mlir::dxsa";
  let genSpecializedAttr = 0;
}

def DXSA_InlineOperandAttr : AttrDef<DXSADialect, "InlineOperand"> {
  let mnemonic = "inline_operand";
  let summary = "inline operand of an instruction";
  let description = [{
    The `#dxsa.inline_operand` attribute carries a fully decoded operand token

    Example:

    ```mlir
    dxsa.dcl_output <type = output, components = 4, mask = <x, y, z, w>, index = [0]>
    dxsa.dcl_output <type = output_depth, components = 1>
    ```
  }];
  let parameters = (ins
      EnumParameter<DXSA_InlineOperandType>:$type,
      "uint32_t":$components,
      OptionalParameter<"::mlir::dxsa::ComponentMaskAttr">:$mask,
      OptionalParameter<"::mlir::DenseI64ArrayAttr">:$index);
  let assemblyFormat = [{
    `<` `type` `=` $type
        `,` `components` `=` $components
        (`,` `mask` `=` $mask^)?
        (`,` `index` `=` $index^)?
    `>`
  }];
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
    dxsa.dcl_input_ps_siv linear %v0, <position>
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
    dxsa.dcl_input_ps_sgv %v0, <sampleIndex>
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
    dxsa.dcl_input <type = input, components = 4, mask = <x>, index = [0]>
    ```
  }];
  let arguments = (ins DXSA_InlineOperandAttr:$operand);
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
    dxsa.dcl_output <type = output, components = 4, mask = <x, y, z, w>, index = [0]>
    ```
  }];
  let arguments = (ins DXSA_InlineOperandAttr:$operand);
  let assemblyFormat = "$operand attr-dict";
}

def DXSA_DclIndexRange : DXSA_Op<"dcl_index_range"> {
  let summary = "declares a range of input or output registers to be indexed";
  let description = [{
    The `dxsa.dcl_index_range` operation declares a range of input or output
    registers to be indexed.

    Example:

    ```mlir
    dxsa.dcl_index_range <type = output, components = 4, mask = <x>, index = [0]>, 4
    ```
  }];
  let arguments = (ins DXSA_InlineOperandAttr:$operand,
                       ConfinedAttr<I32Attr, [IntPositive]>:$count);
  let assemblyFormat = "$operand `,` $count attr-dict";
  let hasVerifier = 1;
}

def DXSA_DclOutputSgv : DXSA_Op<"dcl_output_sgv"> {
  let summary = "declares an output as a System Generated Value";
  let description = [{
    The `dxsa.dcl_output_sgv` operation declares an output to be written
    that represents a System Generated Value.

    Example:

    ```mlir
    dxsa.dcl_output_sgv <type = output, components = 1, mask = <x>, index = [4]>, <primitiveID>
    ```
  }];
  let arguments = (ins DXSA_InlineOperandAttr:$operand,
                       DXSA_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

def DXSA_DclOutputSiv : DXSA_Op<"dcl_output_siv"> {
  let summary = "declares an output as a System Interpreted Value";
  let description = [{
    The `dxsa.dcl_output_siv` operation declares an output to be written
    that represents a System Interpreted Value.
    
    Example:

    ```mlir
    dxsa.dcl_output_siv <type = output, components = 4, mask = <x, y, z, w>, index = [3]>, <position>
    ```
  }];
  let arguments = (ins DXSA_InlineOperandAttr:$operand,
                       DXSA_SystemValueNameAttr:$name);
  let assemblyFormat = "$operand `,` $name attr-dict";
}

#endif // DXSA_OPS
