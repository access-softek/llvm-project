// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.uge r<0>, r<1>, r<2>
0x07000050, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001, 0x00100e46, 0x00000002

// CHECK-NEXT:   dxsa.uge r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
0x07000050, 0x00100012, 0x00000000, 0x00100796, 0x00000001, 0x00100006, 0x00000002

// CHECK-NEXT:   dxsa.uge precise <x, y, z, w> r<0>, r<1>, r<2>
0x07780050, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001, 0x00100e46, 0x00000002

// CHECK-NEXT: }
