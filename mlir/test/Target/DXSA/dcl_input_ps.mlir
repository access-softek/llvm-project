// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_ps.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_ps.bin | mlir-opt --verify-roundtrip

// CHECK-LABEL: module
module {
  // dcl_input_ps constant v0.x
  // CHECK:      %0 = dxsa.index.imm {imm = 0 : i32}
  // CHECK-NEXT: %1 = dxsa.operand %0 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps constant %1

  // dcl_input_ps linear v1.x
  // CHECK-NEXT: %2 = dxsa.index.imm {imm = 1 : i32}
  // CHECK-NEXT: %3 = dxsa.operand %2 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps linear %3

  // dcl_input_ps linearCentroid v2.x
  // CHECK-NEXT: %4 = dxsa.index.imm {imm = 2 : i32}
  // CHECK-NEXT: %5 = dxsa.operand %4 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps linearCentroid %5

  // dcl_input_ps linearNoPerspective v3.x
  // CHECK-NEXT: %6 = dxsa.index.imm {imm = 3 : i32}
  // CHECK-NEXT: %7 = dxsa.operand %6 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps linearNoPerspective %7

  // dcl_input_ps linearNoPerspectiveCentroid v4.x
  // CHECK-NEXT: %8 = dxsa.index.imm {imm = 4 : i32}
  // CHECK-NEXT: %9 = dxsa.operand %8 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps linearNoPerspectiveCentroid %9

  // dcl_input_ps linearSample v5.x
  // CHECK-NEXT: %10 = dxsa.index.imm {imm = 5 : i32}
  // CHECK-NEXT: %11 = dxsa.operand %10 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps linearSample %11

  // dcl_input_ps linearNoPerspectiveSample v6.x
  // CHECK-NEXT: %12 = dxsa.index.imm {imm = 6 : i32}
  // CHECK-NEXT: %13 = dxsa.operand %12 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps linearNoPerspectiveSample %13
}
