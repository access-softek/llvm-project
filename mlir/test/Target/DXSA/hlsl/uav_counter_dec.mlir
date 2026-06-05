// RUN: mlir-translate --import-dxsa-bin %S/inputs/uav_counter_dec.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
