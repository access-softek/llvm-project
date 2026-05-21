// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_constant_buffer.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_constant_buffer <id = 0, size = 1>, <immediateIndexed>
// CHECK-NEXT:   dxsa.dcl_constant_buffer <id = 0, size = 4, lbound = 0, ubound = 3, space = 1>, <dynamicIndexed>
// CHECK-NEXT: }
