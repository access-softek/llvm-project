; RUN: llc -mtriple=aarch64 -verify-machineinstrs -asm-verbose=0              -stop-after=finalize-isel < %s \
; RUN:     | FileCheck --check-prefixes=MIR-HINT %s
; RUN: llc -mtriple=aarch64 -verify-machineinstrs -asm-verbose=0 -mattr=v8.3a -stop-after=finalize-isel < %s \
; RUN:     | FileCheck --check-prefixes=MIR-V83 %s
; RUN: llc -mtriple=aarch64 -verify-machineinstrs -asm-verbose=0              -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 < %s \
; RUN:     | FileCheck --check-prefixes=MIR-HINT %s
; RUN: llc -mtriple=aarch64 -verify-machineinstrs -asm-verbose=0 -mattr=v8.3a -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 < %s \
; RUN:     | FileCheck --check-prefixes=MIR-V83 %s

; RUN: llc -mtriple=aarch64 -verify-machineinstrs -asm-verbose=0              < %s \
; RUN:     | FileCheck --check-prefixes=HINT %s
; RUN: llc -mtriple=aarch64 -verify-machineinstrs -asm-verbose=0 -mattr=v8.3a < %s \
; RUN:     | FileCheck --check-prefixes=V83 %s

; Test which check method is used by default. At now, if one key is I-key and
; the other is D-key, the key used for authentication determines the method.

define i64 @test_default_checker_ia(i64 %signed) {
; HINT-LABEL:  test_default_checker_ia:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov     x17, x0
; HINT-NEXT:     mov     x16, #0
; HINT-NEXT:     hint    #12
; HINT-NEXT:     mov     x16, #42
; HINT-NEXT:     hint    #8
; HINT-NEXT:     mov     x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_default_checker_ia:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autiza  x0
; V83-NEXT:     mov     x8, x0
; V83-NEXT:     xpaci   x8
; V83-NEXT:     cmp     x8, x0
; V83-NEXT:     b.ne    .[[FAIL:LBB[_0-9]+]]
; V83-NEXT:     mov     x8, #42
; V83-NEXT:     pacia   x0, x8
; V83-NEXT:     ret
; V83-NEXT:   .[[FAIL]]:
; V83-NEXT:     brk     #0xc470
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 0, i32 0, i64 42)
  ret i64 %resigned
}

define i64 @test_default_checker_ia_to_da(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_default_checker_ia_to_da:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autiza  x0
; V83-NEXT:     mov     x8, x0
; V83-NEXT:     xpaci   x8
; V83-NEXT:     cmp     x8, x0
; V83-NEXT:     b.ne    .[[FAIL:LBB[_0-9]+]]
; V83-NEXT:     mov     x8, #42
; V83-NEXT:     pacda   x0, x8
; V83-NEXT:     ret
; V83-NEXT:   .[[FAIL]]:
; V83-NEXT:     brk     #0xc470
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 0, i32 2, i64 42)
  ret i64 %resigned
}

define i64 @test_default_checker_da(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_default_checker_da:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autdza  x0
; V83-NEXT:     ldr w8, [x0]
; V83-NEXT:     mov     x8, #42
; V83-NEXT:     pacda   x0, x8
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 2, i64 0, i32 2, i64 42)
  ret i64 %resigned
}

define i64 @test_default_checker_da_to_ia(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_default_checker_da_to_ia:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autdza  x0
; V83-NEXT:     ldr w8, [x0]
; V83-NEXT:     mov     x8, #42
; V83-NEXT:     pacia   x0, x8
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 2, i64 0, i32 0, i64 42)
  ret i64 %resigned
}

; Test that correct AUT* and PAC* instructions are generated.
; * Use different key and zero/non-zero discriminator for authentication
;   and signing (to catch mixed up old and new signing schemas).
; * Use all 8 combinations both for authentication and for signing.
; * Do not mix I-keys with D-keys, so the former can be checked both with and
;   without FEAT_PAuth

define i64 @test_i1(i64 %signed) {
; HINT-LABEL:  test_i1:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, #0
; HINT-NEXT:     hint #12
; HINT-NEXT:     mov x16, #42
; HINT-NEXT:     hint #10
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_i1:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autiza x0
;
; V83:          mov x8, #42
; V83-NEXT:     pacib x0, x8
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 0, i32 1, i64 42)
  ret i64 %resigned
}

define i64 @test_i2(i64 %signed) {
; HINT-LABEL:  test_i2:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, #42
; HINT-NEXT:     hint #12
; HINT-NEXT:     mov x16, #0
; HINT-NEXT:     hint #10
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_i2:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     mov x8, #42
; V83-NEXT:     autia x0, x8
;
; V83:          pacizb x0
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 42, i32 1, i64 0)
  ret i64 %resigned
}

define i64 @test_i3(i64 %signed) {
; HINT-LABEL:  test_i3:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, #0
; HINT-NEXT:     hint #14
; HINT-NEXT:     mov x16, #42
; HINT-NEXT:     hint #8
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_i3:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autizb x0
;
; V83:          mov x8, #42
; V83-NEXT:     pacia x0, x8
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 1, i64 0, i32 0, i64 42)
  ret i64 %resigned
}

define i64 @test_i4(i64 %signed) {
; HINT-LABEL:  test_i4:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, #42
; HINT-NEXT:     hint #14
; HINT-NEXT:     mov x16, #0
; HINT-NEXT:     hint #8
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_i4:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     mov x8, #42
; V83-NEXT:     autib x0, x8
;
; V83:          paciza x0
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 1, i64 42, i32 0, i64 0)
  ret i64 %resigned
}

define i64 @test_d1(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_d1:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autdza x0
;
; V83:          mov x8, #42
; V83-NEXT:     pacdb x0, x8
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 2, i64 0, i32 3, i64 42)
  ret i64 %resigned
}

define i64 @test_d2(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_d2:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     mov x8, #42
; V83-NEXT:     autda x0, x8
;
; V83:          pacdzb x0
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 2, i64 42, i32 3, i64 0)
  ret i64 %resigned
}

define i64 @test_d3(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_d3:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autdzb x0
;
; V83:          mov x8, #42
; V83-NEXT:     pacda x0, x8
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 3, i64 0, i32 2, i64 42)
  ret i64 %resigned
}

define i64 @test_d4(i64 %signed) "target-features"="+v8.3a" {
; V83-LABEL:  test_d4:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     mov x8, #42
; V83-NEXT:     autdb x0, x8
;
; V83:          pacdza x0
; V83-NEXT:     ret
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 3, i64 42, i32 2, i64 0)
  ret i64 %resigned
}

; Test various combinations of "old" and "new" signing schemas.
; Only use an I-key, so both +pauth and -pauth cases can be tested.

define i64 @test_zero_to_int(i64 %signed) {
; HINT-LABEL:  test_zero_to_int:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, #0
; HINT-NEXT:     hint #12
; HINT-NEXT:     mov x16, #42
; HINT-NEXT:     hint #8
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_zero_to_int:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autiza x0
;
; V83:          mov x8, #42
; V83-NEXT:     pacia x0, x8
; V83-NEXT:     ret

; MIR-HINT-LABEL:  name: test_zero_to_int
; MIR-HINT:        body:
; MIR-HINT:          bb{{.*}}:
; MIR-HINT:            liveins: $x0
; MIR-HINT-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-HINT:            $x17, {{(dead )?}}$xzr = PAUTH_RESIGN %[[SIGNED]], $xzr, 0, 0, 0, {{(killed )?}}$xzr, 42, 0, 0, implicit-def $x16{{$}}
; MIR-HINT:            %[[AUTED:[0-9]+]]:gpr64common = COPY $x17
; MIR-HINT:            $x0 = COPY %[[AUTED]]
; MIR-HINT:            RET_ReallyLR implicit $x0

; MIR-V83-LABEL:  name: test_zero_to_int
; MIR-V83:        body:
; MIR-V83:          bb{{.*}}:
; MIR-V83:            liveins: $x0
; MIR-V83-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-V83:            %[[AUTED:[0-9]+]]:gpr64common, {{(dead )?}}$xzr = PAUTH_RESIGN %[[SIGNED]], $xzr, 0, 0, 0, {{(killed )?}}$xzr, 42, 0, 0, implicit-def %{{[0-9]+}}{{$}}
; MIR-V83:            $x0 = COPY %[[AUTED]]
; MIR-V83:            RET_ReallyLR implicit $x0
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 0, i32 0, i64 42)
  ret i64 %resigned
}

define i64 @test_int_to_zero(i64 %signed) {
; HINT-LABEL:  test_int_to_zero:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, #42
; HINT-NEXT:     hint #12
; HINT-NEXT:     mov x16, #0
; HINT-NEXT:     hint #8
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_int_to_zero:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     mov x8, #42
; V83-NEXT:     autia x0, x8
;
; V83:          paciza x0
; V83-NEXT:     ret

; MIR-HINT-LABEL:  name: test_int_to_zero
; MIR-HINT:        body:
; MIR-HINT:          bb{{.*}}:
; MIR-HINT:            liveins: $x0
; MIR-HINT-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-HINT:            $x17, {{(dead )?}}$xzr = PAUTH_RESIGN %[[SIGNED]], $xzr, 42, 0, 0, {{(killed )?}}$xzr, 0, 0, 0, implicit-def $x16{{$}}
; MIR-HINT:            %[[AUTED:[0-9]+]]:gpr64common = COPY $x17
; MIR-HINT:            $x0 = COPY %[[AUTED]]
; MIR-HINT:            RET_ReallyLR implicit $x0

; MIR-V83-LABEL:  name: test_int_to_zero
; MIR-V83:        body:
; MIR-V83:          bb{{.*}}:
; MIR-V83:            liveins: $x0
; MIR-V83-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-V83:            %[[AUTED:[0-9]+]]:gpr64common, {{(dead )?}}$xzr = PAUTH_RESIGN %[[SIGNED]], $xzr, 42, 0, 0, {{(killed )?}}$xzr, 0, 0, 0, implicit-def %{{[0-9]+}}{{$}}
; MIR-V83:            $x0 = COPY %[[AUTED]]
; MIR-V83:            RET_ReallyLR implicit $x0
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 42, i32 0, i64 0)
  ret i64 %resigned
}

define i64 @test_raw_to_blended(i64 %signed, i64 %raw_disc_old, i64 %addr_disc_new) {
; HINT-LABEL:  test_raw_to_blended:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, x1
; HINT-NEXT:     hint #12
; HINT-NEXT:     mov x16, x2
; HINT-NEXT:     movk x16, #42, lsl #48
; HINT-NEXT:     hint #8
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_raw_to_blended:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     autia x0, x1
;
; V83:          mov x1, x2
; V83-NEXT:     movk x1, #42, lsl #48
; V83-NEXT:     pacia x0, x1
; V83-NEXT:     ret

; MIR-HINT-LABEL:  name: test_raw_to_blended
; MIR-HINT:        body:
; MIR-HINT:          bb{{.*}}:
; MIR-HINT:            liveins: $x0
; MIR-HINT-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-HINT-DAG:        %[[RAW_DISC_OLD:[0-9]+]]:gpr64 = COPY $x1
; MIR-HINT-DAG:        %[[ADDR_DISC_NEW:[0-9]+]]:gpr64 = COPY $x2
; MIR-HINT:            $x17, {{(dead )?}}$x16 = PAUTH_RESIGN %[[SIGNED]], %[[RAW_DISC_OLD]], 0, 0, 0, {{(killed )?}}%[[ADDR_DISC_NEW]], 42, 1, 0{{$}}
; MIR-HINT:            %[[AUTED:[0-9]+]]:gpr64common = COPY $x17
; MIR-HINT:            $x0 = COPY %[[AUTED]]
; MIR-HINT:            RET_ReallyLR implicit $x0

; MIR-V83-LABEL:  name: test_raw_to_blended
; MIR-V83:        body:
; MIR-V83:          bb{{.*}}:
; MIR-V83:            liveins: $x0
; MIR-V83-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-V83-DAG:        %[[RAW_DISC_OLD:[0-9]+]]:gpr64 = COPY $x1
; MIR-V83-DAG:        %[[ADDR_DISC_NEW:[0-9]+]]:gpr64 = COPY $x2
; MIR-V83:            %[[AUTED:[0-9]+]]:gpr64common, {{(dead )?}}%{{[0-9]+}}:gpr64 = PAUTH_RESIGN %[[SIGNED]], %[[RAW_DISC_OLD]], 0, 0, 0, {{(killed )?}}%[[ADDR_DISC_NEW]], 42, 1, 0{{$}}
; MIR-V83:            $x0 = COPY %[[AUTED]]
; MIR-V83:            RET_ReallyLR implicit $x0
  %disc_new = call i64 @llvm.ptrauth.blend(i64 %addr_disc_new, i64 42)
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 %raw_disc_old, i32 0, i64 %disc_new)
  ret i64 %resigned
}

define i64 @test_blended_to_raw(i64 %signed, i64 %addr_disc_old, i64 %raw_disc_new) {
; HINT-LABEL:  test_blended_to_raw:
; HINT-NEXT:     .cfi_startproc
; HINT-NEXT:     mov x17, x0
; HINT-NEXT:     mov x16, x1
; HINT-NEXT:     movk x16, #42, lsl #48
; HINT-NEXT:     hint #12
; HINT-NEXT:     mov x16, x2
; HINT-NEXT:     hint #8
; HINT-NEXT:     mov x0, x17
; HINT-NEXT:     ret

; V83-LABEL:  test_blended_to_raw:
; V83-NEXT:     .cfi_startproc
; V83-NEXT:     movk x1, #42, lsl #48
; V83-NEXT:     autia x0, x1
;
; V83:          mov x1, x2
; V83-NEXT:     pacia x0, x1
; V83-NEXT:     ret

; MIR-HINT-LABEL:  name: test_blended_to_raw
; MIR-HINT:        body:
; MIR-HINT:          bb{{.*}}:
; MIR-HINT:            liveins: $x0
; MIR-HINT-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-HINT-DAG:        %[[ADDR_DISC_OLD:[0-9]+]]:gpr64 = COPY $x1
; MIR-HINT-DAG:        %[[RAW_DISC_NEW:[0-9]+]]:gpr64 = COPY $x2
; MIR-HINT:            $x17, {{(dead )?}}$x16 = PAUTH_RESIGN %[[SIGNED]], %[[ADDR_DISC_OLD]], 42, 1, 0, {{(killed )?}}%[[RAW_DISC_NEW]], 0, 0, 0{{$}}
; MIR-HINT:            %[[AUTED:[0-9]+]]:gpr64common = COPY $x17
; MIR-HINT:            $x0 = COPY %[[AUTED]]
; MIR-HINT:            RET_ReallyLR implicit $x0

; MIR-V83-LABEL:  name: test_blended_to_raw
; MIR-V83:        body:
; MIR-V83:          bb{{.*}}:
; MIR-V83:            liveins: $x0
; MIR-V83-DAG:        %[[SIGNED:[0-9]+]]:gpr64common = COPY $x0
; MIR-V83-DAG:        %[[ADDR_DISC_OLD:[0-9]+]]:gpr64 = COPY $x1
; MIR-V83-DAG:        %[[RAW_DISC_NEW:[0-9]+]]:gpr64 = COPY $x2
; MIR-V83:            %[[AUTED:[0-9]+]]:gpr64common, {{(dead )?}}%{{[0-9]+}}:gpr64 = PAUTH_RESIGN %[[SIGNED]], %[[ADDR_DISC_OLD]], 42, 1, 0, {{(killed )?}}%[[RAW_DISC_NEW]], 0, 0, 0{{$}}
; MIR-V83:            $x0 = COPY %[[AUTED]]
; MIR-V83:            RET_ReallyLR implicit $x0
  %disc_old = call i64 @llvm.ptrauth.blend(i64 %addr_disc_old, i64 42)
  %resigned = call i64 @llvm.ptrauth.resign(i64 %signed, i32 0, i64 %disc_old, i32 0, i64 %raw_disc_new)
  ret i64 %resigned
}

declare i64 @llvm.ptrauth.resign(i64, i32, i64, i32, i64)
declare i64 @llvm.ptrauth.blend(i64, i64)
