// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_uav_raw.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_uav_raw <id = 0>
// CHECK-NEXT:   dxsa.dcl_uav_raw <id = 1>, <flags =  globallyCoherent>
// CHECK-NEXT:   dxsa.dcl_uav_raw <id = 2>, <flags =  globallyCoherent|rasterizerOrdered>
// CHECK-NEXT:   dxsa.dcl_uav_raw <id = 0, lbound = 0, ubound = 3, space = 1>
// CHECK-NEXT: }
