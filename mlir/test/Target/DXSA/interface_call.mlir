// RUN: mlir-translate --import-dxsa-bin %S/inputs/interface_call.bin | FileCheck %s

// CHECK-LABEL: module {
// CHECK-NEXT:   %0 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %1 = dxsa.index.imm {imm = 0 : i32}
// CHECK-NEXT:   %2 = dxsa.operand %1 {num_components = 4 : i32, one = 0 : i32, type = 0 : i32}
// CHECK-NEXT:   %3 = dxsa.index.rel %2
// CHECK-NEXT:   %4 = dxsa.operand %0, %3 {num_components = 0 : i32, type = 19 : i32}
// CHECK-NEXT:   dxsa.interface_call %4, <call_site = 0>
// CHECK-NEXT: }
