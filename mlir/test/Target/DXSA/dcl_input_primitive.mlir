// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_primitive.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_primitive.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_input_primitive point
// CHECK-NEXT:   dxsa.dcl_input_primitive line
// CHECK-NEXT:   dxsa.dcl_input_primitive triangle
// CHECK-NEXT:   dxsa.dcl_input_primitive line_adj
// CHECK-NEXT:   dxsa.dcl_input_primitive triangle_adj
// CHECK-NEXT:   dxsa.dcl_input_primitive patch1
// CHECK-NEXT:   dxsa.dcl_input_primitive patch2
// CHECK-NEXT:   dxsa.dcl_input_primitive patch3
// CHECK-NEXT:   dxsa.dcl_input_primitive patch4
// CHECK-NEXT:   dxsa.dcl_input_primitive patch5
// CHECK-NEXT:   dxsa.dcl_input_primitive patch6
// CHECK-NEXT:   dxsa.dcl_input_primitive patch7
// CHECK-NEXT:   dxsa.dcl_input_primitive patch8
// CHECK-NEXT:   dxsa.dcl_input_primitive patch9
// CHECK-NEXT:   dxsa.dcl_input_primitive patch10
// CHECK-NEXT:   dxsa.dcl_input_primitive patch11
// CHECK-NEXT:   dxsa.dcl_input_primitive patch12
// CHECK-NEXT:   dxsa.dcl_input_primitive patch13
// CHECK-NEXT:   dxsa.dcl_input_primitive patch14
// CHECK-NEXT:   dxsa.dcl_input_primitive patch15
// CHECK-NEXT:   dxsa.dcl_input_primitive patch16
// CHECK-NEXT:   dxsa.dcl_input_primitive patch17
// CHECK-NEXT:   dxsa.dcl_input_primitive patch18
// CHECK-NEXT:   dxsa.dcl_input_primitive patch19
// CHECK-NEXT:   dxsa.dcl_input_primitive patch20
// CHECK-NEXT:   dxsa.dcl_input_primitive patch21
// CHECK-NEXT:   dxsa.dcl_input_primitive patch22
// CHECK-NEXT:   dxsa.dcl_input_primitive patch23
// CHECK-NEXT:   dxsa.dcl_input_primitive patch24
// CHECK-NEXT:   dxsa.dcl_input_primitive patch25
// CHECK-NEXT:   dxsa.dcl_input_primitive patch26
// CHECK-NEXT:   dxsa.dcl_input_primitive patch27
// CHECK-NEXT:   dxsa.dcl_input_primitive patch28
// CHECK-NEXT:   dxsa.dcl_input_primitive patch29
// CHECK-NEXT:   dxsa.dcl_input_primitive patch30
// CHECK-NEXT:   dxsa.dcl_input_primitive patch31
// CHECK-NEXT:   dxsa.dcl_input_primitive patch32
// CHECK-NEXT: }
