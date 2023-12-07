; RUN: split-file %s %t && cd %t

;--- MOVaddrPAC.ll

; RUN: not --crash llc -mtriple aarch64-elf MOVaddrPAC.ll 2>&1 | \
; RUN:   FileCheck MOVaddrPAC.ll

; CHECK: LLVM ERROR: pac instructions require ptrauth target feature

@foo.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @foo, i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

define ptr @bar() #0 {
  ret ptr @foo.ptrauth
}

define private void @foo() {
  ret void
}

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }

;--- LOADgotPAC.ll

; RUN: not --crash llc -mtriple aarch64-elf LOADgotPAC.ll 2>&1 | \
; RUN:   FileCheck LOADgotPAC.ll

; CHECK: LLVM ERROR: pac instructions require ptrauth target feature

@foo.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @foo, i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

define ptr @bar() #0 {
  ret ptr @foo.ptrauth
}

declare void @foo()

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }

;--- LOADauthptrgot.ll

; RUN: not --crash llc -mtriple aarch64-elf LOADauthptrgot.ll 2>&1 | \
; RUN:   FileCheck LOADauthptrgot.ll

; CHECK: LLVM ERROR: pac instructions require ptrauth target feature

define i8* @foo() #0 {
  %tmp = bitcast { i8*, i32, i64, i64 }* @g_weak.ptrauth to i8*
  ret i8* %tmp
}

@g_weak = extern_weak global i32
@g_weak.ptrauth = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g_weak to i8*), i32 0, i64 0, i64 0 }, section "llvm.ptrauth"

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }

;--- ptrauth-returns.ll

; RUN: not --crash llc -mtriple aarch64-elf ptrauth-returns.ll 2>&1 | \
; RUN:   FileCheck ptrauth-returns.ll

; CHECK: LLVM ERROR: aarch64 LR authentication requires ptrauth

define i32 @bar() #0 {
  ret i32 42
}

define i32 @foo() {
  %tmp = call i32 @bar()
  ret i32 %tmp
}

attributes #0 = { "ptrauth-returns" "target-cpu"="generic" }

;--- auth-call.ll

; RUN: not --crash llc -mtriple aarch64-elf auth-call.ll 2>&1 | \
; RUN:   FileCheck auth-call.ll

; CHECK: LLVM ERROR: Cannot select:{{.*}}AArch64ISD::AUTH_CALL

define void @bar(ptr %foo) #0 {
  call void %foo() [ "ptrauth"(i32 0, i64 0) ]
  ret void
}

attributes #0 = { "ptrauth-calls" "target-cpu"="generic" }
