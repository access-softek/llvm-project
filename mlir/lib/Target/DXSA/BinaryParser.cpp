//===----------- BinaryParser.cpp - Parse DXSA binary to MLIR -------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Target/DXSA/BinaryParser.h"
#include "mlir/Dialect/DXSA/IR/DXSA.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Location.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DebugLog.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/LogicalResult.h"

#include <optional>

#include "d3d12TokenizedProgramFormat.hpp"

#define DEBUG_TYPE "import-dxsa-bin"

using namespace mlir;
using namespace llvm;

enum OpcodeClass {
  D3D10_SB_FLOAT_OP,
  D3D10_SB_INT_OP,
  D3D10_SB_UINT_OP,
  D3D10_SB_BIT_OP,
  D3D10_SB_FLOW_OP,
  D3D10_SB_TEX_OP,
  D3D10_SB_DCL_OP,
  D3D11_SB_ATOMIC_OP,
  D3D11_SB_MEM_OP,
  D3D11_SB_DOUBLE_OP,
  D3D11_SB_FLOAT_TO_DOUBLE_OP,
  D3D11_SB_DOUBLE_TO_FLOAT_OP,
  D3D11_SB_DEBUG_OP,
};

struct InstructionInfo {
  unsigned numOperands;
  StringRef name;
  OpcodeClass opClass;
  uint32_t precisionFromOutMask;
};

static void initInstructionInfo(MutableArrayRef<InstructionInfo> instructions) {
#define SET(OpCode, Name, NumOperands, PrecMask, OpClass)                      \
  instructions[OpCode] = InstructionInfo{NumOperands, Name, OpClass, PrecMask};
#include "InstrInfo.def"
#undef SET
}

struct InstructionModifier {
  uint32_t preciseMask{0};
  uint32_t saturate{0};
};

struct OperandModifier {
  uint32_t modifier{0};
  uint32_t minPrecision{0};
  uint32_t nonUniform{0};
};

enum class OperandComponentsKind {
  None,
  Mask,
  Swizzle,
  One,
};

struct OperandComponents {
  unsigned num;
  OperandComponentsKind kind;
  union {
    uint32_t mask;
    uint32_t swizzle[4];
    uint32_t one;
  };
};

class DXBuilder {
public:
  DXBuilder(MLIRContext *context, StringAttr name)
      : context(context),
        module(ModuleOp::create(builder, FileLineColLoc::get(name, 0, 0))),
        builder(module.getRegion()) {}

  using Index = mlir::Value;
  using Operand = mlir::Value;
  using Instruction = mlir::Operation *;
  using Module = mlir::ModuleOp;

  Index buildIndexImm32(int32_t imm, FileLineColLoc loc) {
    Operation *op =
        dxsa::IndexImm::create(builder, loc, builder.getType<dxsa::IndexType>(),
                               builder.getI32IntegerAttr(imm));
    return op->getResults()[0];
  }

  Index buildIndexImm64(int64_t imm, FileLineColLoc loc) {
    Operation *op =
        dxsa::IndexImm::create(builder, loc, builder.getType<dxsa::IndexType>(),
                               builder.getI64IntegerAttr(imm));
    return op->getResults()[0];
  }

  Index buildIndexRelative(Operand operand, FileLineColLoc loc) {
    Operation *op = dxsa::IndexRel::create(
        builder, loc, builder.getType<dxsa::IndexType>(), operand);
    return op->getResults()[0];
  }

  Index buildIndexImm32PlusRelative(int32_t imm, Operand operand,
                                    FileLineColLoc loc) {
    Operation *op = dxsa::IndexRelImm::create(
        builder, loc, builder.getType<dxsa::IndexType>(), operand,
        builder.getStringAttr("add"), builder.getI32IntegerAttr(imm));
    return op->getResults()[0];
  }

  Operand buildOperandImm32(ArrayRef<int32_t> values, FileLineColLoc loc) {
    Operation *op = dxsa::OperandImm::create(
        builder, loc, builder.getType<dxsa::OperandType>(),
        builder.getI32VectorAttr(values));
    return op->getResults()[0];
  }

  Operand buildOperandImm64(ArrayRef<int64_t> values, FileLineColLoc loc) {
    Operation *op = dxsa::OperandImm::create(
        builder, loc, builder.getType<dxsa::OperandType>(),
        builder.getI64VectorAttr(values));
    return op->getResults()[0];
  }

  Operand buildOperand(uint32_t opType, const OperandComponents &components,
                       ArrayRef<Index> indices,
                       const std::optional<OperandModifier> &modifier,
                       FileLineColLoc loc) {
    NamedAttrList attrs;
    attrs.append("type", builder.getI32IntegerAttr(opType));
    if (modifier) {
      const OperandModifier &mod = modifier.value();
      if (uint32_t modifier = mod.modifier) {
        attrs.append("modifier", builder.getI32IntegerAttr(modifier));
      }
      if (uint32_t minPrecision = mod.minPrecision) {
        attrs.append("min_precision", builder.getI32IntegerAttr(minPrecision));
      }
      if (uint32_t nonUniform = mod.nonUniform) {
        attrs.append("non_uniform", builder.getI32IntegerAttr(nonUniform));
      }
    }
    attrs.append("num_components", builder.getI32IntegerAttr(components.num));
    switch (components.kind) {
    case OperandComponentsKind::Mask: {
      attrs.append("mask", builder.getI32IntegerAttr(components.mask));
      break;
    }
    case OperandComponentsKind::Swizzle: {
      SmallVector<int32_t, 4> values;
      for (uint32_t i = 0; i < components.num; ++i) {
        values.push_back(components.swizzle[i]);
      }
      attrs.append("swizzle", builder.getI32VectorAttr(values));
      break;
    }
    case OperandComponentsKind::One: {
      attrs.append("one", builder.getI32IntegerAttr(components.one));
      break;
    }
    case OperandComponentsKind::None:
      break;
    }
    Operation *op = dxsa::Operand::create(
        builder, loc, builder.getType<dxsa::OperandType>(), indices, attrs);
    return op->getResults()[0];
  }

  Instruction buildInstruction(StringRef name, ArrayRef<Operand> operands,
                               const InstructionModifier &modifier,
                               FileLineColLoc loc) {
    return dxsa::Instruction::create(builder, loc, operands,
                                     builder.getStringAttr(name));
  }

  Module buildModule(ArrayRef<Instruction> instructions, FileLineColLoc loc) {
    return module;
  }

  Instruction buildDclGlobalFlags(uint32_t flags, Location loc) {
    auto flagsAttr = dxsa::GlobalFlagsAttr::get(
        builder.getContext(), static_cast<dxsa::GlobalFlags>(flags));
    return dxsa::DclGlobalFlags::create(builder, loc, flagsAttr);
  }

  Instruction buildDclTemps(uint32_t count, Location loc) {
    return dxsa::DclTemps::create(builder, loc,
                                  builder.getI32IntegerAttr(count));
  }

private:
  MLIRContext *context;
  ModuleOp module;
  OpBuilder builder;
};

class Parser {
public:
  Parser(DXBuilder &builder, StringAttr name, StringRef buffer)
      : builder(builder), name(name), buffer(buffer) {
    initInstructionInfo(instrInfo);
  }

  using Token = FailureOr<uint32_t>;
  using Index = DXBuilder::Index;
  using Operand = DXBuilder::Operand;
  using Instruction = DXBuilder::Instruction;
  using Module = DXBuilder::Module;

  /// Parse the current token and move the cursor to the next one.
  Token parseToken() {
    constexpr size_t tokenSize = sizeof(uint32_t);
    if ((currentTokenOffset + tokenSize) > buffer.size()) {
      emitError(getLocation(), "unexpected end of file");
      return failure();
    }

    uint32_t value = support::endian::read<uint32_t>(
        buffer.begin() + currentTokenOffset, endianness::little);
    currentTokenOffset += tokenSize;

    return value;
  }

  /// Returns location where the last parsed token begins (at offset
  /// -4 from the currentTokenOffset).
  FileLineColLoc getLocation(int offset = -4) const {
    return FileLineColLoc::get(name, 0, currentTokenOffset + offset);
  }

  bool isImmOperand(uint32_t token) {
    switch (DECODE_D3D10_SB_OPERAND_TYPE(token)) {
    case D3D10_SB_OPERAND_TYPE_IMMEDIATE32:
    case D3D10_SB_OPERAND_TYPE_IMMEDIATE64:
      return true;
    default:
      return false;
    }
  }

  FailureOr<OperandComponents> parseOperandComponents(uint32_t token) {
    OperandComponents components;
    switch (DECODE_D3D10_SB_OPERAND_NUM_COMPONENTS(token)) {
    case D3D10_SB_OPERAND_0_COMPONENT: {
      components.num = 0;
      break;
    }
    case D3D10_SB_OPERAND_1_COMPONENT: {
      components.num = 1;
      break;
    }
    case D3D10_SB_OPERAND_4_COMPONENT: {
      components.num = 4;
      break;
    }
    default:
      emitError(getLocation(), "unexpected number of components");
      return failure();
    }

    if (components.num != 4 || isImmOperand(token))
      return components;

    switch (DECODE_D3D10_SB_OPERAND_4_COMPONENT_SELECTION_MODE(token)) {
    case D3D10_SB_OPERAND_4_COMPONENT_MASK_MODE: {
      components.kind = OperandComponentsKind::Mask;
      components.mask = DECODE_D3D10_SB_OPERAND_4_COMPONENT_MASK(token);
      break;
    }
    case D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE_MODE: {
      components.kind = OperandComponentsKind::Swizzle;
      components.swizzle[0] =
          DECODE_D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE_SOURCE(token, 0);
      components.swizzle[1] =
          DECODE_D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE_SOURCE(token, 1);
      components.swizzle[2] =
          DECODE_D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE_SOURCE(token, 2);
      components.swizzle[3] =
          DECODE_D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE_SOURCE(token, 3);
      break;
    }
    case D3D10_SB_OPERAND_4_COMPONENT_SELECT_1_MODE: {
      components.kind = OperandComponentsKind::One;
      components.one = DECODE_D3D10_SB_OPERAND_4_COMPONENT_SELECT_1(token);
      break;
    }
    default:
      emitError(getLocation(), "unexpected component selection");
      return failure();
    }

    return components;
  }

  using OperandIndexTypes = SmallVector<uint32_t, 3>;

  FailureOr<OperandIndexTypes> parseOperandIndexTypes(uint32_t token) {
    SmallVector<uint32_t, 3> indexTypes;
    if (isImmOperand(token))
      return indexTypes; // none

    uint32_t indexDimension = DECODE_D3D10_SB_OPERAND_INDEX_DIMENSION(token);
    if (indexDimension > 3) {
      emitError(getLocation(),
                "invalid operand index dimension (must be <= 3)");
      return failure();
    }

    if (indexDimension == D3D10_SB_OPERAND_INDEX_0D)
      return indexTypes; // none

    indexTypes.resize(indexDimension);
    for (unsigned i = 0; i < indexTypes.size(); ++i) {
      indexTypes[i] = DECODE_D3D10_SB_OPERAND_INDEX_REPRESENTATION(i, token);
    }

    return indexTypes;
  }

  FailureOr<Index> parseIndex(uint32_t indexType) {
    switch (indexType) {
    case D3D10_SB_OPERAND_INDEX_IMMEDIATE32: {
      Token value = parseToken();
      if (failed(value)) {
        emitError(getLocation(), "expected an operand index imm32");
        return failure();
      }
      return builder.buildIndexImm32(*value, getLocation());
    }
    case D3D10_SB_OPERAND_INDEX_IMMEDIATE64: {
      Token value0 = parseToken();
      if (failed(value0)) {
        emitError(getLocation(), "expected an operand index imm64");
        return failure();
      }

      FileLineColLoc loc = getLocation();

      Token value1 = parseToken();
      if (failed(value1)) {
        emitError(getLocation(),
                  "expected an operand index imm64 (second token)");
        return failure();
      }

      // TODO: check the order of tokens (MSB or LSB?)
      return builder.buildIndexImm64((((uint64_t)*value0) << 32) | *value1,
                                     loc);
    }
    case D3D10_SB_OPERAND_INDEX_RELATIVE: {
      FailureOr<Operand> operand = parseOperand();
      if (failed(operand)) {
        emitError(getLocation(), "expected an index operand");
        return failure();
      }
      return builder.buildIndexRelative(*operand, getLocation());
    }
    case D3D10_SB_OPERAND_INDEX_IMMEDIATE32_PLUS_RELATIVE: {
      Token imm = parseToken();
      if (failed(imm)) {
        emitError(getLocation(), "expected an operand index relative (imm)");
        return failure();
      }

      FileLineColLoc loc = getLocation();

      FailureOr<Operand> operand = parseOperand();
      if (failed(operand)) {
        emitError(getLocation(),
                  "expected an operand index relative (operand)");
        return failure();
      }

      return builder.buildIndexImm32PlusRelative(*imm, *operand, loc);
    }
    default:
      emitError(getLocation(), "invalid operand index type");
      return failure();
    }
  }

  FailureOr<std::optional<OperandModifier>>
  parseOperandExtendedModifier(uint32_t extToken) {
    std::optional<OperandModifier> none;
    if (D3D10_SB_EXTENDED_OPERAND_MODIFIER !=
        DECODE_D3D10_SB_EXTENDED_OPERAND_TYPE(extToken))
      return none;

    OperandModifier modifier;
    modifier.modifier = DECODE_D3D10_SB_OPERAND_MODIFIER(extToken);
    modifier.minPrecision = DECODE_D3D11_SB_OPERAND_MIN_PRECISION(extToken);
    modifier.nonUniform = DECODE_D3D12_SB_OPERAND_NON_UNIFORM(extToken);
    return std::make_optional(modifier);
  }

  FailureOr<Operand> parseOperand() {
    Token token = parseToken();
    if (failed(token))
      return failure();

    FileLineColLoc loc = getLocation();

    uint32_t opType = DECODE_D3D10_SB_OPERAND_TYPE(*token);
    bool isExtended = DECODE_IS_D3D10_SB_OPERAND_EXTENDED(*token);

    FailureOr<OperandComponents> components = parseOperandComponents(*token);
    if (failed(components))
      return failure();

    FailureOr<OperandIndexTypes> indexTypes = parseOperandIndexTypes(*token);
    if (failed(indexTypes))
      return failure();

    std::optional<OperandModifier> modifier;
    if (isExtended) {
      Token extToken = parseToken();
      if (failed(extToken)) {
        emitError(getLocation(), "unexpected an extended operand token");
        return failure();
      }
      auto failureOrModifier = parseOperandExtendedModifier(*extToken);
      if (failed(failureOrModifier))
        return failure();
      modifier = *failureOrModifier;
    }

    if (isImmOperand(*token)) {
      switch (opType) {
      case D3D10_SB_OPERAND_TYPE_IMMEDIATE32: {
        SmallVector<int32_t, 4> values;
        for (unsigned i = 0; i < components->num; ++i) {
          Token value = parseToken();
          if (failed(value)) {
            emitError(getLocation(), "expected an immediate operand (imm32)");
            return failure();
          }
          values.push_back(*value);
        }
        return builder.buildOperandImm32(values, loc);
      }
      case D3D10_SB_OPERAND_TYPE_IMMEDIATE64: {
        if (components->num != 4) {
          emitError(getLocation(), "imm64 operand must have 4 components");
          return failure();
        }
        SmallVector<int64_t, 2> values;
        for (unsigned i = 0; i < 2; ++i) {
          Token high = parseToken();
          if (failed(high)) {
            emitError(getLocation(),
                      "expected an immediate operand (imm64 high)");
            return failure();
          }

          Token low = parseToken();
          if (failed(low)) {
            emitError(getLocation(),
                      "expected an immediate operand (imm64 low)");
            return failure();
          }

          values.push_back((((int64_t)*high) << 32) | *low);
        }
        return builder.buildOperandImm64(values, loc);
      }
      }
      emitError(getLocation(), "unhandled immediate type");
      return failure();
    }

    // Operand indices
    SmallVector<Index, 3> indices;
    for (uint32_t indexType : *indexTypes) {
      FailureOr<Index> index = parseIndex(indexType);
      if (failed(index))
        return failure();
      indices.push_back(*index);
    }
    return builder.buildOperand(opType, *components, indices, modifier,
                                getLocation());
  }

  FailureOr<Instruction> parseDclGlobalFlags(uint32_t opcodeToken,
                                             Location loc) {
    return builder.buildDclGlobalFlags(
        DECODE_D3D10_SB_GLOBAL_FLAGS(opcodeToken), loc);
  }

  FailureOr<Instruction> parseDclTemps(Location loc) {
    auto countToken = parseToken();
    if (failed(countToken))
      return failure();
    auto count = *countToken;
    if (count == 0) {
      emitError(getLocation(), "temp register count cannot be zero");
      return failure();
    }
    if (count > 4096) {
      emitError(getLocation(), "invalid temp register count: ")
          << count << " (max 4096)";
      return failure();
    }
    return builder.buildDclTemps(count, loc);
  }

  OptionalParseResult parseDclInstruction(uint32_t opcodeToken, Location loc,
                                          Instruction &out) {
    FailureOr<Instruction> result;
    switch (DECODE_D3D10_SB_OPCODE_TYPE(opcodeToken)) {
    case D3D10_SB_OPCODE_DCL_GLOBAL_FLAGS:
      result = parseDclGlobalFlags(opcodeToken, loc);
      break;
    case D3D10_SB_OPCODE_DCL_TEMPS:
      result = parseDclTemps(loc);
      break;
    default:
      return std::nullopt;
    }
    if (failed(result))
      return failure();
    out = *result;
    return success();
  }

  FailureOr<Instruction> parseInstruction() {
    size_t beginOffset = currentTokenOffset;
    Token token = parseToken();
    if (failed(token))
      return failure();

    FileLineColLoc loc = getLocation();

    uint32_t opcode = DECODE_D3D10_SB_OPCODE_TYPE(*token);
    InstructionModifier modifier;
    modifier.preciseMask = DECODE_D3D11_SB_INSTRUCTION_PRECISE_VALUES(*token);
    modifier.saturate = DECODE_IS_D3D10_SB_INSTRUCTION_SATURATE_ENABLED(*token);

    uint32_t length = DECODE_D3D10_SB_TOKENIZED_INSTRUCTION_LENGTH(*token);

    // TODO: extended instructions:
    // BOOL b51PlusShader =
    // BOOL bExtended = DECODE_IS_D3D10_SB_OPCODE_EXTENDED(Token)
    // ...

    if (opcode >= D3D10_SB_NUM_OPCODES) {
      emitError(getLocation(), "unknown opcode");
      return failure();
    }

    auto opcodeToken = *token;

    Instruction dclInstruction;
    auto parseResult = parseDclInstruction(opcodeToken, loc, dclInstruction);
    if (parseResult.has_value()) {
      if (failed(*parseResult))
        return failure();
      if (failed(verifyInstructionLength(beginOffset, length)))
        return failure();
      return dclInstruction;
    }

    unsigned numOperands = instrInfo[opcode].numOperands;

    SmallVector<Operand, 8> operands;
    for (unsigned i = 0; i < numOperands; ++i) {
      FailureOr<Operand> operand = parseOperand();
      if (failed(operand))
        return failure();
      operands.push_back(*operand);
    }

    if (failed(verifyInstructionLength(beginOffset, length)))
      return failure();

    return builder.buildInstruction(instrInfo[opcode].name, operands, modifier,
                                    loc);
  }

  FailureOr<Module> parseModule() {
    FileLineColLoc loc = getLocation(0);
    std::vector<Instruction> instructions;
    while (currentTokenOffset < buffer.size()) {
      FailureOr<Instruction> inst = parseInstruction();
      if (failed(inst)) {
        return failure();
      }
      instructions.push_back(*inst);
    }
    return builder.buildModule(instructions, loc);
  }

  LogicalResult verifyInstructionLength(size_t beginOffset, uint32_t length) {
    if (((currentTokenOffset - beginOffset) / 4) != length) {
      emitError(getLocation(), "instruction length mismatch");
      return failure();
    }
    return success();
  }

private:
  DXBuilder &builder;
  StringAttr name;
  StringRef buffer;
  size_t currentTokenOffset{0};
  InstructionInfo instrInfo[D3D10_SB_NUM_OPCODES];
};

namespace mlir::dxsa {
OwningOpRef<ModuleOp> importDxsaBinaryToModule(llvm::SourceMgr &source,
                                               MLIRContext *context) {

  if (source.getNumBuffers() != 1) {
    emitError(UnknownLoc::get(context), "one source file should be provided");
    return nullptr;
  }

  uint32_t sourceBufId = source.getMainFileID();
  StringRef buffer = source.getMemoryBuffer(sourceBufId)->getBuffer();
  StringAttr name = StringAttr::get(
      context, source.getMemoryBuffer(sourceBufId)->getBufferIdentifier());

  // FIXME:
  context->allowUnregisteredDialects();
  context->loadAllAvailableDialects();

  DXBuilder builder(context, name);
  Parser parser(builder, name, buffer);
  FailureOr<ModuleOp> mod = parser.parseModule();
  if (failed(mod))
    return {nullptr};
  return {*mod};
}
} // namespace mlir::dxsa
