// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module pixel_shader 5 0 {
0x00000050, 0x00000004,
// CHECK-NEXT:   dxsa.dcl_temps 4
0x02000068, 0x00000004
// CHECK-NEXT: }
