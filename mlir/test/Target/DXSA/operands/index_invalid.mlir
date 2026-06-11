// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// An index immediate must be 32- or 64-bit; other widths are rejected.
// expected-error@+1 {{unsupported index type: 'i17'}}
dxsa.add r<0>, v<42 : i17>, r<2>

// -----

// expected-error@+1 {{unsupported index type: 'i43'}}
dxsa.add r<0>, cb<[1, 2 : i43]>, r<2>

// -----

// A non-integer index type is rejected at parse time.
// expected-error@+1 {{invalid kind of type specified: expected builtin.integer}}
dxsa.add r<0>, v<42 : f32>, r<2>
