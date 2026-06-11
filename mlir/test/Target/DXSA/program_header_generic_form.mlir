// RUN: mlir-opt %s --mlir-print-op-generic --verify-roundtrip | FileCheck %s

// CHECK:      "dxsa.module"() <{program_type = #dxsa<program_type pixel_shader>, shader_version = #dxsa.shader_version<5, 0>}> ({
// CHECK-NEXT:   "dxsa.dcl_global_flags"() <{flags = #dxsa.global_flags<refactoringAllowed>}> : () -> ()
// CHECK-NEXT:   "dxsa.add"() <{dst = #dxsa.dst_operand<r<0>>, lhs = #dxsa.src_operand<r<1>>, rhs = #dxsa.src_operand<r<2>>}> : () -> ()
dxsa.module pixel_shader 5 0 {
  dxsa.dcl_global_flags <refactoringAllowed>
  dxsa.add r<0>, r<1>, r<2>
}
