//===- DXBCDialect.td -------------------------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// DXBC dialect definition.
//
//===----------------------------------------------------------------------===//

#ifndef DXBC_DIALECT_TD
#define DXBC_DIALECT_TD

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// DXBC dialect definitions
//===----------------------------------------------------------------------===//

def DXBCDialect : Dialect {
  let name = "dxbc";
  let cppNamespace = "::mlir::dxbc";

  let summary = "Types and operations for DXBC dialect";
  let description = [{
    This dialect contains operations and types for DirectX Shader Assembly.
  }];

  let useDefaultTypePrinterParser = 1;
  let useDefaultAttributePrinterParser = 0;
  let extraClassDeclaration = [{
    // The following are defined in DXBCOperand.cpp where GET_ATTRDEF_CLASSES is
    // instantiated, so the generated attribute dispatch helpers are in scope.
    void registerAttributes();
    ::mlir::Attribute parseAttribute(::mlir::DialectAsmParser &parser,
                                     ::mlir::Type type) const override;
    void printAttribute(::mlir::Attribute attr,
                        ::mlir::DialectAsmPrinter &printer) const override;
  }];
}

#endif // DXBC_DIALECT_TD
