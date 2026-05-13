// RUN: mlir-opt %s -verify-diagnostics

// expected-error@+1 {{invalid number of swizzle values}}
%1 = dxsa.operand {num_components = 4 : i32, swizzle = dense<[0, 1, 2, 3, 4]> : vector<5xi32>, type = 1 : i32}
