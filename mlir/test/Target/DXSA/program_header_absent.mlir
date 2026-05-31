// RUN: mlir-translate --import-dxsa-bin %S/inputs/program_header_absent.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_temps 4
// CHECK-NEXT:   dxsa.instruction "ret"
// CHECK-NEXT: }
