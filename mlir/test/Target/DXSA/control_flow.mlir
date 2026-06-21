// RUN: mlir-translate --import-dxsa-hex %s | FileCheck %s
// RUN: mlir-translate --import-dxsa-hex %s | mlir-opt --verify-roundtrip

// CHECK:      dxsa.module {

// CHECK-NEXT:   dxsa.break
0x01000002

// CHECK-NEXT:   dxsa.continue
0x01000007

// CHECK-NEXT:   dxsa.default
0x0100000a

// CHECK-NEXT:   dxsa.else
0x01000012

// CHECK-NEXT:   dxsa.endif
0x01000015

// CHECK-NEXT:   dxsa.endloop
0x01000016

// CHECK-NEXT:   dxsa.endswitch
0x01000017

// CHECK-NEXT:   dxsa.loop
0x01000030

// CHECK-NEXT:   dxsa.ret
0x0100003e

// CHECK-NEXT: }
