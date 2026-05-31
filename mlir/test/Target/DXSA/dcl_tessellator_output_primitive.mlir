// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_tessellator_output_primitive.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_tessellator_output_primitive output_point
// CHECK-NEXT:   dxsa.dcl_tessellator_output_primitive output_line
// CHECK-NEXT:   dxsa.dcl_tessellator_output_primitive output_triangle_cw
// CHECK-NEXT:   dxsa.dcl_tessellator_output_primitive output_triangle_ccw
// CHECK-NEXT: }
