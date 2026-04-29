#include "mlir/Dialect/DXSA/IR/DXSA.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Location.h"
#include "mlir/Target/DXSA/BinaryParser.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DebugLog.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/LogicalResult.h"

#include "d3d12TokenizedProgramFormat.hpp"

#define DEBUG_TYPE "export-dxsa-bin"

using namespace mlir;
using namespace llvm;

using OpcodeMap = llvm::DenseMap<StringRef, uint32_t>;

static void initOpcodeMap(OpcodeMap &opcodes) {
#define SET(OpCode, Name, NumOperands, PrecMask, OpClass)                      \
  opcodes[Name] = OpCode;
#include "InstrInfo.def"
#undef SET
}

static FailureOr<uint32_t> getIndexRepresentation(Operation *op) {
  if (auto imm = dyn_cast<dxsa::IndexImm>(op)) {
    auto attr = dyn_cast<IntegerAttr>(imm.getImm());
    if (!attr) {
      return emitError(op->getLoc(), "invalid immediate index");
    }

    if (attr.getType().isInteger(32)) {
      return D3D10_SB_OPERAND_INDEX_IMMEDIATE32;
    }

    if (attr.getType().isInteger(64)) {
      return D3D10_SB_OPERAND_INDEX_IMMEDIATE64;
    }

    return emitError(op->getLoc(), "invalid immediate index type");
  }

  if (isa<dxsa::IndexRel>(op)) {
    return D3D10_SB_OPERAND_INDEX_RELATIVE;
  }

  if (isa<dxsa::IndexRelImm>(op)) {
    return D3D10_SB_OPERAND_INDEX_IMMEDIATE32_PLUS_RELATIVE;
  }

  return emitError(op->getLoc(), "invalid index type");
}

class Writer {
public:
  Writer(raw_ostream &output) : output(output, endianness::little) {
    initOpcodeMap(opcodeMap);
  }

  LogicalResult emitModule(ModuleOp source) {
    Region &region = source.getRegion();
    if (!region.hasOneBlock()) {
      return emitError(region.getLoc(), "region should contain only one block");
    }

    for (auto &op : region.front()) {
      if (auto inst = dyn_cast<dxsa::Instruction>(op)) {
        if (failed(emitInstruction(inst))) {
          return failure();
        }
      }
    }
    return success();
  }

  // Emit an instruction and all its operands recursively.
  // FIXME: add extended instructions
  LogicalResult emitInstruction(dxsa::Instruction inst) {
    // Buffer all tokens for an instruction, so we can fixup
    // instruction length before emitting tokens to the output.
    buffer.clear();

    auto opcodeIt = opcodeMap.find(inst.getMnemonic());
    if (opcodeIt == opcodeMap.end()) {
      return emitError(inst.getLoc(), "unknown mnemonic");
    }

    // First token is an opcode and length. Length is unknown until we
    // process all operands.
    uint32_t opcode = opcodeIt->second;
    uint32_t token = ENCODE_D3D10_SB_OPCODE_TYPE(opcode);
    buffer.push_back(token);

    for (Value value : inst.getOperands()) {
      Operation *op = value.getDefiningOp();
      if (!op) {
        return emitError(value.getLoc(), "undefined operand");
      }

      auto result =
          llvm::TypeSwitch<Operation &, LogicalResult>(*op)
              .Case<dxsa::Operand>([this](auto op) { return emitOperand(op); })
              .Case<dxsa::OperandImm>(
                  [this](auto op) { return emitOperandImm(op); })
              .Default([this](auto &op) {
                return emitError(op.getLoc(), "unexpected operand kind");
              });
      if (failed(result)) {
        return result;
      }
    }

    // Fixup instruction length after all operands are accumulated in
    // the buffer.
    buffer[0] |= ENCODE_D3D10_SB_TOKENIZED_INSTRUCTION_LENGTH(buffer.size());
    for (uint32_t token : buffer) {
      output.write(token);
    }

    return success();
  }

  // Emit an operand and all its indices recursively.
  LogicalResult emitOperand(dxsa::Operand op) {
    uint32_t token = ENCODE_D3D10_SB_OPERAND_TYPE(op.getType());

    // Encode swizzle, mask, or one component selection.
    switch (op.getNumComponents()) {
    case 0: {
      token |=
          ENCODE_D3D10_SB_OPERAND_NUM_COMPONENTS(D3D10_SB_OPERAND_0_COMPONENT);
      break;
    }
    case 1: {
      token |=
          ENCODE_D3D10_SB_OPERAND_NUM_COMPONENTS(D3D10_SB_OPERAND_1_COMPONENT);
      break;
    }
    case 4: {
      token |=
          ENCODE_D3D10_SB_OPERAND_NUM_COMPONENTS(D3D10_SB_OPERAND_4_COMPONENT);
      if (auto mask = op.getMask()) {
        token |= ENCODE_D3D10_SB_OPERAND_4_COMPONENT_SELECTION_MODE(
            D3D10_SB_OPERAND_4_COMPONENT_MASK_MODE);
        token |= ENCODE_D3D10_SB_OPERAND_4_COMPONENT_MASK(*mask);
      } else if (auto swizzle = op.getSwizzle()) {
        SmallVector<uint32_t, 4> values;
        for (const APInt &v : *swizzle) {
          values.push_back(v.getZExtValue());
        }
        if (values.size() != 4) {
          return emitError(op.getLoc(), "invalid number of swizzle values");
        }
        token |= ENCODE_D3D10_SB_OPERAND_4_COMPONENT_SELECTION_MODE(
            D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE_MODE);
        token |= ENCODE_D3D10_SB_OPERAND_4_COMPONENT_SWIZZLE(
            values[0], values[1], values[2], values[3]);
        break;
      } else if (auto one = op.getOne()) {
        token |= ENCODE_D3D10_SB_OPERAND_4_COMPONENT_SELECTION_MODE(
            D3D10_SB_OPERAND_4_COMPONENT_SELECT_1_MODE);
        token |= ENCODE_D3D10_SB_OPERAND_4_COMPONENT_SELECT_1(*one);
        break;
      }
      break;
    }
    default: {
      return emitError(op.getLoc(), "invalid number of components");
    }
    }

    // Operand token encodes types and number of indices that follow
    // it.
    token |= ENCODE_D3D10_SB_OPERAND_INDEX_DIMENSION(op.getNumOperands());
    uint32_t dim = 0;
    for (Value value : op.getOperands()) {
      Operation *index = value.getDefiningOp();
      if (!index) {
        return emitError(value.getLoc(), "index must be defined");
      }

      FailureOr<uint32_t> repr = getIndexRepresentation(index);
      if (failed(repr)) {
        return failure();
      }
      token |= ENCODE_D3D10_SB_OPERAND_INDEX_REPRESENTATION(dim, *repr);
      dim += 1;
    }

    buffer.push_back(token);

    // Indices follow the operand token.
    for (Value value : op.getOperands()) {
      Operation *index = value.getDefiningOp();
      if (!index) {
        return emitError(value.getLoc(), "index must be defined");
      }

      auto result = llvm::TypeSwitch<Operation &, LogicalResult>(*index)
                        .Case<dxsa::IndexImm>(
                            [this](auto op) { return emitIndexImm(op); })
                        .Case<dxsa::IndexRel>(
                            [this](auto op) { return emitIndexRel(op); })
                        .Case<dxsa::IndexRelImm>(
                            [this](auto op) { return emitIndexRelImm(op); })
                        .Default([this](auto &op) {
                          return emitError(op.getLoc(), "invalid index type");
                        });

      if (failed(result)) {
        return result;
      }
    }

    return success();
  }

  // Emit an immediate operand. Unlike register operands, immediate
  // operands do not have indices. They are encoded as an operand
  // followed by N immediate values for each component.
  LogicalResult emitOperandImm(dxsa::OperandImm op) {
    auto attr = dyn_cast<DenseIntElementsAttr>(op.getImm());
    if (!attr) {
      return emitError(op.getLoc(), "invalid immediate operand");
    }

    uint32_t token = 0;

    Type elementType = attr.getType().getElementType();
    if (elementType.isInteger(32)) {
      token |= ENCODE_D3D10_SB_OPERAND_TYPE(D3D10_SB_OPERAND_TYPE_IMMEDIATE32);
    } else if (elementType.isInteger(64)) {
      token |= ENCODE_D3D10_SB_OPERAND_TYPE(D3D10_SB_OPERAND_TYPE_IMMEDIATE64);
    } else {
      return emitError(op.getLoc(), "invalid immediate operand type");
    }

    // Split immediates into tokens. 32 bit immediate values are
    // encoded as is, and 64 bit immediates are split into high and
    // low 32 bit parts.
    SmallVector<uint32_t, 4> values;
    for (const APInt &v : attr) {
      uint64_t bits = v.getZExtValue();
      if (v.getBitWidth() == 64) {
        values.push_back(bits >> 32);
      }
      values.push_back(bits);
    }

    if (values.size() == 1) {
      token |=
          ENCODE_D3D10_SB_OPERAND_NUM_COMPONENTS(D3D10_SB_OPERAND_1_COMPONENT);
    } else if (values.size() == 4) {
      token |=
          ENCODE_D3D10_SB_OPERAND_NUM_COMPONENTS(D3D10_SB_OPERAND_4_COMPONENT);
    } else {
      return emitError(op.getLoc(),
                       "immediate operand should be either 1- or 4- component");
    }

    buffer.push_back(token);
    llvm::append_range(buffer, values);

    return success();
  }

  // Emit an immediate index. Its type is encoded into the operand, so
  // here we only emit the value as tokens.
  LogicalResult emitIndexImm(dxsa::IndexImm op) {
    auto attr = dyn_cast<IntegerAttr>(op.getImm());
    if (!attr) {
      return emitError(op.getLoc(), "invalid immediate index");
    }

    uint64_t value = attr.getInt();
    if (attr.getType().isInteger(32)) {
      buffer.push_back(value);
      return success();
    }

    if (attr.getType().isInteger(64)) {
      buffer.push_back(value >> 32);
      buffer.push_back(value);
      return success();
    }

    return emitError(op.getLoc(), "invalid type of an immediate index");
  }

  // Emit an operand used as an index.
  LogicalResult emitIndexRel(dxsa::IndexRel index) {
    Operation *def = index.getOperand().getDefiningOp();
    if (!def) {
      return emitError(index.getLoc(), "index must be defined");
    }

    auto operand = dyn_cast<dxsa::Operand>(*def);
    if (!operand) {
      return emitError(def->getLoc(), "invalid index relative operand");
    }

    // Recursively emit an operand, which may also have other indices.
    return emitOperand(operand);
  }

  // Emit an index as an operand + a 32 bit immediate offset.
  LogicalResult emitIndexRelImm(dxsa::IndexRelImm index) {
    Operation *def = index.getOperand().getDefiningOp();
    if (!def) {
      return emitError(index.getLoc(), "index must be defined");
    }

    auto operand = dyn_cast<dxsa::Operand>(*def);
    if (!operand) {
      return emitError(def->getLoc(), "invalid index relative operand");
    }

    if (failed(emitOperand(operand))) {
      return failure();
    }

    buffer.push_back(index.getImm());
    return success();
  }

private:
  std::vector<uint32_t> buffer;
  support::endian::Writer output;
  OpcodeMap opcodeMap;
};

namespace mlir::dxsa {
LogicalResult exportModuleToDxsaBinary(ModuleOp source, raw_ostream &output) {
  Writer writer(output);
  return writer.emitModule(source);
}
} // namespace mlir::dxsa
