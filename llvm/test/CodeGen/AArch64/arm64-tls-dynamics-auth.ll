; RUN: llc -mtriple=arm64-none-linux-gnu -mattr=+pauth -relocation-model=pic \
; RUN:   -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=arm64-none-linux-gnu -mattr=+pauth -relocation-model=pic \
; RUN:   -filetype=obj < %s | llvm-objdump -r - | FileCheck --check-prefix=CHECK-RELOC %s
; RUN: not --crash llc -mtriple=arm64-none-linux-gnu -mattr=+pauth -relocation-model=pic \
; RUN:   -global-isel=1 < %s 2>&1 | FileCheck --check-prefix=CHECK-ERR %s

@general_dynamic_var = external thread_local global i32

define i32 @test_generaldynamic() {
; CHECK-LABEL: test_generaldynamic:

  %val = load i32, ptr @general_dynamic_var
  ret i32 %val

; CHECK: adrp x[[TLSDESC_HI:[0-9]+]], :tlsdesc_auth:general_dynamic_var
; CHECK-NEXT: ldr x16, [x[[TLSDESC_HI]], :tlsdesc_auth_lo12:general_dynamic_var]
; CHECK-NEXT: add x0, x[[TLSDESC_HI]], :tlsdesc_auth_lo12:general_dynamic_var
; CHECK-NEXT: autia x16, x0
; CHECK-NEXT: .tlsdesccall general_dynamic_var
; CHECK-NEXT: blr x16

; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADR_PAGE21
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_LD64_LO12
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADD_LO12
; CHECK-RELOC: R_AARCH64_TLSDESC_CALL

; CHECK-ERR: LLVM ERROR: cannot select: %1:gpr64sp(p0) = G_GLOBAL_VALUE @general_dynamic_var (in function: test_generaldynamic)
}

define ptr @test_generaldynamic_addr() {
; CHECK-LABEL: test_generaldynamic_addr:

  ret ptr @general_dynamic_var

; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADR_PAGE21
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_LD64_LO12
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADD_LO12
; CHECK-RELOC: R_AARCH64_TLSDESC_CALL
}

@local_dynamic_var = external thread_local(localdynamic) global i32

define i32 @test_localdynamic() {
; CHECK-LABEL: test_localdynamic:

  %val = load i32, ptr @local_dynamic_var
  ret i32 %val

; CHECK: adrp x[[TLSDESC_HI:[0-9]+]], :tlsdesc_auth:local_dynamic_var
; CHECK-NEXT: ldr x16, [x[[TLSDESC_HI]], :tlsdesc_auth_lo12:local_dynamic_var]
; CHECK-NEXT: add x0, x[[TLSDESC_HI]], :tlsdesc_auth_lo12:local_dynamic_var
; CHECK-NEXT: autia x16, x0
; CHECK-NEXT: .tlsdesccall local_dynamic_var
; CHECK-NEXT: blr x16
; CHECK: mrs x[[TPIDR:[0-9]+]], TPIDR_EL0
; CHECK: ldr w0, [x[[TPIDR]], x0]

; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADR_PAGE21
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_LD64_LO12
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADD_LO12
; CHECK-RELOC: R_AARCH64_TLSDESC_CALL
}

define ptr @test_localdynamic_addr() {
; CHECK-LABEL: test_localdynamic_addr:

  ret ptr @local_dynamic_var

; CHECK: adrp x[[TLSDESC_HI:[0-9]+]], :tlsdesc_auth:local_dynamic_var
; CHECK-NEXT: ldr x16, [x[[TLSDESC_HI]], :tlsdesc_auth_lo12:local_dynamic_var]
; CHECK-NEXT: add x0, x[[TLSDESC_HI]], :tlsdesc_auth_lo12:local_dynamic_var
; CHECK-NEXT: autia x16, x0
; CHECK-NEXT: .tlsdesccall local_dynamic_var
; CHECK-NEXT: blr x16
; CHECK: mrs x[[TPIDR:[0-9]+]], TPIDR_EL0
; CHECK: add x0, x[[TPIDR]], x0

; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADR_PAGE21
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_LD64_LO12
; CHECK-RELOC: R_AARCH64_AUTH_TLSDESC_ADD_LO12
; CHECK-RELOC: R_AARCH64_TLSDESC_CALL
}

!llvm.module.flags = !{!0, !1}
!0 = !{i32 1, !"aarch64-elf-pauthabi-platform", i32 268435458}
!1 = !{i32 1, !"aarch64-elf-pauthabi-version", i32 128}
