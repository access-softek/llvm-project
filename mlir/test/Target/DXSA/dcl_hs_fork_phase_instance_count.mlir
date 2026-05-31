// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_hs_fork_phase_instance_count.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_hs_fork_phase_instance_count 42
// CHECK-NEXT: }
