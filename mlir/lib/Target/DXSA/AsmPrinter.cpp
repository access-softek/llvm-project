#include "mlir/Dialect/DXSA/IR/DXSA.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Location.h"
#include "mlir/Target/DXSA/BinaryParser.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DebugLog.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/LogicalResult.h"
#include "llvm/Support/NativeFormatting.h"

#include "d3d12TokenizedProgramFormat.hpp"

#define DEBUG_TYPE "export-dxsa-bin"

using namespace mlir;
using namespace llvm;

// FIXME: remove OpcodeClass from BinaryParser
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

using OpClassMap = llvm::DenseMap<StringRef, OpcodeClass>;

static void initOpClassMap(OpClassMap &opcodes) {
#define SET(OpCode, Name, NumOperands, PrecMask, OpClass)                      \
  opcodes[Name] = OpClass;
#include "InstrInfo.def"
#undef SET
}

static void printComponent(raw_ostream &outs, uint32_t v) {
  switch (v) {
  case D3D10_SB_4_COMPONENT_X:
    outs << 'x';
    break;
  case D3D10_SB_4_COMPONENT_Y:
    outs << 'y';
    break;
  case D3D10_SB_4_COMPONENT_Z:
    outs << 'z';
    break;
  case D3D10_SB_4_COMPONENT_W:
    outs << 'w';
    break;
  }
}

static void printComponentMask(raw_ostream &outs, uint32_t mask) {
  if (mask & D3D10_SB_OPERAND_4_COMPONENT_MASK_X)
    outs << 'x';
  if (mask & D3D10_SB_OPERAND_4_COMPONENT_MASK_Y)
    outs << 'y';
  if (mask & D3D10_SB_OPERAND_4_COMPONENT_MASK_Z)
    outs << 'z';
  if (mask & D3D10_SB_OPERAND_4_COMPONENT_MASK_W)
    outs << 'w';
}

class Printer {
public:
  Printer(raw_ostream &output) : outs(output) { initOpClassMap(opClass); }

  LogicalResult emitModule(ModuleOp source) {
    for (auto &op : *source.getBody()) {
      if (auto inst = dyn_cast<dxsa::Instruction>(op)) {
        if (failed(emitInstruction(inst)))
          return failure();
      }
    }
    return success();
  }

  // Emit an instruction and all its operands recursively.
  // FIXME: add extended instructions
  LogicalResult emitInstruction(dxsa::Instruction inst) {
    outs << inst.getMnemonic();

    if (inst.getOperands().empty()) {
      outs << '\n';
      return success();
    }

    StringRef separator = "\t";
    for (Value value : inst.getOperands()) {
      Operation *op = value.getDefiningOp();
      assert(op && "undefined operand");

      outs << separator;
      separator = ", ";

      auto result =
          llvm::TypeSwitch<Operation &, LogicalResult>(*op)
              .Case<dxsa::Operand>([this](auto &op) { return emitOperand(op); })
              .Case<dxsa::OperandImm>([this, &inst](auto &op) {
                return emitOperandImm(op, opClass[inst.getMnemonic()]);
              })
              .Default([](auto &op) {
                return emitError(op.getLoc(), "unexpected operand kind");
              });

      if (failed(result))
        return result;
    }
    outs << '\n';
    return success();
  }

  // Emit an operand and all its indices recursively.
  LogicalResult emitOperand(dxsa::Operand op) {
    // First index of register-like operands is printed without subscript
    // syntax: `r0`, `o0`, cb0
    //
    // Some operations must use subscript syntax for the first index:
    // `icb[0]`
    //
    bool firstIndexIsSubscript = false;

    switch (op.getType()) {
    case D3D10_SB_OPERAND_TYPE_TEMP:
      outs << 'r';
      break;
    case D3D10_SB_OPERAND_TYPE_INPUT: {
      outs << 'v';
      break;
    }
    case D3D10_SB_OPERAND_TYPE_OUTPUT: {
      outs << 'o';
      break;
    }
    case D3D10_SB_OPERAND_TYPE_INDEXABLE_TEMP: {
      outs << 'x';
      break;
    }
    case D3D10_SB_OPERAND_TYPE_SAMPLER: {
      outs << 's';
      break;
    }
    case D3D10_SB_OPERAND_TYPE_RESOURCE: {
      outs << 't';
      break;
    }
    case D3D10_SB_OPERAND_TYPE_CONSTANT_BUFFER: {
      outs << "cb";
      break;
    }
    case D3D10_SB_OPERAND_TYPE_IMMEDIATE_CONSTANT_BUFFER: {
      outs << "icb";
      firstIndexIsSubscript = true;
      break;
    }
    case D3D10_SB_OPERAND_TYPE_LABEL:
    case D3D10_SB_OPERAND_TYPE_INPUT_PRIMITIVEID:
    case D3D10_SB_OPERAND_TYPE_OUTPUT_DEPTH:
      return emitError(op->getLoc(), "unsupported operand type");
    case D3D10_SB_OPERAND_TYPE_NULL: {
      outs << "NULL";
      break;
    }
    case D3D10_SB_OPERAND_TYPE_RASTERIZER:
    case D3D10_SB_OPERAND_TYPE_OUTPUT_COVERAGE_MASK:
    case D3D11_SB_OPERAND_TYPE_STREAM:
    case D3D11_SB_OPERAND_TYPE_FUNCTION_BODY:
    case D3D11_SB_OPERAND_TYPE_FUNCTION_TABLE:
    case D3D11_SB_OPERAND_TYPE_INTERFACE:
    case D3D11_SB_OPERAND_TYPE_FUNCTION_INPUT:
    case D3D11_SB_OPERAND_TYPE_FUNCTION_OUTPUT:
      return emitError(op->getLoc(), "unsupported operand type");
    case D3D11_SB_OPERAND_TYPE_OUTPUT_CONTROL_POINT_ID: {
      outs << "vOutputControlPointID";
      break;
    }
    case D3D11_SB_OPERAND_TYPE_INPUT_FORK_INSTANCE_ID:
    case D3D11_SB_OPERAND_TYPE_INPUT_JOIN_INSTANCE_ID:
    case D3D11_SB_OPERAND_TYPE_INPUT_CONTROL_POINT:
    case D3D11_SB_OPERAND_TYPE_OUTPUT_CONTROL_POINT:
    case D3D11_SB_OPERAND_TYPE_INPUT_PATCH_CONSTANT:
    case D3D11_SB_OPERAND_TYPE_INPUT_DOMAIN_POINT:
    case D3D11_SB_OPERAND_TYPE_THIS_POINTER:
    case D3D11_SB_OPERAND_TYPE_UNORDERED_ACCESS_VIEW:
    case D3D11_SB_OPERAND_TYPE_THREAD_GROUP_SHARED_MEMORY:
    case D3D11_SB_OPERAND_TYPE_INPUT_THREAD_ID:
    case D3D11_SB_OPERAND_TYPE_INPUT_THREAD_GROUP_ID:
    case D3D11_SB_OPERAND_TYPE_INPUT_THREAD_ID_IN_GROUP:
    case D3D11_SB_OPERAND_TYPE_INPUT_COVERAGE_MASK:
    case D3D11_SB_OPERAND_TYPE_INPUT_THREAD_ID_IN_GROUP_FLATTENED:
    case D3D11_SB_OPERAND_TYPE_INPUT_GS_INSTANCE_ID:
    case D3D11_SB_OPERAND_TYPE_OUTPUT_DEPTH_GREATER_EQUAL:
    case D3D11_SB_OPERAND_TYPE_OUTPUT_DEPTH_LESS_EQUAL:
    case D3D11_SB_OPERAND_TYPE_CYCLE_COUNTER:
    case D3D11_SB_OPERAND_TYPE_OUTPUT_STENCIL_REF:
    case D3D11_SB_OPERAND_TYPE_INNER_COVERAGE:
      return emitError(op->getLoc(), "unsupported operand type");
    }

    bool printSubscript = firstIndexIsSubscript;
    for (Value value : op.getOperands()) {
      Operation *index = value.getDefiningOp();
      assert(index && "undefined index");

      // Non-immediate indices always use subscript syntax.
      if (!isa<dxsa::IndexImm>(*index))
        printSubscript = true;

      if (printSubscript)
        outs << '[';

      if (failed(emitIndex(index)))
        return failure();

      if (printSubscript)
        outs << ']';

      // First index may be a register number (immediate), but other
      // indices are always subscripts.
      printSubscript = true;
    }

    if (auto swizzle = op.getSwizzle()) {
      outs << '.';
      for (const APInt &v : *swizzle)
        printComponent(outs, v.getZExtValue());
    } else if (auto mask = op.getMask()) {
      outs << '.';
      printComponentMask(outs, *mask);
    } else if (auto one = op.getOne()) {
      outs << '.';
      printComponent(outs, *one);
    }

    return success();
  }

  // Emit an immediate operand. Its format (integer or floating point) depends
  // on the instruction it is used for.
  LogicalResult emitOperandImm(dxsa::OperandImm op, OpcodeClass kind) {
    auto attr = cast<DenseIntElementsAttr>(op.getImm());
    auto elementType = cast<IntegerType>(attr.getType().getElementType());

    // FIXME: how 64-bit immediates should be printed?
    if (elementType.getWidth() != 32)
      return emitError(op.getLoc(), "unsupported immediate operand type");

    // FIXME: encode OperandImm with the correct type in MLIR
    bool isInt = false;
    switch (kind) {
    case D3D10_SB_INT_OP:
    case D3D10_SB_UINT_OP:
    case D3D10_SB_BIT_OP:
      isInt = true;
      break;
    default:
      break;
    };

    bool printVec = attr.getNumElements() > 1 || !isInt;

    if (printVec)
      outs << "l(";

    interleaveComma(attr, outs, [isInt, this](const APInt &v) {
      uint32_t bits = v.getZExtValue();
      if (isInt)
        outs << bits;
      else
        write_double(outs, llvm::bit_cast<float>(bits), FloatStyle::Fixed, 6);
    });

    if (printVec)
      outs << ")";

    return success();
  }

  LogicalResult emitIndex(Operation *op) {
    return llvm::TypeSwitch<Operation &, LogicalResult>(*op)
        .Case<dxsa::IndexImm>(
            [this](auto index) { return emitIndexImm(index); })
        .Case<dxsa::IndexRel>(
            [this](auto index) { return emitIndexRel(index); })
        .Case<dxsa::IndexRelImm>(
            [this](auto index) { return emitIndexRelImm(index); })
        .Default([this](auto &op) {
          return emitError(op.getLoc(), "invalid index kind");
        });
  }

  // Emit an immediate index.
  LogicalResult emitIndexImm(dxsa::IndexImm op) {
    auto imm = cast<IntegerAttr>(op.getImm()).getInt();
    outs << imm;
    return success();
  }

  // Emit an operand used as an index.
  LogicalResult emitIndexRel(dxsa::IndexRel index) {
    auto operand = cast<dxsa::Operand>(index.getOperand().getDefiningOp());

    // Recursively emit an operand, which may also have other indices.
    return emitOperand(operand);
  }

  // Emit an index as an operand + a 32 bit immediate offset.
  LogicalResult emitIndexRelImm(dxsa::IndexRelImm index) {
    auto operand = cast<dxsa::Operand>(index.getOperand().getDefiningOp());

    if (failed(emitOperand(operand)))
      return failure();

    outs << " + " << index.getImm();
    return success();
  }

private:
  raw_ostream &outs;
  OpClassMap opClass;
};

namespace mlir::dxsa {
LogicalResult exportModuleToDxsa(ModuleOp source, raw_ostream &output) {
  Printer printer(output);
  return printer.emitModule(source);
}
} // namespace mlir::dxsa
