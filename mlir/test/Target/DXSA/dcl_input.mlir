// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input.bin | FileCheck %s

// CHECK-LABEL: module
module {
  // dcl_input v0.x
  // CHECK:      %0 = dxsa.index.imm {imm = 0 : i32}
  // CHECK-NEXT: %1 = dxsa.operand %0 {mask = 16 : i32, num_components = 4 : i32, type = 1 : i32}
  // CHECK-NEXT: dxsa.dcl_input %1

  // dcl_input vOutputControlPointID
  // CHECK-NEXT: %2 = dxsa.operand {num_components = 1 : i32, type = 22 : i32}
  // CHECK-NEXT: dxsa.dcl_input %2
}
