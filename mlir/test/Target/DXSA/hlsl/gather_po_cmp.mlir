// RUN: mlir-translate --import-dxsa-bin %S/inputs/gather_po_cmp.bin | FileCheck %s

// FIXME: fix mlir-translate errors and update checks
// CHECK-LABEL: module
