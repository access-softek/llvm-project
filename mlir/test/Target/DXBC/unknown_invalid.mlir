// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxbc.unknown' op tokens must not be empty}}
dxbc.unknown <tokens = []>
