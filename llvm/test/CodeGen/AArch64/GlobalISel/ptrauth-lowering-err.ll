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

define ptr @foo() #0 {
  ret ptr @g_weak.ptrauth
}

@g_weak = extern_weak global i32
@g_weak.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @g_weak, i32 0, i64 0, i64 0 }, section "llvm.ptrauth"

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

;--- tryAuthLoad.ll

; RUN: not --crash llc -mtriple aarch64-elf tryAuthLoad.ll 2>&1 | \
; RUN:   FileCheck tryAuthLoad.ll

; CHECK: LLVM ERROR: pac instructions require ptrauth target feature

define i64 @test(ptr %ptr) {
  %tmp0 = ptrtoint ptr %ptr to i64
  %tmp1 = call i64 @llvm.ptrauth.auth(i64 %tmp0, i32 2, i64 0)
  %tmp2 = inttoptr i64 %tmp1 to ptr
  %tmp3 = load i64, ptr %tmp2
  ret i64 %tmp3
}

declare i64 @llvm.ptrauth.auth(i64, i32, i64)
