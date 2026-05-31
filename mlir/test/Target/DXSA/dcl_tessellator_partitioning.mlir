// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_tessellator_partitioning.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_tessellator_partitioning partitioning_integer
// CHECK-NEXT:   dxsa.dcl_tessellator_partitioning partitioning_pow2
// CHECK-NEXT:   dxsa.dcl_tessellator_partitioning partitioning_fractional_odd
// CHECK-NEXT:   dxsa.dcl_tessellator_partitioning partitioning_fractional_even
// CHECK-NEXT: }
