// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_uav_typed.bin | FileCheck %s

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 0, dim =  buffer>, <x =  unorm, y =  snorm, z =  sint, w =  uint>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 1, dim =  texture1d>, <x =  float, y =  float, z =  float, w =  float>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 2, dim =  texture1darray>, <x =  float, y =  float, z =  float, w =  float>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 3, dim =  texture2d>, <x =  float, y =  float, z =  float, w =  float>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 4, dim =  texture2darray>, <x =  float, y =  float, z =  float, w =  float>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 5, dim =  texture3d>, <x =  float, y =  float, z =  float, w =  float>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 6, dim =  texture2d>, <x =  float, y =  float, z =  float, w =  float>, <flags =  globallyCoherent>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 7, dim =  texture2d>, <x =  float, y =  float, z =  float, w =  float>, <flags =  rasterizerOrdered>
// CHECK-NEXT:   dxsa.dcl_uav_typed <id = 0, dim =  texture3d, lbound = 0, ubound = 3, space = 1>, <x =  float, y =  float, z =  float, w =  float>
// CHECK-NEXT: }
