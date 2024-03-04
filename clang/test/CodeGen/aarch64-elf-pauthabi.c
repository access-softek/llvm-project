// RUN: %clang -target aarch64-linux -S -emit-llvm -o - -mbranch-protection=pauthabi %s                                    | FileCheck %s --check-prefix=ALL
// RUN: %clang -target aarch64-linux -S -emit-llvm -o - -fptrauth-returns %s                                               | FileCheck %s --check-prefix=RET
// RUN: %clang -target aarch64-linux -S -emit-llvm -o - -fptrauth-calls %s                                                 | FileCheck %s --check-prefix=CALL
// RUN: %clang -target aarch64-linux -S -emit-llvm -o - -fptrauth-calls -fptrauth-vtable-pointer-address-discrimination %s | FileCheck %s --check-prefix=VPTRADDR
// RUN: %clang -target aarch64-linux -S -emit-llvm -o - -fptrauth-calls -fptrauth-vtable-pointer-type-discrimination %s    | FileCheck %s --check-prefix=VPTRTYPE
// RUN: %clang -target aarch64-linux -S -emit-llvm -o - -fptrauth-calls -fptrauth-init-fini %s                             | FileCheck %s --check-prefix=INITFINI

// REQUIRES: aarch64-registered-target

// ALL: !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
// ALL: !{i32 1, !"aarch64-elf-pauthabi-version", i32 31}

// RET: !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
// RET: !{i32 1, !"aarch64-elf-pauthabi-version", i32 2}

// CALL: !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
// CALL: !{i32 1, !"aarch64-elf-pauthabi-version", i32 1}

// VPTRADDR: !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
// VPTRADDR: !{i32 1, !"aarch64-elf-pauthabi-version", i32 5}

// VPTRTYPE: !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
// VPTRTYPE: !{i32 1, !"aarch64-elf-pauthabi-version", i32 9}

// INITFINI: !{i32 1, !"aarch64-elf-pauthabi-platform", i32 2}
// INITFINI: !{i32 1, !"aarch64-elf-pauthabi-version", i32 17}

void foo() {}
