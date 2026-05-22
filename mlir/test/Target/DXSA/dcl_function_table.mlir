// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_function_table.bin | FileCheck %s

// CHECK-LABEL: module

// dcl_function_table ft1 = {fb0, fb1}
// CHECK: dxsa.dcl_function_table 1, [0, 1]
