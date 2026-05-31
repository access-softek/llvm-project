// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_tgsm_raw.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_tgsm_raw <type = thread_group_shared_memory, components = 0, index = [0]>, 40
// CHECK-NEXT: }
