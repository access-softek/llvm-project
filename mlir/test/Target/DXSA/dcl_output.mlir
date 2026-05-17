// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output.bin | FileCheck %s

// CHECK-LABEL: module
module {
  // dcl_output o0.xyzw
  // CHECK:      dxsa.dcl_output <type = output, components = 4, mask = <x, y, z, w>, index = [0]>

  // dcl_output oDepth
  // CHECK-NEXT: dxsa.dcl_output <type = output_depth, components = 1>
}
