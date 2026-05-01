// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_indexable_temp.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_indexable_temp x0[1], 1
// CHECK-NEXT:   dxsa.dcl_indexable_temp x1[23], 2
// CHECK-NEXT:   dxsa.dcl_indexable_temp x2[16], 4
// CHECK-NEXT:   dxsa.dcl_indexable_temp x7[4096], 4
// CHECK-NEXT: }
