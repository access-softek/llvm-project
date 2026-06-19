// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.utof r<0>, r<1>
0x05000056, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001

// CHECK-NEXT:   dxsa.utof r<0, <x>>, r<1, <y, z, w, y>>
0x05000056, 0x00100012, 0x00000000, 0x00100796, 0x00000001

// CHECK-NEXT:   dxsa.utof precise <x, y> r<0>, r<1>
0x05180056, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001

// CHECK-NEXT: }
