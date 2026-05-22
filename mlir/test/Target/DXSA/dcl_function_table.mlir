// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_function_table.bin | FileCheck %s

// CHECK-LABEL: module
// CHECK-NEXT: dxsa.dcl_function_table 1, <functions = [0, 1]>
