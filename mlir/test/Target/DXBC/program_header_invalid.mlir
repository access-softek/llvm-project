// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error@+1 {{'dxbc.module' op attribute 'major_version' failed to satisfy constraint: 32-bit signless integer attribute whose minimum value is 0 whose maximum value is 255}}
"dxbc.module"() <{major_version = 256 : i32, minor_version = 0 : i32, program_type = #dxbc<program_type pixel_shader>}> ({
^bb0:
}) : () -> ()

// -----

// expected-error@+1 {{'dxbc.module' op attribute 'minor_version' failed to satisfy constraint: 32-bit signless integer attribute whose minimum value is 0 whose maximum value is 255}}
"dxbc.module"() <{major_version = 5 : i32, minor_version = 256 : i32, program_type = #dxbc<program_type pixel_shader>}> ({
^bb0:
}) : () -> ()

// -----

// expected-error@+1 {{'dxbc.module' op program_type, major_version and minor_version must all be present or all absent}}
"dxbc.module"() <{program_type = #dxbc<program_type pixel_shader>}> ({
^bb0:
}) : () -> ()

// -----

// expected-error@+1 {{'dxbc.module' op program_type, major_version and minor_version must all be present or all absent}}
"dxbc.module"() <{major_version = 5 : i32, program_type = #dxbc<program_type pixel_shader>}> ({
^bb0:
}) : () -> ()

// -----

// expected-error@+1 {{'dxbc.module' op program_type, major_version and minor_version must all be present or all absent}}
"dxbc.module"() <{minor_version = 1 : i32, program_type = #dxbc<program_type pixel_shader>}> ({
^bb0:
}) : () -> ()
