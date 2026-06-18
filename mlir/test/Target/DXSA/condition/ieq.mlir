// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.ieq r<0>, r<1>, r<2>
0x07000020, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001, 0x00100e46, 0x00000002

// CHECK-NEXT:   dxsa.ieq r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
0x07000020, 0x00100012, 0x00000000, 0x00100796, 0x00000001, 0x00100006, 0x00000002

// CHECK-NEXT:   dxsa.ieq precise <x, y, z, w> r<0>, r<1>, r<2>
0x07780020, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001, 0x00100e46, 0x00000002

// CHECK-NEXT: }
