; RUN: llc --verify-machineinstrs < %s | FileCheck %s

target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430"

define i16 @no_replace() {
; CHECK-LABEL: no_replace
  call void asm sideeffect "", "~{r5}"()
  ret i16 42
; CHECK:     pop r5
; CHECK:     ret
; CHECK:     -- End function
}

; The fact that non-contiguous range of callee-saved registers is spilled
; should not prevent emitting BR for the last contiguous group

define i16 @pops_3_last_regs_and_some_other() {
; CHECK-LABEL: pops_3_last_regs_and_some_other
  call void asm sideeffect "", "~{r5},~{r8},~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     pop r5
; CHECK:     br #__mspabi_func_epilog_3
; CHECK:     -- End function
}
