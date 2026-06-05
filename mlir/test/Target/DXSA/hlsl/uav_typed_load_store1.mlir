// RUN: mlir-translate --import-dxsa-bin %S/inputs/uav_typed_load_store1.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
