; RUN: opt -passes=globalopt %s -S -o - | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64e-apple-ios13"

; Check that simple references to llvm.ptrauth globals get optimized into
; constant initializers, but more complex ones don't.
; CHECK: @llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @test_init_ptrauth_offset, ptr null }, { i32, ptr, ptr } { i32 65535, ptr @test_init_ptrauth_nested, ptr null }]
@llvm.global_ctors = appending global [3 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @test_init_ptrauth, ptr null }, { i32, ptr, ptr } { i32 65535, ptr @test_init_ptrauth_offset, ptr null }, { i32, ptr, ptr } { i32 65535, ptr @test_init_ptrauth_nested, ptr null }]

@f.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @f, i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

; CHECK: @fp = local_unnamed_addr global ptr @f.ptrauth, align 8
@fp = global ptr null, align 8

; CHECK-NOT: @test_init_ptrauth
define internal void @test_init_ptrauth() {
  store ptr @f.ptrauth, ptr @fp, align 8
  ret void
}

; CHECK: @fp_offset = local_unnamed_addr global ptr null, align 8
@fp_offset = global ptr null, align 8

; CHECK: @fp_nested = local_unnamed_addr global ptr null, align 8
@fp_nested = global ptr null, align 8

; CHECK: @fp_nested_offset = local_unnamed_addr global ptr null, align 8
@fp_nested_offset = global ptr null, align 8

; CHECK: define internal void @test_init_ptrauth_offset()
; CHECK:   store ptr getelementptr inbounds (i8, ptr @f.ptrauth, i64 1), ptr @fp_offset, align 8
define internal void @test_init_ptrauth_offset() {
  store ptr getelementptr inbounds (i8, ptr @f.ptrauth, i64 1), ptr @fp_offset, align 8
  ret void
}

; CHECK: define internal void @test_init_ptrauth_nested()
; CHECK:   store ptr @f.ptrauth, ptr @fp_nested, align 8
; CHECK:   store ptr getelementptr inbounds (i8, ptr @f.ptrauth, i64 1), ptr @fp_nested_offset, align 8
define internal void @test_init_ptrauth_nested() {
  store ptr @f.ptrauth, ptr @fp_nested, align 8
  store ptr getelementptr inbounds (i8, ptr @f.ptrauth, i64 1), ptr @fp_nested_offset, align 8
  ret void
}

declare void @f()
