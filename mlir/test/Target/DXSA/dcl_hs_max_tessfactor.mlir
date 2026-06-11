// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_hs_max_tessfactor.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_hs_max_tessfactor.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_hs_max_tessfactor 4.200000e+01
// CHECK-NEXT: }
