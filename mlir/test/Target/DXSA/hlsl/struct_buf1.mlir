// RUN: mlir-translate --import-dxsa-bin %S/inputs/struct_buf1.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
