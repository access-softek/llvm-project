// RUN: mlir-translate --import-dxsa-bin %S/inputs/mov.bin | FileCheck %s
// mov r0.x, l(3.000000)

// CHECK:      dxsa.module {
// CHECK-NEXT:   %0 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %1 = dxsa.operand %0 {mask = 16 : i32, num_components = 4 : i32, type = 0 : i32}
// CHECK-NEXT:   %2 = dxsa.operand.imm {imm = dense<1077936128> : vector<1xi32>}
// CHECK-NEXT:   dxsa.instruction "mov" %1, %2
// CHECK-NEXT: }

module {
  %0 = dxsa.index.imm {imm = 0 : i32}
  %1 = dxsa.operand %0 {mask = 16 : i32, num_components = 4 : i32, type = 0 : i32}
  %2 = dxsa.operand.imm {imm = dense<1077936128> : vector<1xi32>}
  dxsa.instruction "mov" %1, %2
}
