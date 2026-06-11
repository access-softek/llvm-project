// RUN: mlir-translate --import-dxsa-bin %S/inputs/unknown_past_eof.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/unknown_past_eof.bin | mlir-opt --verify-roundtrip

// Opcode declares length 5, but only 3 tokens remain in the file.
// The unknown fallback clamps the span to the actual remainder, never past EOF.

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_temps 1
// CHECK-NEXT:   dxsa.unknown <tokens = [0x050007FF, 0xAAAAAAAA, 0xBBBBBBBB]>
// CHECK-NEXT: }
