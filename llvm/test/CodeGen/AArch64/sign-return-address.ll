; RUN: llc -mtriple=aarch64              < %s | FileCheck --check-prefixes=CHECK,COMPAT %s
; RUN: llc -mtriple=aarch64 -mattr=v8.3a < %s | FileCheck --check-prefixes=CHECK,V83A %s

; CHECK-LABEL: leaf:
; CHECK-NOT:     .cfi_negate_ra_state
; CHECK-NOT:     hint
; CHECK-NOT:     paci{{[ab]}}sp
; CHECK-NOT:     auti{{[ab]}}sp
define i32 @leaf(i32 %x) {
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_none:
; CHECK-NOT:     .cfi_negate_ra_state
; CHECK-NOT:     hint
; CHECK-NOT:     paci{{[ab]}}sp
; CHECK-NOT:     auti{{[ab]}}sp
define i32 @leaf_sign_none(i32 %x) "sign-return-address"="none"  {
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_non_leaf:
; CHECK-NOT:     .cfi_negate_ra_state
; CHECK-NOT:     hint
; CHECK-NOT:     paci{{[ab]}}sp
; CHECK-NOT:     auti{{[ab]}}sp
define i32 @leaf_sign_non_leaf(i32 %x) "sign-return-address"="non-leaf"  {
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_all:
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
;
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT:        ret
; V83A:          retaa
define i32 @leaf_sign_all(i32 %x) "sign-return-address"="all" {
  ret i32 %x
}

; CHECK-LABEL: leaf_clobbers_lr:
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
; CHECK:         str x30, [sp, #-16]!
;
; CHECK:         ldr x30, [sp], #16
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT:        ret
; V83A-NEXT:     retaa
define i64 @leaf_clobbers_lr(i64 %x) "sign-return-address"="non-leaf"  {
  call void asm sideeffect "mov x30, $0", "r,~{lr}"(i64 %x) #1
  ret i64 %x
}

declare i32 @foo(i32)

; CHECK-LABEL: non_leaf_sign_all:
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
; CHECK:         str x30, [sp, #-16]!
;
; CHECK:         ldr x30, [sp], #16
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT:        ret
; V83A:          retaa
define i32 @non_leaf_sign_all(i32 %x) "sign-return-address"="all" {
  %call = call i32 @foo(i32 %x)
  ret i32 %call
}

; CHECK-LABEL: non_leaf_sign_non_leaf:
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
; CHECK:         str x30, [sp, #-16]!
;
; CHECK:         ldr x30, [sp], #16
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT:        ret
; V83A:          retaa
define i32 @non_leaf_sign_non_leaf(i32 %x) "sign-return-address"="non-leaf"  {
  %call = call i32 @foo(i32 %x)
  ret i32 %call
}

; CHECK-LABEL: non_leaf_scs:
; CHECK-NOT:     retaa
define i32 @non_leaf_scs(i32 %x) "sign-return-address"="non-leaf" shadowcallstack "target-features"="+v8.3a,+reserve-x18"  {
  %call = call i32 @foo(i32 %x)
  ret i32 %call
}

; CHECK-LABEL: leaf_sign_all_v83:
; CHECK:         paciasp
; CHECK-NEXT:    .cfi_negate_ra_state
; CHECK-NOT:     ret
; CHECK:         retaa
; CHECK-NOT:     ret
define i32 @leaf_sign_all_v83(i32 %x) "sign-return-address"="all" "target-features"="+v8.3a" {
  ret i32 %x
}

declare fastcc i64 @bar(i64)

; CHECK-LABEL: spill_lr_and_tail_call:
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
; CHECK:         str x30, [sp, #-16]!
;
; CHECK:         ldr x30, [sp], #16
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          autiasp
; V83A-NEXT:     .cfi_negate_ra_state
; CHECK:                b bar
define fastcc void @spill_lr_and_tail_call(i64 %x) "sign-return-address"="all" {
  call void asm sideeffect "mov x30, $0", "r,~{lr}"(i64 %x) #1
  tail call fastcc i64 @bar(i64 %x)
  ret void
}

; CHECK-LABEL: leaf_sign_all_a_key:
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
;
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT:        ret
; V83A:          retaa
define i32 @leaf_sign_all_a_key(i32 %x) "sign-return-address"="all" "sign-return-address-key"="a_key" {
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_all_b_key:
; COMPAT:        hint #27
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          pacibsp
; V83A-NEXT:     .cfi_negate_ra_state
;
; COMPAT:        hint #31
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT:        ret
; V83A:          retab
define i32 @leaf_sign_all_b_key(i32 %x) "sign-return-address"="all" "sign-return-address-key"="b_key" {
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_all_v83_b_key:
; CHECK:         pacibsp
; CHECK-NEXT:    .cfi_negate_ra_state
; CHECK-NOT:     ret
; CHECK:         retab
; CHECK-NOT:     ret
define i32 @leaf_sign_all_v83_b_key(i32 %x) "sign-return-address"="all" "target-features"="+v8.3a" "sign-return-address-key"="b_key" {
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_all_a_key_bti:{{.*$}}
; CHECK-NOT:     hint #34
; CHECK-NOT:     bti
; COMPAT:        hint #25
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          paciasp
; V83A-NEXT:     .cfi_negate_ra_state
;
; COMPAT:        hint #29
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT-NEXT:   ret
; V83A:          retaa
define i32 @leaf_sign_all_a_key_bti(i32 %x) "sign-return-address"="all" "sign-return-address-key"="a_key" "branch-target-enforcement"="true"{
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_all_b_key_bti:{{.*$}}
; CHECK-NOT:     hint #34
; CHECK-NOT:     bti
; COMPAT:        hint #27
; COMPAT-NEXT:   .cfi_negate_ra_state
; V83A:          pacibsp
; V83A-NEXT:     .cfi_negate_ra_state
;
; COMPAT:        hint #31
; COMPAT-NEXT:   .cfi_negate_ra_state
; COMPAT-NEXT:   ret
; V83A:          retab
define i32 @leaf_sign_all_b_key_bti(i32 %x) "sign-return-address"="all" "sign-return-address-key"="b_key" "branch-target-enforcement"="true"{
  ret i32 %x
}

; CHECK-LABEL: leaf_sign_all_v83_b_key_bti:{{.*$}}
; CHECK-NOT:     hint #34
; CHECK-NOT:     bti
; CHECK:         pacibsp
; CHECK-NEXT:    .cfi_negate_ra_state
; CHECK-NOT:     ret
; CHECK:         retab
; CHECK-NOT:     ret
define i32 @leaf_sign_all_v83_b_key_bti(i32 %x) "sign-return-address"="all" "target-features"="+v8.3a" "sign-return-address-key"="b_key" "branch-target-enforcement"="true" {
  ret i32 %x
}
