// RUN: mlir-translate --import-dxsa-bin | FileCheck %s
// RUN: mlir-translate --export-dxsa-bin %s -o - | mlir-translate --import-dxsa-bin - | FileCheck %s

// CHECK: module {
// CHECK-NEXT }

module {
}
