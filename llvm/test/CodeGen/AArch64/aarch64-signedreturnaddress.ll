; RUN: llc < %s -mtriple=arm64-eabi -asm-verbose=false -mattr=v8.2a | FileCheck %s
; RUN: llc < %s -mtriple=arm64-eabi -asm-verbose=false -mattr=v8.3a | FileCheck %s --check-prefix=CHECKV83
; RUN: llc < %s -mtriple=arm64-eabi -asm-verbose=false -mattr=v8.2a -global-isel=1 -global-isel-abort=1 | FileCheck %s
; RUN: llc < %s -mtriple=arm64-eabi -asm-verbose=false -mattr=v8.3a -global-isel=1 -global-isel-abort=1 | FileCheck %s --check-prefix=CHECKV83

; Armv8.3-A Pointer Authetication requires a special intsruction to strip the
; pointer authentication code from the pointer.
; The XPACLRI instruction assembles to a hint-space instruction before Armv8.3-A
; therefore this instruction can be safely used for any pre Armv8.3-A architectures.
; On Armv8.3-A and onwards XPACI is available so use that instead.

define ptr @retaddr_0() nounwind readnone "sign-return-address"="none" {
entry:
; CHECK-LABEL: retaddr_0:
; CHECK-NEXT:     str     x30, [sp, #-16]!
; CHECK-NEXT:     hint    #7
; CHECK-NEXT:     mov     x0, x30
; CHECK-NEXT:     ldr     x30, [sp], #16
; CHECK-NEXT:     ret
;
; CHECKV83-LABEL: retaddr_0:
; CHECKV83:          mov     x0, x30
; CHECKV83-NEXT:     xpaci   x0
; CHECKV83-NEXT:     ret
  %0 = tail call ptr @llvm.returnaddress(i32 0)
  ret ptr %0
}

define ptr @retaddr_sign_all_0() nounwind readnone "sign-return-address"="all" {
entry:
; CHECK-LABEL: retaddr_sign_all_0:
; CHECK-NEXT:     hint    #25
; CHECK-NEXT:     str     x30, [sp, #-16]!
; CHECK-NEXT:     hint    #7
; CHECK-NEXT:     mov     x0, x30
; CHECK-NEXT:     ldr     x30, [sp], #16
; CHECK-NEXT:     hint    #29
; CHECK-NEXT:     ret
;
; CHECKV83-LABEL: retaddr_sign_all_0:
; CHECKV83-NEXT:     paciasp
; CHECKV83-NEXT:     mov     x0, x30
; CHECKV83-NEXT:     xpaci   x0
; CHECKV83-NEXT:     retaa
  %0 = tail call ptr @llvm.returnaddress(i32 0)
  ret ptr %0
}

; x29 and x30 are saved because @llvm.returnaddress with non-zero argument
; takes frame address internally.

define ptr @retaddr_1() nounwind readnone "sign-return-address"="none" {
entry:
; CHECK-LABEL: retaddr_1:
; CHECK-NEXT:     stp     x29, x30, [sp, #-16]!
; CHECK-NEXT:     mov     x29, sp
; CHECK-NEXT:     ldr     x8, [x29]
; CHECK-NEXT:     ldr     x30, [x8, #8]
; CHECK-NEXT:     hint    #7
; CHECK-NEXT:     mov     x0, x30
; CHECK-NEXT:     ldp     x29, x30, [sp], #16
; CHECK-NEXT:     ret
;
; CHECKV83-LABEL: retaddr_1:
; CHECKV83-NEXT:     stp     x29, x30, [sp, #-16]!
; CHECKV83-NEXT:     mov     x29, sp
; CHECKV83-NEXT:     ldr     x8, [x29]
; CHECKV83-NEXT:     ldr     x0, [x8, #8]
; CHECKV83-NEXT:     xpaci   x0
; CHECKV83-NEXT:     ldp     x29, x30, [sp], #16
; CHECKV83-NEXT:     ret
  %0 = tail call ptr @llvm.returnaddress(i32 1)
  ret ptr %0
}

define ptr @retaddr_sign_all_1() nounwind readnone "sign-return-address"="all" {
entry:
; CHECK-LABEL: retaddr_sign_all_1:
; CHECK-NEXT:     hint    #25
; CHECK-NEXT:     stp     x29, x30, [sp, #-16]!
; CHECK-NEXT:     mov     x29, sp
; CHECK-NEXT:     ldr     x8, [x29]
; CHECK-NEXT:     ldr     x30, [x8, #8]
; CHECK-NEXT:     hint    #7
; CHECK-NEXT:     mov     x0, x30
; CHECK-NEXT:     ldp     x29, x30, [sp], #16
; CHECK-NEXT:     hint    #29
; CHECK-NEXT:     ret
;
; CHECKV83-LABEL: retaddr_sign_all_1:
; CHECKV83-NEXT:     paciasp
; CHECKV83-NEXT:     stp     x29, x30, [sp, #-16]!
; CHECKV83-NEXT:     mov     x29, sp
; CHECKV83-NEXT:     ldr     x8, [x29]
; CHECKV83-NEXT:     ldr     x0, [x8, #8]
; CHECKV83-NEXT:     xpaci   x0
; CHECKV83-NEXT:     ldp     x29, x30, [sp], #16
; CHECKV83-NEXT:     retaa

  %0 = tail call ptr @llvm.returnaddress(i32 1)
  ret ptr %0
}

declare ptr @llvm.returnaddress(i32) nounwind readnone
