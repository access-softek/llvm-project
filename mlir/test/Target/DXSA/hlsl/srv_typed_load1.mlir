// RUN: mlir-translate --import-dxsa-bin %S/inputs/srv_typed_load1.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
