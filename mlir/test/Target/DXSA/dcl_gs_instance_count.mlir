// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_gs_instance_count.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_gs_instance_count 1
// CHECK-NEXT:   dxsa.dcl_gs_instance_count 32
// CHECK-NEXT: }
