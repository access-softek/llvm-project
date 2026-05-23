// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxsa.dcl_index_range' op operand must be an input or output register, got temp}}
dxsa.dcl_index_range <type = temp, components = 4, mask = <x, y, z, w>, index = [0]>, 3

// -----

// expected-error@+1 {{attribute 'count' failed to satisfy constraint: 32-bit signless integer attribute whose value is positive}}
dxsa.dcl_index_range <type = input, components = 4, mask = <x, y, z, w>, index = [0]>, 0
