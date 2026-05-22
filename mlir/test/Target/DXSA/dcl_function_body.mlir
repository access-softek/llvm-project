// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_function_body.bin | FileCheck %s

// CHECK-LABEL: module

// dcl_function_body fb1
// CHECK: dxsa.dcl_function_body 1
