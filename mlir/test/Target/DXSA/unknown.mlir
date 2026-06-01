// RUN: mlir-translate --import-dxsa-bin %S/inputs/unknown.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_temps 1
// CHECK-NEXT:   dxsa.unknown <tokens = [0x030007FF, 0xDEADBEEF, 0x12345678]>
// CHECK-NEXT:   dxsa.dcl_temps 2
// CHECK-NEXT:   dxsa.unknown <tokens = [0x00000035, 0x00000004, 0x11111111, 0x22222222]>
// CHECK-NEXT:   dxsa.dcl_temps 3
// CHECK-NEXT:   dxsa.unknown <tokens = [0x03000068, 0x00000005, 0xCAFEBABE]>
// CHECK-NEXT: }
