// RUN: mlir-translate --import-dxsa-bin %S/inputs/precise.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/precise.bin | mlir-opt --verify-roundtrip

// The precise modifier is a per-output-component mask; it carries the
// `{x, y, z, w}` subset that must stay non-refactorable, and combines with
// the saturate variant (`add_sat`) independently.

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.add r<0>, r<1>, r<2>
// CHECK-NEXT:   dxsa.add precise <x, y, z, w> r<0>, r<1>, r<2>
// CHECK-NEXT:   dxsa.add precise <x, y> r<0>, r<1>, r<2>
// CHECK-NEXT:   dxsa.add_sat precise <x> r<0>, r<1>, r<2>
// CHECK-NEXT: }
