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
  let useDefaultAttributePrinterParser = 1;
}

#endif // DXBC_DIALECT_TD
