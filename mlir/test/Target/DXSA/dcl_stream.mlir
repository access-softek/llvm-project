// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_stream.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_stream.bin | mlir-opt --verify-roundtrip

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_stream 0
// CHECK-NEXT:   dxsa.dcl_stream 3
// CHECK-NEXT: }
