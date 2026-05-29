// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxsa.dcl_function_table' op attribute 'index' failed to satisfy constraint: 32-bit signless integer attribute whose value is non-negative}}
dxsa.dcl_function_table -1, <functions = [0, 1]>

// -----

// expected-error@+1 {{'dxsa.dcl_function_table' op function body index must not be negative, got -1}}
dxsa.dcl_function_table 1, <functions = [0, -1]>
