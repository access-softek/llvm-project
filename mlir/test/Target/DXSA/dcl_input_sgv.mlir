// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input_sgv.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_input_sgv <type = input, components = 4, mask = <x>, index = [0]>, <vertexID>
// CHECK-NEXT:   dxsa.dcl_input_sgv <type = input, components = 4, mask = <y>, index = [0]>, <instanceID>
// CHECK-NEXT:   dxsa.dcl_input_sgv <type = input, components = 4, mask = <z>, index = [1]>, <vertexID>
// CHECK-NEXT:   dxsa.dcl_input_sgv <type = input, components = 4, mask = <w>, index = [1]>, <instanceID>
// CHECK-NEXT: }
