// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_index_range.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_index_range <type = input, components = 4, mask = <x, y, z, w>, index = [4]>, 6
// CHECK-NEXT:   dxsa.dcl_index_range <type = output, components = 4, mask = <x>, index = [0]>, 4
// CHECK-NEXT: }
