// RUN: mlir-translate --import-dxsa-bin %S/inputs/ret.bin | FileCheck %s
// RUN: mlir-translate --export-dxsa-bin %s -o %t.bin
// RUN: mlir-translate --import-dxsa-bin %t.bin | FileCheck %s
// RUN: diff %t.bin %S/inputs/ret.bin

// CHECK:      module {
// CHECK-NEXT:   dxsa.instruction "ret"
// CHECK-NEXT: }

module {
  dxsa.instruction "ret"
}
