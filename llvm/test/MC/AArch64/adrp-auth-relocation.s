// RUN: llvm-mc -triple=aarch64-linux-gnu -filetype=obj -o - %s| llvm-readobj -r - | FileCheck %s
// RUN: not llvm-mc -triple=aarch64-linux-gnu_ilp32 -filetype=obj \
// RUN: -o /dev/null %s 2>&1 | FileCheck -check-prefix=CHECK-ILP32 %s
        .text
// This tests that LLVM doesn't think it can deal with the relocation on the ADRP
// itself (even though it knows everything about the relative offsets of sym and
// the adrp instruction) because its value depends on where this object file's
// .text section gets relocated in memory.
        adrp x0, :got_auth:sym

        .global sym
sym:
// CHECK: R_AARCH64_AUTH_ADR_GOT_PAGE sym
// CHECK-ILP32: error: ILP32 ADRP AUTH relocation not supported (LP64 eqv: AUTH_ADR_GOT_PAGE)