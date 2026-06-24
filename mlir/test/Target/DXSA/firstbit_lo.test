// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.firstbit_lo o<0>, v<0, <y, x, x, x>>
0x05000088, 0x001020F2, 0x00000000, 0x00101016, 0x00000000,
// CHECK-NEXT: }
