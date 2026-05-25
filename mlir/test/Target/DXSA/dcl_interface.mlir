// RUN: mlir-translate --import-dxsa-bin %S/inputs/dcl_interface.bin | FileCheck %s

// CHECK-LABEL: module

// CHECK-NEXT: dxsa.dcl_interface 0, <access = dynamic, array_length = 253, table_length = 1, tables = [0, 1]>
// CHECK-NEXT: dxsa.dcl_interface 0, <access = immediate, array_length = 253, table_length = 1, tables = [0, 1]>