//===- DXBCOps.td - DXBC operations definition -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef DXBC_OPS
#define DXBC_OPS

include "mlir/Dialect/DXBC/IR/DXBCDialect.td"
include "mlir/Dialect/DXBC/IR/DXBCTypes.td"
include "mlir/IR/EnumAttr.td"

//===----------------------------------------------------------------------===//
// DXBC enum definitions
//===----------------------------------------------------------------------===//

// Global shader flags for 'dcl_globalFlags' instruction.
def DXBC_GlobalFlags_None               : I32BitEnumAttrCaseNone<"none">;
// D3D10_SB_GLOBAL_FLAG_REFACTORING_ALLOWED
def DXBC_GlobalFlags_RefactoringAllowed : I32BitEnumAttrCaseBit<"refactoringAllowed", 11>;
// D3D11_SB_GLOBAL_FLAG_ENABLE_DOUBLE_PRECISION_FLOAT_OPS
def DXBC_GlobalFlags_DoublePrecision    : I32BitEnumAttrCaseBit<"enableDoublePrecision", 12>;
// D3D11_SB_GLOBAL_FLAG_FORCE_EARLY_DEPTH_STENCIL
def DXBC_GlobalFlags_ForceEarlyDepth    : I32BitEnumAttrCaseBit<"forceEarlyDepth", 13>;
// D3D11_SB_GLOBAL_FLAG_ENABLE_RAW_AND_STRUCTURED_BUFFERS
def DXBC_GlobalFlags_RawStructured      : I32BitEnumAttrCaseBit<"enableRawStructured", 14>;
// D3D11_1_SB_GLOBAL_FLAG_SKIP_OPTIMIZATION
def DXBC_GlobalFlags_SkipOptimization   : I32BitEnumAttrCaseBit<"skipOptimization", 15>;
// D3D11_1_SB_GLOBAL_FLAG_ENABLE_MINIMUM_PRECISION
def DXBC_GlobalFlags_MinPrecision       : I32BitEnumAttrCaseBit<"enableMinPrecision", 16>;
// D3D11_1_SB_GLOBAL_FLAG_ENABLE_DOUBLE_EXTENSIONS
def DXBC_GlobalFlags_DoubleExtensions   : I32BitEnumAttrCaseBit<"enableDoubleExtensions", 17>;
// D3D11_1_SB_GLOBAL_FLAG_ENABLE_SHADER_EXTENSIONS
def DXBC_GlobalFlags_ShaderExtensions   : I32BitEnumAttrCaseBit<"enableShaderExtensions", 18>;
// D3D12_SB_GLOBAL_FLAG_ALL_RESOURCES_BOUND
def DXBC_GlobalFlags_AllResourcesBound  : I32BitEnumAttrCaseBit<"allResourcesBound", 19>;

def DXBC_GlobalFlags : I32BitEnumAttr<
    "GlobalFlags", "global shader flags", [
      DXBC_GlobalFlags_None,
      DXBC_GlobalFlags_RefactoringAllowed,
      DXBC_GlobalFlags_DoublePrecision,
      DXBC_GlobalFlags_ForceEarlyDepth,
      DXBC_GlobalFlags_RawStructured,
      DXBC_GlobalFlags_SkipOptimization,
      DXBC_GlobalFlags_MinPrecision,
      DXBC_GlobalFlags_DoubleExtensions,
      DXBC_GlobalFlags_ShaderExtensions,
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

//===----------------------------------------------------------------------===//
// DXBC op definitions
//===----------------------------------------------------------------------===//

// Base class for the operation in this dialect
class DXBC_Op<string mnemonic, list<Trait> traits = []> :
    Op<DXBCDialect, mnemonic, traits>;

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
  let results = (outs DXBC_OperandType:$operand);
  let assemblyFormat = "$operands attr-dict";
}

def DXBC_OperandImm : DXBC_Op<"operand.imm"> {
  let summary = "defines an immediate operand of an instruction";
  let description = [{
    TODO
  }];

  let arguments = (ins AnyAttrOf<[I32ElementsAttr, I64ElementsAttr]>:$imm);
  let results = (outs DXBC_OperandType:$operand);
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

  let arguments = (ins DXBC_OperandType:$operand);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_IndexRelImm : DXBC_Op<"index.rel.imm"> {
  let summary = "defines an operand index with an immediate attribute";
  let description = [{
    TODO
  }];

  let arguments = (ins DXBC_OperandType:$operand, StrAttr:$op, I64Attr:$imm);
  let results = (outs DXBC_IndexType:$index);
  let assemblyFormat = "$operand attr-dict";
}

def DXBC_Instruction : DXBC_Op<"instruction"> {
  let summary = "defines an instruction with zero or more operands";
  let description = [{
    TODO
  }];

  let arguments = (ins Variadic<DXBC_OperandType>:$operands, StrAttr:$mnemonic);
  let results = (outs);
  let assemblyFormat = "$mnemonic $operands attr-dict";
}

def DXBC_DclGlobalFlags : DXBC_Op<"dcl_global_flags"> {
  let summary = "declares global shader flags";
  let arguments = (ins DXBC_GlobalFlagsAttr:$flags);
  let assemblyFormat = "$flags attr-dict";
  let hasVerifier = 1;
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

#endif // DXBC_OPS
