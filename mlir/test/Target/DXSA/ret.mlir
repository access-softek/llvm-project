// RUN: mlir-translate --import-dxsa-bin %S/inputs/ret.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/ret.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.instruction "ret"
// CHECK-NEXT: }

module {
  dxsa.instruction "ret"
}
