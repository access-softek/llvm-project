// RUN: mlir-translate --import-dxsa-bin %S/inputs/ret.bin -o %t.mlir
// RUN: FileCheck %s --input-file %t.mlir
// RUN: mlir-translate --export-dxsa-bin %t.mlir -o %t.bin
// RUN: mlir-translate --import-dxsa-bin %t.bin | FileCheck %s
// RUN: diff %t.bin %S/inputs/ret.bin
// RUN: mlir-translate --export-dxsa %t.mlir -o - | FileCheck %s --check-prefix ASM

// ASM: ret

// CHECK:      module {
// CHECK-NEXT:   dxsa.instruction "ret"
// CHECK-NEXT: }

module {
  dxsa.instruction "ret"
}
