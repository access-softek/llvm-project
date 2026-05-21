//===--------------- DXSA.cpp - MLIR DXSA Operations ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DXSA/IR/DXSA.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace mlir::dxsa;

#include "mlir/Dialect/DXSA/IR/DXSAOpsDialect.cpp.inc"
#include "mlir/Dialect/DXSA/IR/DXSAOpsEnums.cpp.inc"

void DXSADialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/DXSA/IR/DXSAOps.cpp.inc"
      >();
  addTypes<
#define GET_TYPEDEF_LIST
#include "mlir/Dialect/DXSA/IR/DXSAOpsTypes.cpp.inc"
      >();
  addAttributes<
#define GET_ATTRDEF_LIST
#include "mlir/Dialect/DXSA/IR/DXSAOpsAttributes.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// TableGen'd op method definitions
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "mlir/Dialect/DXSA/IR/DXSAOps.cpp.inc"

//===----------------------------------------------------------------------===//
// Op verifiers
//===----------------------------------------------------------------------===//

LogicalResult DclIndexRange::verify() {
  auto operandType = getOperand().getType();
  if (operandType != InlineOperandType::input &&
      operandType != InlineOperandType::output)
    return emitOpError("operand must be an input or output register, got ")
           << stringifyInlineOperandType(operandType);
  return success();
}

LogicalResult DclHsMaxTessFactor::verify() {
  auto value = getMaxTessfactorAttr().getValue();
  if (!value.isFinite() || value < llvm::APFloat(1.0f) ||
      value > llvm::APFloat(64.0f))
    return emitOpError("MaxTessFactor must be in [1.0, 64.0], got ")
           << value.convertToFloat();
  return success();
}

LogicalResult DclTgsmRaw::verify() {
  auto byteCount = getByteCount();
  if (byteCount % 4 != 0)
    return emitOpError("byte count must be a multiple of 4, got ") << byteCount;
  return success();
}

LogicalResult DclTgsmStructured::verify() {
  auto stride = getStructByteStride();
  auto count = getStructCount();
  if (stride % 4 != 0)
    return emitOpError("struct byte stride must be a multiple of 4, got ")
           << stride;
  auto totalSize = static_cast<uint64_t>(stride) * count;
  if (totalSize > 32768)
    return emitOpError("total size struct_byte_stride * struct_count must "
                       "be <= 32768, got ")
           << totalSize;
  return success();
}

LogicalResult DclConstantBuffer::verify() {
  auto lbound = getLbound();
  auto ubound = getUbound();
  if (lbound && ubound && *lbound > *ubound)
    return emitOpError("expected lbound <= ubound, got lbound=")
           << *lbound << ", ubound=" << *ubound;
  return success();
}

//===----------------------------------------------------------------------===//
// TableGen'd attribute method definitions
//===----------------------------------------------------------------------===//

#define GET_ATTRDEF_CLASSES
#include "mlir/Dialect/DXSA/IR/DXSAOpsAttributes.cpp.inc"

//===----------------------------------------------------------------------===//
// TableGen'd type method definitions
//===----------------------------------------------------------------------===//

#define GET_TYPEDEF_CLASSES
#include "mlir/Dialect/DXSA/IR/DXSAOpsTypes.cpp.inc"
