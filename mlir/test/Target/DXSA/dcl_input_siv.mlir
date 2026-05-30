// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_siv.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_input_siv <type = input, components = 4, mask = <x, y, z, w>, index = [0]>, <position>
// CHECK-NEXT:   dxsa.dcl_input_siv <type = input, components = 4, mask = <x, y, z>, index = [1]>, <clipDistance>
// CHECK-NEXT:   dxsa.dcl_input_siv <type = input, components = 4, mask = <x, y>, index = [2]>, <cullDistance>
// CHECK-NEXT:   dxsa.dcl_input_siv <type = input, components = 4, mask = <x>, index = [3]>, <finalQuadUInsideTessFactor>
// CHECK-NEXT: }
