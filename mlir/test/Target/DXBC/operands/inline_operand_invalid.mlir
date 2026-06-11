// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{unknown operand type: `qq`}}
dxbc.add r<0>, qq<0>, r<2>

// -----

// expected-error@+1 {{unknown component: `q`}}
dxbc.add r<0>, r<1, <q>>, r<2>

// -----

// expected-error@+1 {{duplicate component `x` in destination mask}}
dxbc.add r<0, <x, x>>, r<1>, r<2>

// -----

// expected-error@+1 {{duplicate mask}}
dxbc.add r<0, <x>, <y>>, r<1>, r<2>

// -----

// expected-error@+1 {{duplicate swizzle}}
dxbc.add r<0>, r<1, <x>, <y>>, r<2>

// -----

// expected-error@+1 {{duplicate component count}}
dxbc.add r<0>, r<1, scalar, vector>, r<2>

// -----

// expected-error@+1 {{duplicate min precision}}
dxbc.add r<0>, r<1, min16f, min2_8f>, r<2>

// -----

// expected-error@+1 {{duplicate nonuniform}}
dxbc.add r<0>, r<1, nonuniform, nonuniform>, r<2>

// -----

// expected-error@+1 {{duplicate index list}}
dxbc.add r<0>, r<1, 2>, r<2>

// -----

// expected-error@+1 {{swizzle must have 1 or 4 components, got 2}}
dxbc.add r<0>, r<1, <x, y>>, r<2>

// -----

// expected-error@+1 {{duplicate component `x` in destination mask}}
dxbc.add r<0, <x, x, y, z>>, r<1>, r<2>

// -----

// expected-error@+1 {{unexpected keyword in destination operand body: `nonuniform`}}
dxbc.add r<0, nonuniform>, r<1>, r<2>
