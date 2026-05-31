// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_control_point_count.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_input_control_point_count 1
// CHECK-NEXT:   dxsa.dcl_input_control_point_count 3
// CHECK-NEXT:   dxsa.dcl_input_control_point_count 16
// CHECK-NEXT:   dxsa.dcl_input_control_point_count 32
// CHECK-NEXT: }
