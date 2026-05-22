//===--------------- DXBC.cpp - MLIR DXBC Operations ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DXBC/IR/DXBC.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace mlir::dxbc;

#include "mlir/Dialect/DXBC/IR/DXBCOpsDialect.cpp.inc"
#include "mlir/Dialect/DXBC/IR/DXBCOpsEnums.cpp.inc"

void DXBCDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/DXBC/IR/DXBCOps.cpp.inc"
      >();
  addTypes<
#define GET_TYPEDEF_LIST
#include "mlir/Dialect/DXBC/IR/DXBCOpsTypes.cpp.inc"
      >();
  addAttributes<
#define GET_ATTRDEF_LIST
#include "mlir/Dialect/DXBC/IR/DXBCOpsAttributes.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// TableGen'd op method definitions
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "mlir/Dialect/DXBC/IR/DXBCOps.cpp.inc"

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

//===----------------------------------------------------------------------===//
// TableGen'd attribute method definitions
//===----------------------------------------------------------------------===//

#define GET_ATTRDEF_CLASSES
#include "mlir/Dialect/DXBC/IR/DXBCOpsAttributes.cpp.inc"

//===----------------------------------------------------------------------===//
// TableGen'd type method definitions
//===----------------------------------------------------------------------===//

#define GET_TYPEDEF_CLASSES
#include "mlir/Dialect/DXBC/IR/DXBCOpsTypes.cpp.inc"
