// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_sampler.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_sampler <id = 0, mode = default>
// CHECK-NEXT:   dxsa.dcl_sampler <id = 1, mode = comparison>
// CHECK-NEXT:   dxsa.dcl_sampler <id = 2, mode = mono>
// CHECK-NEXT:   dxsa.dcl_sampler <id = 0, mode = default, lbound = 0, ubound = 3, space = 1>
// CHECK-NEXT: }
