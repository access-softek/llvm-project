// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_temps.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_temps 1
// CHECK-NEXT:   dxsa.dcl_temps 16
// CHECK-NEXT:   dxsa.dcl_temps 4096
// CHECK-NEXT: }
