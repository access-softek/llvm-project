// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_ps_sgv.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_ps_sgv.bin | mlir-opt --verify-roundtrip

// CHECK-LABEL: module
module {
  // dcl_input_ps_sgv v0.x, primitiveID
  // CHECK:      %0 = dxsa.index.imm {imm = 0 : i32}
  // CHECK-NEXT: %1 = dxsa.operand %0 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_sgv %1, <primitiveID>

  // dcl_input_ps_sgv v1.x, isFrontFace
  // CHECK-NEXT: %2 = dxsa.index.imm {imm = 1 : i32}
  // CHECK-NEXT: %3 = dxsa.operand %2 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_sgv %3, <isFrontFace>

  // dcl_input_ps_sgv v2.x, sampleIndex
  // CHECK-NEXT: %4 = dxsa.index.imm {imm = 2 : i32}
  // CHECK-NEXT: %5 = dxsa.operand %4 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input_ps_sgv %5, <sampleIndex>
}
