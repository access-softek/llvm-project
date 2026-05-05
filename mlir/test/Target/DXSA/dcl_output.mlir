// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output.bin | FileCheck %s

// CHECK-LABEL: module
module {
  // dcl_output o0.xyzw
  // CHECK:      %0 = dxsa.index.imm {imm = 0 : i32}
  // CHECK-NEXT: %1 = dxsa.operand %0 {mask = 240 : i32, num_components = 4 : i32, type = 2 : i32}
  // CHECK-NEXT: dxsa.dcl_output %1

  // dcl_output oDepth
  // CHECK-NEXT: %2 = dxsa.operand {num_components = 1 : i32, type = 12 : i32}
  // CHECK-NEXT: dxsa.dcl_output %2
}
