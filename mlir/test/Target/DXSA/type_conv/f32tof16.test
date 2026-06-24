// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.f32tof16 r<0>, r<1>
0x05000082, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001

// CHECK-NEXT:   dxsa.f32tof16 r<0>, -r<1>
0x06000082, 0x001000f2, 0x00000000, 0x80100e46, 0x00000041, 0x00000001

// CHECK-NEXT:   dxsa.f32tof16 r<0, <x>>, r<1, <y, z, w, y>>
0x05000082, 0x00100012, 0x00000000, 0x00100796, 0x00000001

// CHECK-NEXT:   dxsa.f32tof16 precise <x, y> r<0>, r<1>
0x05180082, 0x001000f2, 0x00000000, 0x00100e46, 0x00000001

// CHECK-NEXT: }
