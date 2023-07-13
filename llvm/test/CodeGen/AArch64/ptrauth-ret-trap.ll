; RUN: llc -mtriple arm64e-apple-darwin -asm-verbose=false -disable-post-ra -o - %s | FileCheck %s

!0 = !{i32 8, !"sign-return-address", i32 1}
!llvm.module.flags = !{!0}

; CHECK-LABEL: _test_tailcall:
; CHECK-NEXT:  paciasp
; CHECK-NEXT:  stp x29, x30, [sp, #-16]!
; CHECK-NEXT:  bl _bar
; CHECK-NEXT:  ldp x29, x30, [sp], #16
; CHECK-NEXT:  autiasp
; CHECK-NEXT:  eor x16, x30, x30, lsl #1
; CHECK-NEXT:  tbz x16, #62, [[GOOD:L.*]]
; CHECK-NEXT:  brk #0xc471
; CHECK-NEXT:  [[GOOD]]:
; CHECK-NEXT:  b _bar
define i32 @test_tailcall() {
  call i32 @bar()
  %c = tail call i32 @bar()
  ret i32 %c
}

; CHECK-LABEL: _test_tailcall_noframe:
; CHECK-NEXT:  b _bar
define i32 @test_tailcall_noframe() {
  %c = tail call i32 @bar()
  ret i32 %c
}

; CHECK-LABEL: _test_tailcall_indirect:
; CHECK:         autiasp
; CHECK:         eor     x16, x30, x30, lsl #1
; CHECK:         tbz     x16, #62, [[GOOD:L.*]]
; CHECK:         brk     #0xc471
; CHECK: [[GOOD]]:
; CHECK:         br      x0
define void @test_tailcall_indirect(void ()* %fptr) {
  call i32 @test_tailcall()
  tail call void %fptr()
  ret void
}

; CHECK-LABEL: _test_tailcall_indirect_in_x9:
; CHECK:         autiasp
; CHECK:         eor     x16, x30, x30, lsl #1
; CHECK:         tbz     x16, #62, [[GOOD:L.*]]
; CHECK:         brk     #0xc471
; CHECK: [[GOOD]]:
; CHECK:         br      x9
define void @test_tailcall_indirect_in_x9(i64* sret(i64) %ret, [8 x i64] %in, void (i64*, [8 x i64])* %fptr) {
  %ptr = alloca i8, i32 16
  call i32 @test_tailcall()
  tail call void %fptr(i64* sret(i64) %ret, [8 x i64] %in)
  ret void
}

; CHECK-LABEL: _test_tailcall_indirect_bti:
; CHECK:         autiasp
; CHECK:         eor     x17, x30, x30, lsl #1
; CHECK:         tbz     x17, #62, [[GOOD:L.*]]
; CHECK:         brk     #0xc471
; CHECK: [[GOOD]]:
; CHECK:         br      x16
define void @test_tailcall_indirect_bti(i64* sret(i64) %ret, [8 x i64] %in, void (i64*, [8 x i64])* %fptr) "branch-target-enforcement"="true" {
  %ptr = alloca i8, i32 16
  call i32 @test_tailcall()
  tail call void %fptr(i64* sret(i64) %ret, [8 x i64] %in)
  ret void
}

declare i32 @bar()
