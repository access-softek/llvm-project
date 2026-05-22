// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{attribute 'count' failed to satisfy constraint: 32-bit unsigned integer attribute whose value is non-zero}}
dxbc.dcl_hs_join_phase_instance_count 0

// -----

// expected-error@+1 {{negative integer literal not valid for unsigned integer type}}
dxbc.dcl_hs_join_phase_instance_count -1

// -----

// expected-error@+1 {{integer constant out of range for attribute}}
dxbc.dcl_hs_join_phase_instance_count 4294967296
