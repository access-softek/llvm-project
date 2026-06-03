// RUN: mlir-translate --import-dxsa-bin %S/inputs/discard.bin | FileCheck %s

// CHECK: module {
// CHECK-NEXT:   %0 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %1 = dxsa.operand %0 {num_components = 4 : i32, one = 0 : i32, type = 0 : i32}
// CHECK-NEXT:   dxsa.discard <non_zero>, %1
// CHECK-NEXT: }
