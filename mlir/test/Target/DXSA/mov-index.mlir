// RUN: mlir-translate --import-dxsa-bin %S/inputs/mov-index.bin | FileCheck %s
// RUN: mlir-translate --export-dxsa-bin %s -o %t.bin
// RUN: mlir-translate --import-dxsa-bin %t.bin | FileCheck %s
// RUN: diff %t.bin %S/inputs/mov-index.bin

// mov o0.xyzw, v[r0.x][0].xyzw

// CHECK: module {
// CHECK-NEXT:   %0 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %1 = dxsa.operand %0 {mask = 240 : i32, num_components = 4 : i32, type = 2 : i32}
// CHECK-NEXT:   %2 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %3 = dxsa.operand %2 {num_components = 4 : i32, one = 0 : i32, type = 0 : i32}
// CHECK-NEXT:   %4 = dxsa.index.rel %3
// CHECK-NEXT:   %5 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %6 = dxsa.operand %4, %5 {num_components = 4 : i32, swizzle = dense<[0, 1, 2, 3]> : vector<4xi32>, type = 1 : i32}
// CHECK-NEXT:   dxsa.instruction "mov" %1, %6
// CHECK-NEXT: }

module {
  %0 = dxsa.index.imm {imm = 0 : i32}
  %1 = dxsa.operand %0 {mask = 240 : i32, num_components = 4 : i32, type = 2 : i32}
  %2 = dxsa.index.imm {imm = 0 : i32}
  %3 = dxsa.operand %2 {num_components = 4 : i32, one = 0 : i32, type = 0 : i32}
  %4 = dxsa.index.rel %3
  %5 = dxsa.index.imm {imm = 0 : i32}
  %6 = dxsa.operand %4, %5 {num_components = 4 : i32, swizzle = dense<[0, 1, 2, 3]> : vector<4xi32>, type = 1 : i32}
  dxsa.instruction "mov" %1, %6
}
