; RUN: not llc < %s -mtriple aarch64 2>&1 | FileCheck %s

; TODO: we probably want to fail fast in llc to avoid printing invalid values

@g = external global i32

; CHECK: error: AArch64 PAC key ID '4' out of range [0, 3] in llvm.ptrauth global 'g'
; CHECK: error: AArch64 PAC discriminator '65536' out of range [0, 0xFFFF] in llvm.ptrauth global 'g'

; CHECK-LABEL:   .globl g.ref.bad_key
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  g.ref.bad_key:
; CHECK-NEXT:    .xword 5
; CHECK-NEXT:    .xword g@AUTH(<key out of range>,0)
; CHECK-NEXT:    .xword 6

@g.ptrauth.bad_key = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g to i8*), i32 4, i64 0, i64 0 }, section "llvm.ptrauth"

@g.ref.bad_key = constant { i64, i8*, i64 } { i64 5, i8* bitcast ({ i8*, i32, i64, i64 }* @g.ptrauth.bad_key to i8*), i64 6 }

; CHECK-LABEL:   .globl g.ref.bad_disc
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  g.ref.bad_disc:
; CHECK-NEXT:    .xword 5
; CHECK-NEXT:    .xword g@AUTH(ia,0)
; CHECK-NEXT:    .xword 6

@g.ptrauth.bad_disc = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g to i8*), i32 0, i64 0, i64 65536 }, section "llvm.ptrauth"

@g.ref.bad_disc = constant { i64, i8*, i64 } { i64 5, i8* bitcast ({ i8*, i32, i64, i64 }* @g.ptrauth.bad_disc to i8*), i64 6 }
