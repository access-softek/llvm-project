//===- TranslateRegistration.cpp - Register translation for DXSA-----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "mlir/Dialect/DXSA/IR/DXSA.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/IR/OwningOpRef.h"
#include "mlir/Target/DXSA/BinaryParser.h"
#include "mlir/Tools/mlir-translate/Translation.h"

using namespace mlir;

namespace mlir {
void registerFromDxsaBinTranslation() {
  TranslateToMLIRRegistration registration{
      "import-dxsa-bin", "Translate DXSA binary to MLIR",
      [](llvm::SourceMgr &sourceMgr,
         MLIRContext *context) -> OwningOpRef<Operation *> {
        return dxsa::deserialize(sourceMgr, context);
      },
      [](DialectRegistry &registry) { registry.insert<dxsa::DXSADialect>(); }};
}

void registerToDxsaBinTranslation() {
  TranslateFromMLIRRegistration registration{
      "export-dxsa-bin", "Translate MLIR to DXSA binary",
      [](ModuleOp source, raw_ostream &output) {
        return dxsa::serialize(source, output);
      },
      [](DialectRegistry &registry) { registry.insert<dxsa::DXSADialect>(); }};
}
} // namespace mlir
