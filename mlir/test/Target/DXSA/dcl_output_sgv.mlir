// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output_sgv.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_output_sgv.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_output_sgv <type = output, components = 4, mask = <x>, index = [0]>, <primitiveID>
// CHECK-NEXT: }
