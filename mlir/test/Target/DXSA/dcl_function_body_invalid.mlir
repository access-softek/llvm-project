// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxsa.dcl_function_body' op attribute 'index' failed to satisfy constraint: 32-bit signless integer attribute whose value is non-negative}}
dxsa.dcl_function_body -1
