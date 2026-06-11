// RUN: mlir-translate --import-dxsa-bin %S/inputs/program_header_present.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/program_header_present.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module pixel_shader 5 0 {
// CHECK-NEXT:   dxsa.dcl_temps 4
// CHECK-NEXT: }
