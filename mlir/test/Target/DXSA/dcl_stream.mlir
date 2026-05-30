// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_stream.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_stream 0
// CHECK-NEXT:   dxsa.dcl_stream 3
// CHECK-NEXT: }
