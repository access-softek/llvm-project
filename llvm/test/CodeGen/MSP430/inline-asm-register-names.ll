; RUN: llc < %s | FileCheck %s
target datalayout = "e-p:16:8:8-i8:8:8-i16:8:8-i32:8:8"
target triple = "msp430-generic-generic"

; Test that correct register names are accepted *inside* inline asm listings.
; Tested with PUSH instruction since it does not support memory operands.

define void @accepted_rN() nounwind {
; CHECK-LABEL: accepted_rN
  call void asm sideeffect "push r0", ""() nounwind
; CHECK: push r0
  call void asm sideeffect "push r1", ""() nounwind
  call void asm sideeffect "push r2", ""() nounwind
  call void asm sideeffect "push r3", ""() nounwind
  call void asm sideeffect "push r4", ""() nounwind
  call void asm sideeffect "push r5", ""() nounwind
  call void asm sideeffect "push r6", ""() nounwind
  call void asm sideeffect "push r7", ""() nounwind
  call void asm sideeffect "push r8", ""() nounwind
  call void asm sideeffect "push r9", ""() nounwind
  call void asm sideeffect "push r10", ""() nounwind
  call void asm sideeffect "push r11", ""() nounwind
  call void asm sideeffect "push r12", ""() nounwind
  call void asm sideeffect "push r13", ""() nounwind
  call void asm sideeffect "push r14", ""() nounwind
  call void asm sideeffect "push r15", ""() nounwind
; CHECK: push r15
  ret void
}

define void @accepted_reg_aliases() nounwind {
; CHECK-LABEL: accepted_reg_aliases
; Ensure register aliases are renamed as expected
call void asm sideeffect "push pc", ""() nounwind
; CHECK: push r0
call void asm sideeffect "push sp", ""() nounwind
; CHECK: push r1
call void asm sideeffect "push sr", ""() nounwind
; CHECK: push r2
call void asm sideeffect "push cg", ""() nounwind
; CHECK: push r3
call void asm sideeffect "push fp", ""() nounwind
; CHECK: push r4
        ret void
}
