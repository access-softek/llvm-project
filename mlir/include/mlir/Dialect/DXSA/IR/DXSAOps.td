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

#endif // DXSA_OPS
