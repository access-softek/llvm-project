; RUN: llc --verify-machineinstrs < %s | \
; RUN:     FileCheck --implicit-check-not "{{(pop|ret) }}" %s

; Short epilogue should be emitted for both void and non-void functions.
; Emitting __mspabi_func_epilog_N for N=1..7 should be supported.
; BRs to LibCalls should *replace* POP + RET sequences

target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430"

; None of the following functions uses any POP or RET instructions,
; so this fact can be tested with --implicit-check-not on the whole output.

define i16 @pops_1_reg() {
; Replacing 4 bytes with 4 other bytes. Doesn't make code smaller, but doesn't
; make it larger as well...
; CHECK-LABEL: pops_1_reg
  call void asm sideeffect "", "~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_1
; CHECK:     -- End function
}

define i16 @pops_2_regs() {
; CHECK-LABEL: pops_2_regs
  call void asm sideeffect "", "~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_2
; CHECK:     -- End function
}

define i16 @pops_3_regs() {
; CHECK-LABEL: pops_3_regs
  call void asm sideeffect "", "~{r8},~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_3
; CHECK:     -- End function
}

define i16 @pops_4_regs() {
; CHECK-LABEL: pops_4_regs
  call void asm sideeffect "", "~{r7},~{r8},~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_4
; CHECK:     -- End function
}

define i16 @pops_5_regs() {
; CHECK-LABEL: pops_5_regs
  call void asm sideeffect "", "~{r6},~{r7},~{r8},~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_5
; CHECK:     -- End function
}

define i16 @pops_6_regs() {
; CHECK-LABEL: pops_6_regs
  call void asm sideeffect "", "~{r5},~{r6},~{r7},~{r8},~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_6
; CHECK:     -- End function
}

define i16 @pops_7_regs() {
; CHECK-LABEL: pops_7_regs
  call void asm sideeffect "", "~{r4},~{r5},~{r6},~{r7},~{r8},~{r9},~{r10}"()
  ret i16 42
; CHECK:     ;NO_APP
; CHECK:     br #__mspabi_func_epilog_7
; CHECK:     -- End function
}
