// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_global_flags.bin | FileCheck %s
// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_global_flags.bin | mlir-opt --verify-roundtrip

// 9 individual flags (one per instruction), then multi-flag combo, then all flags.

// CHECK:      dxsa.module {
// CHECK-NEXT:   dxsa.dcl_global_flags <refactoringAllowed>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableDoublePrecisionFloatOps>
// CHECK-NEXT:   dxsa.dcl_global_flags <forceEarlyDepthStencil>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableRawAndStructuredBuffers>
// CHECK-NEXT:   dxsa.dcl_global_flags <skipOptimization>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableMinimumPrecision>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableDoubleExtensions>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableShaderExtensions>
// CHECK-NEXT:   dxsa.dcl_global_flags <allResourcesBound>
// CHECK-NEXT:   dxsa.dcl_global_flags <refactoringAllowed|skipOptimization|allResourcesBound>
// CHECK-NEXT:   dxsa.dcl_global_flags <refactoringAllowed|enableDoublePrecisionFloatOps|forceEarlyDepthStencil|enableRawAndStructuredBuffers|skipOptimization|enableMinimumPrecision|enableDoubleExtensions|enableShaderExtensions|allResourcesBound>
// CHECK-NEXT: }
