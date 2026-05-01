// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output_control_point_count.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_output_control_point_count 0
// CHECK-NEXT:   dxsa.dcl_output_control_point_count 1
// CHECK-NEXT:   dxsa.dcl_output_control_point_count 4
// CHECK-NEXT:   dxsa.dcl_output_control_point_count 32
// CHECK-NEXT: }
