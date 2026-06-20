// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      module {

// CHECK-NEXT:   dxsa.dcl_stream 0
0x0300008f, 0x00110000, 0x00000000

// CHECK-NEXT:   dxsa.dcl_stream 3
0x0300008f, 0x00110000, 0x00000003

// CHECK-NEXT: }
