// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxbc.sync' op uav_global and uav_group are mutually exclusive}}
dxbc.sync <uav_global|uav_group>
