// RUN: mlir-translate --import-dxsa-bin %S/inputs/ubfeu16.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
