// RUN: mlir-translate --import-dxsa-bin %S/inputs/add.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/add.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.add r<0>, r<1>, r<2>
// CHECK-NEXT: dxsa.add_sat r<0>, r<1>, r<2>
// CHECK-NEXT: dxsa.add r<0>, r<1>, l(0x3F800000, 0x40000000, 0x40400000, 0x40800000)
// CHECK-NEXT: dxsa.add r<0>, l(0x3F800000, 0x40000000, 0x40400000, 0x40800000), l(0x40A00000, 0x40C00000, 0x40E00000, 0x41000000)
// CHECK-NEXT: dxsa.add r<0>, l(0x3F800000, 0x40000000, 0x40400000, 0x40800000), r<2>
// CHECK-NEXT: dxsa.add r<0>, -r<1>, |r<2>|
// CHECK-NEXT: dxsa.add r<0>, r<1, <x>>, r<2>
// CHECK-NEXT: dxsa.add r<0>, r<1>, d(0x3FF0000000000000, 0x4000000000000000)
// CHECK-NEXT: dxsa.add r<0>, v<r<1, <x>>>, r<2>
// CHECK-NEXT: dxsa.add r<0>, cb<[0, 2 + r<1, <x>>], vector>, r<2>
// CHECK-NEXT: dxsa.add o<0>, r<1>, r<2>
// CHECK-NEXT: dxsa.add null<vector>, r<1>, r<2>
// CHECK-NEXT: dxsa.add r<0>, vPrim, r<2>
// CHECK-NEXT: dxsa.add r<0, <x>>, r<1>, r<2>
// CHECK-NEXT: dxsa.add r<0>, r<1, <x, x, x, x>>, r<2>
