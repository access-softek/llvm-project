// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_input.bin | mlir-opt --verify-roundtrip

// CHECK-LABEL: module
module {
  // dcl_input v0.x
  // CHECK:      dxsa.dcl_input <type = input, components = 4, mask = <x>, index = [0]>

  // dcl_input vOutputControlPointID
  // CHECK-NEXT: dxsa.dcl_input <type = output_control_point_id, components = 1>
}
