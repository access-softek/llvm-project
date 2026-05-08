// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output_topology.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_output_topology pointlist
// CHECK-NEXT:   dxsa.dcl_output_topology linestrip
// CHECK-NEXT:   dxsa.dcl_output_topology trianglestrip
// CHECK-NEXT: }
