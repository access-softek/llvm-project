; RUN: llvm-extract -S -func test_fn %s | FileCheck %s

@test_gv = external global i32
@test_gv.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @test_gv, i32 2, i64 0, i64 0 }, section "llvm.ptrauth"

; CHECK: @test_gv = external global i32
; CHECK: @test_gv.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @test_gv, i32 2, i64 0, i64 0 }, section "llvm.ptrauth"

define ptr @test_fn() {
  ret ptr @test_gv.ptrauth
}
