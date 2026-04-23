// RUN: mlir-translate --import-dxsa-bin %S/inputs/udiv.bin | FileCheck %s
// RUN: mlir-translate --export-dxsa-bin %s -o %t.bin
// RUN: mlir-translate --import-dxsa-bin %t.bin | FileCheck %s
// RUN: diff %t.bin %S/inputs/udiv.bin

// udiv NULL, r0.x, vOutputControlPointID, 4

// CHECK: module {
// CHECK-NEXT:   %0 = dxsa.operand {num_components = 0 : i32, type = 13 : i32}
// CHECK-NEXT:   %1 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %2 = dxsa.operand %1 {mask = 16 : i32, num_components = 4 : i32, type = 0 : i32}
// CHECK-NEXT:   %3 = dxsa.operand  {num_components = 1 : i32, type = 22 : i32}
// CHECK-NEXT:   %4 = dxsa.operand.imm {imm = dense<4> : vector<1xi32>}
// CHECK-NEXT:   dxsa.instruction "udiv" %0, %2, %3, %4
// CHECK-NEXT: }

module {
  %0 = dxsa.operand {num_components = 0 : i32, type = 13 : i32}
  %1 = dxsa.index.imm {imm = 0 : i32}
  %2 = dxsa.operand %1 {mask = 16 : i32, num_components = 4 : i32, type = 0 : i32}
  %3 = dxsa.operand  {num_components = 1 : i32, type = 22 : i32}
  %4 = dxsa.operand.imm {imm = dense<4> : vector<1xi32>}
  dxsa.instruction "udiv" %0, %2, %3, %4
}
