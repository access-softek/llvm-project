// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.dcl_output_sgv o<0, <x>>, <primitiveID>
0x04000066, 0x00102012, 0x00000000, 0x00000007

// CHECK-NEXT: }
