// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_ps_siv.bin | FileCheck %s

// CHECK-LABEL: module
module {
  // dcl_input_ps_siv linear v0.x, position
  // CHECK:      %0 = dxsa.index.imm {imm = 0 : i32}
  // CHECK-NEXT: %1 = dxsa.operand %0 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_siv linear %1, <position>

  // dcl_input_ps_siv linear v1.x, clipDistance
  // CHECK-NEXT: %2 = dxsa.index.imm {imm = 1 : i32}
  // CHECK-NEXT: %3 = dxsa.operand %2 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_siv linear %3, <clipDistance>

  // dcl_input_ps_siv linear v2.x, cullDistance
  // CHECK-NEXT: %4 = dxsa.index.imm {imm = 2 : i32}
  // CHECK-NEXT: %5 = dxsa.operand %4 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_siv linear %5, <cullDistance>

  // dcl_input_ps_siv linear v3.x, renderTargetArrayIndex
  // CHECK-NEXT: %6 = dxsa.index.imm {imm = 3 : i32}
  // CHECK-NEXT: %7 = dxsa.operand %6 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_siv linear %7, <renderTargetArrayIndex>

  // dcl_input_ps_siv linear v4.x, viewportArrayIndex
  // CHECK-NEXT: %8 = dxsa.index.imm {imm = 4 : i32}
  // CHECK-NEXT: %9 = dxsa.operand %8 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_siv linear %9, <viewportArrayIndex>
}
