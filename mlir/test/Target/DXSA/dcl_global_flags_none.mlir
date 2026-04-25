// RUN: not mlir-translate --import-dxsa-bin %S/inputs/dcl_global_flags_none.bin 2>&1 | FileCheck %s

// CHECK: 'dxsa.dcl_global_flags' op expected at least one global flag to be set
