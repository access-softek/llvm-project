//===- TranslateRegistration.cpp - Register translation for DXBC-----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "mlir/Dialect/DXBC/IR/DXBC.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/IR/OwningOpRef.h"
#include "mlir/Target/DXBC/BinaryParser.h"
#include "mlir/Tools/mlir-translate/Translation.h"

using namespace mlir;

namespace mlir {
void registerFromDxbcBinTranslation() {
  TranslateToMLIRRegistration registration{
      "import-dxbc-bin", "Translate DXBC binary to MLIR",
      [](llvm::SourceMgr &sourceMgr,
         MLIRContext *context) -> OwningOpRef<Operation *> {
        return dxbc::deserialize(sourceMgr, context);
      },
      [](DialectRegistry &registry) { registry.insert<dxbc::DXBCDialect>(); }};
}

void registerFromDxbcHexTranslation() {
  TranslateToMLIRRegistration registration{
      "import-dxbc-hex", "Translate a DXBC hex DWORD listing to MLIR",
      [](llvm::SourceMgr &sourceMgr,
         MLIRContext *context) -> OwningOpRef<Operation *> {
        return dxbc::deserializeHex(sourceMgr, context);
      },
      [](DialectRegistry &registry) { registry.insert<dxbc::DXBCDialect>(); }};
}

void registerToDxbcBinTranslation() {
  TranslateFromMLIRRegistration registration{
      "export-dxbc-bin", "Translate MLIR to DXBC binary",
      [](ModuleOp source, raw_ostream &output) {
        return dxbc::serialize(source, output);
      },
      [](DialectRegistry &registry) { registry.insert<dxbc::DXBCDialect>(); }};
}
} // namespace mlir
