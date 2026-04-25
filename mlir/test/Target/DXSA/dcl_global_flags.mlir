// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_global_flags.bin | FileCheck %s

// 9 individual flags (one per instruction), then multi-flag combo, then all flags.

// CHECK:      module {
// CHECK-NEXT:   dxsa.dcl_global_flags <refactoringAllowed>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableDoublePrecision>
// CHECK-NEXT:   dxsa.dcl_global_flags <forceEarlyDepth>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableRawStructured>
// CHECK-NEXT:   dxsa.dcl_global_flags <skipOptimization>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableMinPrecision>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableDoubleExtensions>
// CHECK-NEXT:   dxsa.dcl_global_flags <enableShaderExtensions>
// CHECK-NEXT:   dxsa.dcl_global_flags <allResourcesBound>
// CHECK-NEXT:   dxsa.dcl_global_flags <refactoringAllowed|skipOptimization|allResourcesBound>
// CHECK-NEXT:   dxsa.dcl_global_flags <refactoringAllowed|enableDoublePrecision|forceEarlyDepth|enableRawStructured|skipOptimization|enableMinPrecision|enableDoubleExtensions|enableShaderExtensions|allResourcesBound>
// CHECK-NEXT: }
