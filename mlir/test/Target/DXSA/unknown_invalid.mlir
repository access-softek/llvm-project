// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxsa.unknown' op tokens must not be empty}}
dxsa.unknown <tokens = []>
