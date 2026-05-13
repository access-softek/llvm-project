// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// OK
%0 = dxsa.operand {num_components = 0 : i32, type = 1 : i32}

// OK
%1 = dxsa.operand {num_components = 1 : i32, type = 1 : i32}

// expected-error@+1 {{invalid number of components}}
%2 = dxsa.operand {num_components = 2 : i32, type = 1 : i32}

// -----

// expected-error@+1 {{invalid number of components}}
%3 = dxsa.operand {num_components = 3 : i32, type = 1 : i32}

// OK
%4 = dxsa.operand {num_components = 4 : i32, type = 1 : i32}

// -----

// expected-error@+1 {{invalid number of components}}
%5 = dxsa.operand {num_components = 5 : i32, type = 1 : i32}
