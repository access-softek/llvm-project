// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// OK
%1 = dxsa.operand.imm {imm = dense<1> : vector<1xi32>}

// expected-error@+1 {{immediate operand should be either 1- or 4- component}}
%2 = dxsa.operand.imm {imm = dense<[1, 2]> : vector<2xi32>}

// -----

// expected-error@+1 {{immediate operand should be either 1- or 4- component}}
%3 = dxsa.operand.imm {imm = dense<[1, 2, 3]> : vector<3xi32>}

// -----

// OK
%4 = dxsa.operand.imm {imm = dense<[1, 2, 3, 4]> : vector<4xi32>}

// expected-error@+1 {{immediate operand should be either 1- or 4- component}}
%5 = dxsa.operand.imm {imm = dense<[1, 2, 3, 4, 5]> : vector<5xi32>}
