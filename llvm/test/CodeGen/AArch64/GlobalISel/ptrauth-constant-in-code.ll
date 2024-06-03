; RUN: llc < %s -mtriple aarch64-elf -mattr=+pauth -global-isel \
; RUN:   -verify-machineinstrs -global-isel-abort=1 | FileCheck %s

@g = external global i32
@g_weak = extern_weak global i32
@g_strong_def = dso_local constant i32 42

define i8* @test_global_zero_disc() {
; CHECK-LABEL: test_global_zero_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    paciza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret

  ret ptr ptrauth (ptr @g, i32 0)
}

define i8* @test_global_offset_zero_disc() {
; CHECK-LABEL: test_global_offset_zero_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    add     x16, x16, #16
; CHECK-NEXT:    pacdza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret

  ret ptr ptrauth (i8* getelementptr (i8, ptr @g, i64 16), i32 2)
}

; For large offsets, materializing it can take up to 3 add instructions.
; We limit the offset to 32-bits.  We theoretically could support up to
; 64 bit offsets, but 32 bits Ought To Be Enough For Anybody.

define i8* @test_global_big_offset_zero_disc() {
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

  ret ptr ptrauth (i8* getelementptr (i8, ptr @g, i64 add (i64 2147483648, i64 65537)), i32 2)
}

define i8* @test_global_disc() {
; CHECK-LABEL: test_global_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    mov     x17, #42                        // =0x2a
; CHECK-NEXT:    pacia   x16, x17
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret

  ret ptr ptrauth (ptr @g, i32 0, i64 42)
}

@g.ref.da.42.addr = dso_local constant ptr ptrauth (ptr @g, i32 2, i64 42, ptr @g.ref.da.42.addr)

define i8* @test_global_addr_disc() {
; CHECK-LABEL: test_global_addr_disc:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp x8, g.ref.da.42.addr
; CHECK-NEXT:    add x8, x8, :lo12:g.ref.da.42.addr
; CHECK-NEXT:    adrp x16, :got:g
; CHECK-NEXT:    ldr x16, [x16, :got_lo12:g]
; CHECK-NEXT:    mov x17, x8
; CHECK-NEXT:    movk x17, #42, lsl #48
; CHECK-NEXT:    pacda x16, x17
; CHECK-NEXT:    mov x0, x16
; CHECK-NEXT:    ret

  ret ptr ptrauth (ptr @g, i32 2, i64 42, ptr @g.ref.da.42.addr)
}

define i8* @test_global_process_specific() {
; CHECK-LABEL: test_global_process_specific:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, :got:g
; CHECK-NEXT:    ldr     x16, [x16, :got_lo12:g]
; CHECK-NEXT:    pacizb  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  ret ptr ptrauth (ptr @g, i32 1)
}

; weak symbols can't be assumed to be non-nil. Use $auth_ptr$ stub slot always.
; The alternative is to emit a null-check here, but that'd be redundant with
; whatever null-check follows in user code.

define i8* @test_global_weak() {
; CHECK-LABEL: test_global_weak:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x0, g_weak$auth_ptr$ia$42
; CHECK-NEXT:    ldr     x0, [x0, :lo12:g_weak$auth_ptr$ia$42]
; CHECK-NEXT:    ret
  ret ptr ptrauth (ptr @g_weak, i32 0, i64 42)
}

; Non-external symbols don't need to be accessed through the GOT.

define i8* @test_global_strong_def() {
; CHECK-LABEL: test_global_strong_def:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp    x16, g_strong_def
; CHECK-NEXT:    add     x16, x16, :lo12:g_strong_def
; CHECK-NEXT:    pacdza  x16
; CHECK-NEXT:    mov     x0, x16
; CHECK-NEXT:    ret
  ret ptr ptrauth (ptr @g_strong_def, i32 2)
}
