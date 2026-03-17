; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: dxc /dumpbin %t.dxbc

;; The inliner, specially, hoists all alloca instructions into the entry block
;; of the calling function. Ensure that it doesn't accidentally transfer the
;; dbg.value intrinsic from after the alloca to somewhere else. There should be
;; one dbg.value in the resulting block after the call to ext, and before the
;; call to init.
;;
;; This becomes significant in the context of non-instruction debug-info. When
;; splicing segments of instructions around, it's typically the range from one
;; "real" instruction to another, implicitly including all the dbg.values that
;; come before the ending instruction. The inliner is a (unique!) location in
;; LLVM that builds a range of only a single instruction kind (allocas) and thus
;; doesn't transfer the dbg.value to the entry block. This needs Special
;; Handling once we get rid of debug-intrinsics.



declare void @ext()
declare void @init(ptr)

define internal i32 @foo()  {
  %1 = alloca [65 x i32], align 16
  call void @init(ptr %1)
  %2 = load i32, ptr %1, align 4
  ret i32 %2
}

define i32 @bar()  {
  call void @ext()
  %1 = call i32 @foo()
  ret i32 %1
}
