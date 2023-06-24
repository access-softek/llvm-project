; RUN: llc < %s -verify-machineinstrs -mtriple=aarch64-none-linux-gnu -mattr=+v8.3a -enable-post-misched=0 -aarch64-slh-loads=0 -aarch64-harden-auth=0 | FileCheck %s --check-prefixes=CHECK,PAC-NOHARDEN
; RUN: llc < %s -verify-machineinstrs -mtriple=aarch64-none-linux-gnu -mattr=+v8.3a -enable-post-misched=0 -aarch64-slh-loads=0 -aarch64-harden-auth=1 | FileCheck %s --check-prefixes=CHECK,PAC-HARDEN

define i32 @data_pac(i64 %ptr_as_int) {
entry:
  %auted_i = tail call i64 @llvm.ptrauth.auth(i64 %ptr_as_int, i32 2, i64 0)
  %auted = inttoptr i64 %auted_i to ptr
  %value = load i32, ptr %auted, align 4
  ret i32 %value
; CHECK-LABEL: data_pac:
; CHECK:      // %bb.0:
; CHECK-NEXT:    mov     x16, x0
; CHECK-NEXT:    autdza  x16
; CHECK-NEXT:    ldr     w0, [x16]
; CHECK-NEXT:    ret
}

define i32 @data_pac_hardened(i64 %ptr_as_int) speculative_load_hardening {
entry:
  %auted_i = tail call i64 @llvm.ptrauth.auth(i64 %ptr_as_int, i32 2, i64 0)
  %auted = inttoptr i64 %auted_i to ptr
  %value = load i32, ptr %auted, align 4
  ret i32 %value
; CHECK-LABEL: data_pac_hardened:

; PAC-NOHARDEN:      // %bb.0:
; PAC-NOHARDEN-NEXT:   cmp     sp, #0
; PAC-NOHARDEN-NEXT:   csetm   [[TAINT:x[0-9]+]], ne
; PAC-NOHARDEN-NEXT:   mov     x16, x0
; PAC-NOHARDEN-NEXT:   autdza  x16
; PAC-NOHARDEN-NEXT:   ldr     w0, [x16]
; PAC-NOHARDEN-NEXT:   mov     [[RETTMP:x[0-9]+]], sp
; PAC-NOHARDEN-NEXT:   and     [[RETTMP]], [[RETTMP]], [[TAINT]]
; PAC-NOHARDEN-NEXT:   mov     sp, [[RETTMP]]
; PAC-NOHARDEN-NEXT:   ret

; PAC-HARDEN:        // %bb.0:
; PAC-HARDEN-NEXT:     cmp     sp, #0
; PAC-HARDEN-NEXT:     csetm   [[TAINT:x[0-9]+]], ne
; PAC-HARDEN-NEXT:     mov     x16, x0
; PAC-HARDEN-NEXT:     mov     [[XPACTMP:x[0-9]+]], x16
; PAC-HARDEN-NEXT:     autdza  x16
; PAC-HARDEN-NEXT:     xpacd   [[XPACTMP]]
; PAC-HARDEN-NEXT:     and     x16, x16, [[TAINT]]
; PAC-HARDEN-NEXT:     bic     [[XPACTMP]], [[XPACTMP]], [[TAINT]]
; PAC-HARDEN-NEXT:     orr     x16, x16, [[XPACTMP]]
; PAC-HARDEN-NEXT:     ldr     w0, [x16]
; PAC-HARDEN-NEXT:     mov     [[RETTMP:x[0-9]+]], sp
; PAC-HARDEN-NEXT:     and     [[RETTMP]], [[RETTMP]], [[TAINT]]
; PAC-HARDEN-NEXT:     mov     sp, [[RETTMP]]
; PAC-HARDEN-NEXT:     ret
}

define i64 @lr_pac_hardened(i64 %x) speculative_load_hardening "ptrauth-returns" {
entry:
  tail call void asm sideeffect "", "~{lr}"()
  ret i64 %x
}

declare i64 @llvm.ptrauth.auth(i64, i32 immarg, i64)
