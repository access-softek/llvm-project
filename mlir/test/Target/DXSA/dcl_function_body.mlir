// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_function_body.bin | FileCheck %s
//
// CHECK-LABEL: module
// CHECK-NEXT: dxsa.dcl_function_body 1
