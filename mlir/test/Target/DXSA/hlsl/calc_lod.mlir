// RUN: mlir-translate --import-dxsa-bin %S/inputs/calc_lod.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
