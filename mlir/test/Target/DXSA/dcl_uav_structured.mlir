// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_uav_structured.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_uav_structured <id = 0, struct_byte_stride = 4>
// CHECK-NEXT:   dxsa.dcl_uav_structured <id = 1, struct_byte_stride = 16>, <flags =  globallyCoherent>
// CHECK-NEXT:   dxsa.dcl_uav_structured <id = 2, struct_byte_stride = 32>, <flags =  hasOrderPreservingCounter>
// CHECK-NEXT:   dxsa.dcl_uav_structured <id = 3, struct_byte_stride = 64>, <flags =  globallyCoherent|hasOrderPreservingCounter>
// CHECK-NEXT:   dxsa.dcl_uav_structured <id = 0, struct_byte_stride = 32, lbound = 0, ubound = 3, space = 1>
// CHECK-NEXT: }
