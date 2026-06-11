// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output_siv.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output_siv.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_output_siv <type = output, components = 4, mask = <x, y, z, w>, index = [0]>, <position>
// CHECK-NEXT:   dxsa.dcl_output_siv <type = output, components = 4, mask = <x>, index = [1]>, <clipDistance>
// CHECK-NEXT: }
