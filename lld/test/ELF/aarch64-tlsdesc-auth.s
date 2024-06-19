// REQUIRES: aarch64
// RUN: rm -rf %t && split-file %s %t && cd %t

//--- ok.s

// RUN: llvm-mc -filetype=obj -triple=aarch64-pc-linux -mattr=+pauth ok.s -o ok.o
// RUN: ld.lld --hash-style=sysv -shared ok.o -o ok.so
// RUN: llvm-objdump --no-print-imm-hex -d --no-show-raw-insn ok.so | FileCheck %s
// RUN: llvm-readobj -r -x .got ok.so | FileCheck --check-prefix=REL %s

        .text
        adrp    x0, :tlsdesc_auth:a
        ldr     x16, [x0, :tlsdesc_auth_lo12:a]
        add     x0, x0, :tlsdesc_auth_lo12:a
        autia   x16, x0
        .tlsdesccall a
        blr     x16

// CHECK:      10298: adrp    x0, 0x20000
// CHECK-NEXT: 1029c: ldr     x16, [x0, #872]
// CHECK-NEXT: 102a0: add     x0, x0, #872
// CHECK-NEXT: 102a4: autia   x16, x0
// CHECK-NEXT: 102a8: blr     x16

// Create relocation against local TLS symbols where linker should
// create target specific dynamic TLSDESC relocation where addend is
// the symbol VMA in tls block.

        adrp    x0, :tlsdesc_auth:local1
        ldr     x16, [x0, :tlsdesc_auth_lo12:local1]
        add     x0, x0, :tlsdesc_auth_lo12:local1
        autia   x16, x0
        .tlsdesccall a
        blr     x16

// CHECK:      102ac: adrp    x0, 0x20000
// CHECK-NEXT: 102b0: ldr     x16, [x0, #888]
// CHECK-NEXT: 102b4: add     x0, x0, #888
// CHECK-NEXT: 102b8: autia   x16, x0
// CHECK-NEXT: 102bc: blr     x16

        adrp    x0, :tlsdesc_auth:local2
        ldr     x16, [x0, :tlsdesc_auth_lo12:local2]
        add     x0, x0, :tlsdesc_auth_lo12:local2
        autia   x16, x0
        .tlsdesccall a
        blr     x16

// CHECK:      102c0: adrp    x0, 0x20000
// CHECK-NEXT: 102c4: ldr     x16, [x0, #904]
// CHECK-NEXT: 102c8: add     x0, x0, #904
// CHECK-NEXT: 102cc: autia   x16, x0
// CHECK-NEXT: 102d0: blr     x16

        .section .tbss,"awT",@nobits
        .type   local1,@object
        .p2align 2
local1:
        .word   0
        .size   local1, 4

        .type   local2,@object
        .p2align 3
local2:
        .xword  0
        .size   local2, 8


// R_AARCH64_AUTH_TLSDESC - 0x0 -> start of tls block
// R_AARCH64_AUTH_TLSDESC - 0x8 -> align (sizeof (local1), 8)

// REL:      Relocations [
// REL-NEXT:   Section (4) .rela.dyn {
// REL-NEXT:     0x20378 R_AARCH64_AUTH_TLSDESC - 0x0
// REL-NEXT:     0x20388 R_AARCH64_AUTH_TLSDESC - 0x8
// REL-NEXT:     0x20368 R_AARCH64_AUTH_TLSDESC a 0x0
// REL-NEXT:   }
// REL-NEXT: ]

// REL:      Hex dump of section '.got':
// REL-NEXT: 0x00020368 00000000 00000080 00000000 000000a0
// REL-NEXT: 0x00020378 00000000 00000080 00000000 000000a0
// REL-NEXT: 0x00020388 00000000 00000080 00000000 000000a0
//                                     ^^
//                                     0b10000000 bit 63 address diversity = true, bits 61..60 key = IA
//                                                       ^^
//                                                       0b10100000 bit 63 address diversity = true, bits 61..60 key = DA

//--- err.s

// RUN: llvm-mc -filetype=obj -triple=aarch64-pc-linux -mattr=+pauth err.s -o err.o
// RUN: not ld.lld --hash-style=sysv -shared err.o -o err.so 2>&1 | FileCheck --check-prefix=ERR %s
// ERR: error: both AUTH and non-AUTH TLSDESC entries for 'a' requested, but only one type of TLSDESC entry per symbol is supported
        .text
        adrp    x0, :tlsdesc_auth:a
        ldr     x16, [x0, :tlsdesc_auth_lo12:a]
        add     x0, x0, :tlsdesc_auth_lo12:a
        autia   x16, x0
        .tlsdesccall a
        blr     x16

        adrp    x0, :tlsdesc:a
        ldr     x1, [x0, :tlsdesc_lo12:a]
        add     x0, x0, :tlsdesc_lo12:a
        .tlsdesccall a
        blr     x1
