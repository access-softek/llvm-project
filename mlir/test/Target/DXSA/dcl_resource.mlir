// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_resource.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_resource.bin | mlir-opt --verify-roundtrip

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_resource <id = 0>, <dim = buffer>, <x = unorm, y = snorm, z = sint, w = uint>
// CHECK-NEXT:   dxsa.dcl_resource <id = 1>, <dim = texture1d>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 2>, <dim = texture1darray>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 3>, <dim = texture2d>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 4>, <dim = texture2darray>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 5>, <dim = texture2dms, sample_count = 4>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 6>, <dim = texture2dmsarray, sample_count = 8>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 7>, <dim = texture3d>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 8>, <dim = texturecube>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 9>, <dim = texturecubearray>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT:   dxsa.dcl_resource <id = 0, lbound = 0, ubound = 3, space = 1>, <dim = texture3d>, <x = float, y = float, z = float, w = float>
// CHECK-NEXT: }
