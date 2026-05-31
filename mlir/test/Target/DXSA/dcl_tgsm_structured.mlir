// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_tgsm_structured.bin | FileCheck %s

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_tgsm_structured <type = thread_group_shared_memory, components = 0, index = [0]>, 16, 64
// CHECK-NEXT: }
