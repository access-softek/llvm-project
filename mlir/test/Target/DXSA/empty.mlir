// RUN: mlir-translate --import-dxsa-bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT: }
