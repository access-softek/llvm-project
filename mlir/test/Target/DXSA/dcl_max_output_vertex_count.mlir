// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_max_output_vertex_count.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_max_output_vertex_count.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_max_output_vertex_count 1
// CHECK-NEXT:   dxsa.dcl_max_output_vertex_count 1024
// CHECK-NEXT: }
