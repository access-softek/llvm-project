// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_resource_structured.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_resource_structured <id = 3, struct_byte_stride = 16>
// CHECK-NEXT:   dxsa.dcl_resource_structured <id = 0, struct_byte_stride = 32, lbound = 0, ubound = 3, space = 1>
// CHECK-NEXT: }
