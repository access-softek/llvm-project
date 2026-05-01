// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{attribute 'register_count' failed to satisfy constraint: 32-bit signless integer attribute whose value is positive whose maximum value is 4096}}
dxsa.dcl_indexable_temp x0[0], 2

// -----

// expected-error@+1 {{attribute 'register_count' failed to satisfy constraint: 32-bit signless integer attribute whose value is positive whose maximum value is 4096}}
dxsa.dcl_indexable_temp x0[4097], 2

// -----

// expected-error@+1 {{attribute 'num_components' failed to satisfy constraint: 32-bit signless integer attribute whose minimum value is 1 whose maximum value is 4}}
dxsa.dcl_indexable_temp x0[16], 0

// -----

// expected-error@+1 {{attribute 'num_components' failed to satisfy constraint: 32-bit signless integer attribute whose minimum value is 1 whose maximum value is 4}}
dxsa.dcl_indexable_temp x0[16], 5

// -----

// expected-error@+1 {{expected register prefix 'x'}}
dxsa.dcl_indexable_temp r0[16], 4

// -----

// expected-error@+1 {{expected integer after register prefix 'x'}}
dxsa.dcl_indexable_temp xfoo[16], 4
