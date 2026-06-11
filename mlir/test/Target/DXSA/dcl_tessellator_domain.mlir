// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_tessellator_domain.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_tessellator_domain.bin | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_tessellator_domain domain_isoline
// CHECK-NEXT:   dxsa.dcl_tessellator_domain domain_tri
// CHECK-NEXT:   dxsa.dcl_tessellator_domain domain_quad
// CHECK-NEXT: }
