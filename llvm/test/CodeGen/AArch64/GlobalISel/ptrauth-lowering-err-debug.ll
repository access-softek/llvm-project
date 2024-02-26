; REQUIRES: asserts
; RUN: split-file %s %t && cd %t

;--- MOVaddrPAC.ll

; RUN: not --crash llc -debug-only=aarch64-expand-hardened-pseudos -mtriple aarch64-elf MOVaddrPAC.ll 2>&1 | \
; RUN:   FileCheck MOVaddrPAC.ll

; CHECK:      Expanding: MOVaddrPAC @foo
; CHECK-NEXT: {{^$}}
; CHECK-NEXT: LLVM ERROR: pac instructions require ptrauth target feature

@foo.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @foo, i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

define ptr @bar() #0 {
  ret ptr @foo.ptrauth
}

define private void @foo() {
  ret void
}

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }

;--- LOADgotPAC.ll

; RUN: not --crash llc -debug-only=aarch64-expand-hardened-pseudos -mtriple aarch64-elf LOADgotPAC.ll 2>&1 | \
; RUN:   FileCheck LOADgotPAC.ll

; CHECK:      Expanding: LOADgotPAC @foo
; CHECK-NEXT: {{^$}}
; CHECK-NEXT: LLVM ERROR: pac instructions require ptrauth target feature

@foo.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @foo, i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

define ptr @bar() #0 {
  ret ptr @foo.ptrauth
}

declare void @foo()

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }

;--- LOADauthptrgot.ll

; RUN: not --crash llc -debug-only=aarch64-expand-hardened-pseudos -mtriple aarch64-elf LOADauthptrgot.ll 2>&1 | \
; RUN:   FileCheck LOADauthptrgot.ll

; CHECK:      Expanding: {{.*}}LOADauthptrgot @g_weak
; CHECK-NEXT: {{^$}}
; CHECK-NEXT: LLVM ERROR: pac instructions require ptrauth target feature

define ptr @foo() #0 {
  ret ptr @g_weak.ptrauth
}

@g_weak = extern_weak global i32
@g_weak.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @g_weak, i32 0, i64 0, i64 0 }, section "llvm.ptrauth"

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }
