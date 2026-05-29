// RUN: mlir-opt %s -split-input-file -verify-diagnostics

module {
  %0 = dxsa.index.imm {imm = 0 : i32}
  %1 = dxsa.index.imm {imm = 0 : i32}
  %2 = dxsa.operand %1 {num_components = 4 : i32, one = 0 : i32, type = 0 : i32}
  %3 = dxsa.index.rel %2
  %4 = dxsa.operand %0, %3 {num_components = 0 : i32, type = 19 : i32}

  // expected-error@+1 {{attribute 'call_site' failed to satisfy constraint: 32-bit signless integer attribute whose value is non-negative}}
  dxsa.interface_call %4, <call_site = -1>
}
