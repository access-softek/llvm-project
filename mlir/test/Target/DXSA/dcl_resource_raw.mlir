// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_resource_raw.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_resource_raw.bin | mlir-opt --verify-roundtrip

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_resource_raw <id = 3>
// CHECK-NEXT:   dxsa.dcl_resource_raw <id = 0, lbound = 0, ubound = 3, space = 1>
// CHECK-NEXT: }
