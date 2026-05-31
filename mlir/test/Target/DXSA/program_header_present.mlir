// RUN: mlir-translate --import-dxsa-bin %S/inputs/program_header_present.bin | FileCheck %s

// CHECK:      dxsa.module pixel_shader 5 0 {
// CHECK-NEXT:   dxsa.dcl_temps 4
// CHECK-NEXT:   dxsa.instruction "ret"
// CHECK-NEXT: }
