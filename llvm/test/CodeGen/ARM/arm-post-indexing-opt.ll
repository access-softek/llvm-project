; RUN: llc -o - < %s | FileCheck --check-prefix=ASM %s
; RUN: opt --arm-post-indexing-opt -S -o - < %s | FileCheck --check-prefix=IR %s

target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv8-unknown-linux-gnueabihf"

define <4 x float> @test(float* %A) {
  %X.ptr = bitcast float* %A to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 4
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 8
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}
; IR-LABEL: define <4 x float> @test(float* %A) {
; IR-NEXT:    %X.ptr = bitcast float* %A to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %postinc = getelementptr <4 x float>, <4 x float>* %X.ptr, i32 1
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %postinc1 = getelementptr <4 x float>, <4 x float>* %postinc, i32 1
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc1, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

;ASM-LABEL: test:
;ASM-NOT: add
;ASM-NOT: sub
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]

define <4 x float> @test_stride(float* %A) {
  %X.ptr = bitcast float* %A to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 6
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 12
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_stride(float* %A) {
; IR-NEXT:    %X.ptr = bitcast float* %A to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %oldbase.byteptr = bitcast <4 x float>* %X.ptr to i8*
; IR-NEXT:    %postinc.byteptr = getelementptr i8, i8* %oldbase.byteptr, i32 24
; IR-NEXT:    %postinc = bitcast i8* %postinc.byteptr to <4 x float>*
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %oldbase.byteptr1 = bitcast <4 x float>* %postinc to i8*
; IR-NEXT:    %postinc.byteptr2 = getelementptr i8, i8* %oldbase.byteptr1, i32 24
; IR-NEXT:    %postinc3 = bitcast i8* %postinc.byteptr2 to <4 x float>*
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc3, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

; ASM-LABEL: test_stride:
; ASM: mov r[[STRIDE:[0-9]+]], #24
; ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0], r[[STRIDE]]
; ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0], r[[STRIDE]]
; ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]

define <4 x float> @test_stride_mixed(float* %A) {
  %X.ptr = bitcast float* %A to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 6
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 10
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_stride_mixed(float* %A) {
; IR-NEXT:    %X.ptr = bitcast float* %A to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %oldbase.byteptr = bitcast <4 x float>* %X.ptr to i8*
; IR-NEXT:    %postinc.byteptr = getelementptr i8, i8* %oldbase.byteptr, i32 24
; IR-NEXT:    %postinc = bitcast i8* %postinc.byteptr to <4 x float>*
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %postinc1 = getelementptr <4 x float>, <4 x float>* %postinc, i32 1
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc1, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

; ASM-LABEL: test_stride_mixed:
; ASM: mov r[[STRIDE:[0-9]+]], #24
; ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0], r[[STRIDE]]
; ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
; ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]

; Refrain from using multiple stride registers
define <4 x float> @test_stride_noop(float* %A) {
  %X.ptr = bitcast float* %A to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 6
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 14
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_stride_noop(float* %A) {
; IR-NEXT:    %X.ptr = bitcast float* %A to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 6
; IR-NEXT:    %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
; IR-NEXT:    %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 14
; IR-NEXT:    %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

define <4 x float> @test_positive_initial_offset(float* %A) {
  %X.ptr.elt = getelementptr inbounds float, float* %A, i32 8
  %X.ptr = bitcast float* %X.ptr.elt to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 12
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 16
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_positive_initial_offset(float* %A) {
; IR-NEXT:    %X.ptr.elt = getelementptr inbounds float, float* %A, i32 8
; IR-NEXT:    %X.ptr = bitcast float* %X.ptr.elt to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %postinc = getelementptr <4 x float>, <4 x float>* %X.ptr, i32 1
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %postinc1 = getelementptr <4 x float>, <4 x float>* %postinc, i32 1
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc1, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

;ASM-LABEL: test_positive_initial_offset:
;ASM: add r0, r0, #32
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]

define <4 x float> @test_negative_initial_offset(float* %A) {
  %X.ptr.elt = getelementptr inbounds float, float* %A, i32 -16
  %X.ptr = bitcast float* %X.ptr.elt to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 -12
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 -8
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_negative_initial_offset(float* %A) {
; IR-NEXT:    %X.ptr.elt = getelementptr inbounds float, float* %A, i32 -16
; IR-NEXT:    %X.ptr = bitcast float* %X.ptr.elt to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %postinc = getelementptr <4 x float>, <4 x float>* %X.ptr, i32 1
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %postinc1 = getelementptr <4 x float>, <4 x float>* %postinc, i32 1
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc1, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

;ASM-LABEL: test_negative_initial_offset:
;ASM: sub r0, r0, #64
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]

@global_float_array = external global [128 x float], align 4
define <4 x float> @test_global() {
  %X = load <4 x float>, <4 x float>* bitcast (float* getelementptr inbounds ([128 x float], [128 x float]* @global_float_array, i32 0, i32 8) to <4 x float>*), align 4
  %Y = load <4 x float>, <4 x float>* bitcast (float* getelementptr inbounds ([128 x float], [128 x float]* @global_float_array, i32 0, i32 12) to <4 x float>*), align 4
  %Z = load <4 x float>, <4 x float>* bitcast (float* getelementptr inbounds ([128 x float], [128 x float]* @global_float_array, i32 0, i32 16) to <4 x float>*), align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_global() {
; IR-NEXT:    %1 = bitcast float* getelementptr inbounds ([128 x float], [128 x float]* @global_float_array, i32 0, i32 8) to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %1, align 4
; IR-NEXT:    %postinc = getelementptr <4 x float>, <4 x float>* %1, i32 1
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %postinc1 = getelementptr <4 x float>, <4 x float>* %postinc, i32 1
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc1, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

;ASM-LABEL: test_global:
;ASM: add r[[BASE:[0-9]+]], r[[BASE]], #32
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r[[BASE]]]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r[[BASE]]]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r[[BASE]]]

define <4 x float> @test_stack() {
; Use huge alignment to test that ADD would not be converted to OR
  %array = alloca [32 x float], align 128
  %arraydecay = getelementptr inbounds [32 x float], [32 x float]* %array, i32 0, i32 0
  call void @external_function(float* %arraydecay)
  %X.ptr = bitcast [32 x float]* %array to <4 x float>*
  %X = load <4 x float>, <4 x float>* %X.ptr, align 4
  %Y.ptr.elt = getelementptr inbounds [32 x float], [32 x float]* %array, i32 0, i32 4
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds [32 x float], [32 x float]* %array, i32 0, i32 8
  %Z.ptr = bitcast float* %Z.ptr.elt to <4 x float>*
  %Z = load <4 x float>, <4 x float>* %Z.ptr, align 4
  %tmp.sum = fadd <4 x float> %X, %Y
  %sum = fadd <4 x float> %tmp.sum, %Z
  ret <4 x float> %sum
}

; IR-LABEL: define <4 x float> @test_stack() {
; IR-NEXT:    %array = alloca [32 x float], align 128
; IR-NEXT:    %arraydecay = getelementptr inbounds [32 x float], [32 x float]* %array, i32 0, i32 0
; IR-NEXT:    call void @external_function(float* %arraydecay)
; IR-NEXT:    %X.ptr = bitcast [32 x float]* %array to <4 x float>*
; IR-NEXT:    %X = load <4 x float>, <4 x float>* %X.ptr, align 4
; IR-NEXT:    %postinc = getelementptr <4 x float>, <4 x float>* %X.ptr, i32 1
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %postinc1 = getelementptr <4 x float>, <4 x float>* %postinc, i32 1
; IR-NEXT:    %Z = load <4 x float>, <4 x float>* %postinc1, align 4
; IR-NEXT:    %tmp.sum = fadd <4 x float> %X, %Y
; IR-NEXT:    %sum = fadd <4 x float> %tmp.sum, %Z
; IR-NEXT:    ret <4 x float> %sum
; IR-NEXT:  }

;ASM-LABEL: test_stack:
;ASM: bl external_function
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r[[BASE:[0-9]+]]:128]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r[[BASE]]:128]!
;ASM: vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r[[BASE]]]

define <2 x double> @test_double(double* %A) {
  %X.ptr.elt = getelementptr inbounds double, double* %A, i32 8
  %X.ptr = bitcast double* %X.ptr.elt to <2 x double>*
  %X = load <2 x double>, <2 x double>* %X.ptr, align 8
  %Y.ptr.elt = getelementptr inbounds double, double* %A, i32 10
  %Y.ptr = bitcast double* %Y.ptr.elt to <2 x double>*
  %Y = load <2 x double>, <2 x double>* %Y.ptr, align 8
  %Z.ptr.elt = getelementptr inbounds double, double* %A, i32 12
  %Z.ptr = bitcast double* %Z.ptr.elt to <2 x double>*
  %Z = load <2 x double>, <2 x double>* %Z.ptr, align 8
  %tmp.sum = fadd <2 x double> %X, %Y
  %sum = fadd <2 x double> %tmp.sum, %Z
  ret <2 x double> %sum
}

; IR-LABEL: define <2 x double> @test_double(double* %A) {
; IR-NEXT:    %X.ptr.elt = getelementptr inbounds double, double* %A, i32 8
; IR-NEXT:    %X.ptr = bitcast double* %X.ptr.elt to <2 x double>*
; IR-NEXT:    %X = load <2 x double>, <2 x double>* %X.ptr, align 8
; IR-NEXT:    %postinc = getelementptr <2 x double>, <2 x double>* %X.ptr, i32 1
; IR-NEXT:    %Y = load <2 x double>, <2 x double>* %postinc, align 8
; IR-NEXT:    %postinc1 = getelementptr <2 x double>, <2 x double>* %postinc, i32 1
; IR-NEXT:    %Z = load <2 x double>, <2 x double>* %postinc1, align 8
; IR-NEXT:    %tmp.sum = fadd <2 x double> %X, %Y
; IR-NEXT:    %sum = fadd <2 x double> %tmp.sum, %Z
; IR-NEXT:    ret <2 x double> %sum
; IR-NEXT:  }

;ASM-LABEL: test_double:
;ASM: add r0, r0, #64
;ASM: vld1.64 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.64 {{{d[0-9]+, d[0-9]+}}}, [r0]!
;ASM: vld1.64 {{{d[0-9]+, d[0-9]+}}}, [r0]

define void @test_various_instructions(float* %A) {
  %X.ptr = bitcast float* %A to i8*
  %X = call <4 x float> @llvm.arm.neon.vld1.v4f32.p0i8(i8* %X.ptr, i32 1)
  %Y.ptr.elt = getelementptr inbounds float, float* %A, i32 4
  %Y.ptr = bitcast float* %Y.ptr.elt to <4 x float>*
  %Y = load <4 x float>, <4 x float>* %Y.ptr, align 4
  %Z.ptr.elt = getelementptr inbounds float, float* %A, i32 8
  %Z.ptr = bitcast float* %Z.ptr.elt to i8*
  %Z = fadd <4 x float> %X, %Y
  tail call void @llvm.arm.neon.vst1.p0i8.v4f32(i8* nonnull %Z.ptr, <4 x float> %Z, i32 4)
  ret void
}

; IR-LABEL: define void @test_various_instructions(float* %A) {
; IR-NEXT:    %X.ptr = bitcast float* %A to i8*
; IR-NEXT:    %X = call <4 x float> @llvm.arm.neon.vld1.v4f32.p0i8(i8* %X.ptr, i32 1)
; IR-NEXT:    %postinc.byteptr = getelementptr i8, i8* %X.ptr, i32 16
; IR-NEXT:    %postinc = bitcast i8* %postinc.byteptr to <4 x float>*
; IR-NEXT:    %Y = load <4 x float>, <4 x float>* %postinc, align 4
; IR-NEXT:    %Z = fadd <4 x float> %X, %Y
; IR-NEXT:    %oldbase.byteptr = bitcast <4 x float>* %postinc to i8*
; IR-NEXT:    %postinc.byteptr1 = getelementptr i8, i8* %oldbase.byteptr, i32 16
; IR-NEXT:    tail call void @llvm.arm.neon.vst1.p0i8.v4f32(i8* nonnull %postinc.byteptr1, <4 x float> %Z, i32 4)
; IR-NEXT:    ret void
; IR-NEXT:  }

; ASM-LABEL: test_various_instructions:
; ASM:       @ %bb.0:
; ASM-NEXT:  vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
; ASM-NEXT:  vld1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]!
; ASM-NEXT:  vadd.f32
; ASM-NEXT:  vst1.32 {{{d[0-9]+, d[0-9]+}}}, [r0]
; ASM-NEXT:  bx lr

declare void @external_function(float*)
declare <4 x float> @llvm.arm.neon.vld1.v4f32.p0i8(i8*, i32) nounwind readonly
declare void @llvm.arm.neon.vst1.p0i8.v4f32(i8*, <4 x float>, i32) nounwind argmemonly
