; TODO: we probably should rename this file

; RUN: llc -mtriple aarch64 -O3 -o - %s | FileCheck %s

; Check code references.

define i8* @test_global_zero_disc() #0 {
; CHECK-LABEL: test_global_zero_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    paciza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g.ptrauth.ia.0 to i8*
  ret i8* %tmp0
}

define i8* @test_global_offset_zero_disc() #0 {
; CHECK-LABEL: test_global_offset_zero_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    add     x16, x16, #16
; CHECK-NEXT:    pacdza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g.offset.ptrauth.da.0 to i8*
  ret i8* %tmp0
}

; For large offsets, materializing it can take up to 3 add instructions.
; We limit the offset to 32-bits.  We theoretically could support up to
; 64 bit offsets, but 32 bits Ought To Be Enough For Anybody, and that's
; the limit for the relocation addend anyway.
; But we never use the stub and relocation because of dyld shared cache
; encoding constraints.

define i8* @test_global_big_offset_zero_disc() #0 {
; CHECK-LABEL: test_global_big_offset_zero_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    add     x16, x16, #1
; CHECK-NEXT:    add     x16, x16, #16, lsl #12          // =65536
; CHECK-NEXT:    add     x16, x16, #128, lsl #24         // =2147483648
; CHECK-NEXT:    pacdza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g.big_offset.ptrauth.da.0 to i8*
  ret i8* %tmp0
}

define i8* @test_global_disc() #0 {
; CHECK-LABEL: test_global_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    mov     x17, #42                        // =0x2a
; CHECK-NEXT:    pacia   x16, x17
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g.ptrauth.ia.42 to i8*
  ret i8* %tmp0
}

define i8* @test_global_addr_disc() #0 {
; CHECK-LABEL: test_global_addr_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x8, g.ref.da.42.addr
; CHECK-NEXT:    add     x8, x8, :lo12:g.ref.da.42.addr
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    mov     x17, x8
; CHECK-NEXT:    movk    x17, #42, lsl #48
; CHECK-NEXT:    pacda   x16, x17
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g.ptrauth.da.42.addr to i8*
  ret i8* %tmp0
}

; Since we don't support static materialization on ELF, there is no difference
; between process-specific and non process-specific keys. Keep this test to
; make things common between ELF and MachO

define i8* @test_global_process_specific() #0 {
; CHECK-LABEL: test_global_process_specific:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    pacizb  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g.ptrauth.ib.0 to i8*
  ret i8* %tmp0
}

define i8* @test_global_weak() #0 {
; CHECK-LABEL: test_global_weak:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x0, g_weak$auth_ptr$ia$42
; CHECK-NEXT:    ldr     x0, [x0, :lo12:g_weak$auth_ptr$ia$42]
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g_weak.ptrauth.ia.42 to i8*
  ret i8* %tmp0
}

; FIXME: if we define this after function definition, the function body
; transorms to a single call to foo_weak via bl.
@foo_weak.ptrauth.ia.0 = private constant { ptr, i32, i64, i64 } { ptr @foo_weak, i32 0, i64 0, i64 0 }, section "llvm.ptrauth"

define void @test_foo_weak() #0 {
; CHECK-LABEL: test_foo_weak:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x8, foo_weak$auth_ptr$ia$0
; CHECK-NEXT:    ldr     x8, [x8, :lo12:foo_weak$auth_ptr$ia$0]
; CHECK-NEXT:    cbz     x8, .LBB7_2
; CHECK-NEXT:  // %bb.1:
; CHECK-NEXT:    pacibsp
; CHECK-NEXT:    str     x30, [sp, #-16]!
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w30, -16
; CHECK-NEXT:    bl      foo_weak
; CHECK-NEXT:    ldr     x30, [sp], #16
; CHECK-NEXT:    retab
; CHECK-NEXT:  .LBB7_2:
; CHECK-NEXT:    ret
  br i1 icmp ne (ptr @foo_weak.ptrauth.ia.0, ptr null), label %if.then, label %if.end
if.then:
  tail call void @foo_weak.ptrauth.ia.0() [ "ptrauth"(i32 0, i64 0) ]
  br label %if.end
if.end:
  ret void
}

define i8* @test_global_strong_def() #0 {
; CHECK-LABEL: test_global_strong_def:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, g_strong_def
; CHECK-NEXT:    add     x16, x16, :lo12:g_strong_def
; CHECK-NEXT:    pacdza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  %tmp0 = bitcast { i8*, i32, i64, i64 }* @g_strong_def.ptrauth.da.0 to i8*
  ret i8* %tmp0
}

; Check global references.

@g = external global i32

@g_weak = extern_weak global i32

declare extern_weak void @foo_weak() #0

; For ELF, we should specify dso_local explicitly for strong definition, otherwise the symbol would be assumed preemptible, and GOT load would be used
@g_strong_def = dso_local constant i32 42

; CHECK-LABEL:   .globl g.ref.ia.0
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  g.ref.ia.0:
; CHECK-NEXT:    .xword 5
; CHECK-NEXT:    .xword g@AUTH(ia,0)
; CHECK-NEXT:    .xword 6

@g.ptrauth.ia.0 = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g to i8*), i32 0, i64 0, i64 0 }, section "llvm.ptrauth"

@g.ref.ia.0 = constant { i64, i8*, i64 } { i64 5, i8* bitcast ({ i8*, i32, i64, i64 }* @g.ptrauth.ia.0 to i8*), i64 6 }

; CHECK-LABEL:   .globl g.ref.ia.42
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  g.ref.ia.42:
; CHECK-NEXT:    .xword g@AUTH(ia,42)

@g.ptrauth.ia.42 = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g to i8*), i32 0, i64 0, i64 42 }, section "llvm.ptrauth"

@g.ref.ia.42 = dso_local constant i8* bitcast ({ i8*, i32, i64, i64 }* @g.ptrauth.ia.42 to i8*)

; CHECK-LABEL:   .globl g.ref.ib.0
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  g.ref.ib.0:
; CHECK-NEXT:    .xword 5
; CHECK-NEXT:    .xword g@AUTH(ib,0)
; CHECK-NEXT:    .xword 6

@g.ptrauth.ib.0 = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g to i8*), i32 1, i64 0, i64 0 }, section "llvm.ptrauth"

@g.ref.ib.0 = constant { i64, i8*, i64 } { i64 5, i8* bitcast ({ i8*, i32, i64, i64 }* @g.ptrauth.ib.0 to i8*), i64 6 }

; CHECK-LABEL:   .globl g.ref.da.42.addr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  g.ref.da.42.addr:
; CHECK-NEXT:    .xword g@AUTH(da,42,addr)

@g.ptrauth.da.42.addr = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g to i8*), i32 2, i64 ptrtoint (i8** @g.ref.da.42.addr to i64), i64 42 }, section "llvm.ptrauth"

@g.ref.da.42.addr = dso_local constant i8* bitcast ({ i8*, i32, i64, i64 }* @g.ptrauth.da.42.addr to i8*)

; CHECK-LABEL:   .globl g.offset.ref.da.0
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  g.offset.ref.da.0:
; CHECK-NEXT:    .xword (g+16)@AUTH(da,0)

@g.offset.ptrauth.da.0 = private constant { i8*, i32, i64, i64 } { i8* getelementptr (i8, i8* bitcast (i32* @g to i8*), i64 16), i32 2, i64 0, i64 0 }, section "llvm.ptrauth"

@g.offset.ref.da.0 = dso_local constant i8* bitcast ({ i8*, i32, i64, i64 }* @g.offset.ptrauth.da.0 to i8*)

; CHECK-LABEL:   .globl g.big_offset.ref.da.0
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  g.big_offset.ref.da.0:
; CHECK-NEXT:    .xword (g+2147549185)@AUTH(da,0)

@g.big_offset.ptrauth.da.0 = private constant { i8*, i32, i64, i64 } { i8* getelementptr (i8, i8* bitcast (i32* @g to i8*), i64 add (i64 2147483648, i64 65537)), i32 2, i64 0, i64 0 }, section "llvm.ptrauth"

@g.big_offset.ref.da.0 = dso_local constant i8* bitcast ({ i8*, i32, i64, i64 }* @g.big_offset.ptrauth.da.0 to i8*)

; CHECK-LABEL:   .globl g.weird_ref.da.0
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  g.weird_ref.da.0:
; CHECK-NEXT:    .xword (g+16)@AUTH(da,0)

@g.weird_ref.da.0 = constant i64 ptrtoint (i8* bitcast (i64* inttoptr (i64 ptrtoint (i8* bitcast ({ i8*, i32, i64, i64 }* @g.offset.ptrauth.da.0 to i8*) to i64) to i64*) to i8*) to i64)

; CHECK-LABEL: g_weak.ref.ia.42:
; CHECK-NEXT:    .xword g_weak@AUTH(ia,42)

@g_weak.ptrauth.ia.42 = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g_weak to i8*), i32 0, i64 0, i64 42 }, section "llvm.ptrauth"

@g_weak.ref.ia.42 = dso_local constant i8* bitcast ({ i8*, i32, i64, i64 }* @g_weak.ptrauth.ia.42 to i8*)

; CHECK-LABEL:   .globl g_strong_def.ref.da.0
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  g_strong_def.ref.da.0:
; CHECK-NEXT:    .xword g_strong_def@AUTH(da,0)

@g_strong_def.ptrauth.da.0 = private constant { i8*, i32, i64, i64 } { i8* bitcast (i32* @g_strong_def to i8*), i32 2, i64 0, i64 0 }, section "llvm.ptrauth"

@g_strong_def.ref.da.0 = dso_local constant i8* bitcast ({ i8*, i32, i64, i64 }* @g_strong_def.ptrauth.da.0 to i8*)

; CHECK-LABEL: foo_weak$auth_ptr$ia$0:
; CHECK-NEXT:    .xword  foo_weak@AUTH(ia,0)
; CHECK-LABEL: g_weak$auth_ptr$ia$42:
; CHECK-NEXT:    .xword  g_weak@AUTH(ia,42)

attributes #0 = { "target-features"="+pauth" "ptrauth-auth-traps" "ptrauth-calls" "ptrauth-returns" }
