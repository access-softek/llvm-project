; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DILocation: 2
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 1


; This was generated from the following source:
; int a, b;
; __attribute__((__always_inline__)) static void callee2() { b = 2; }
; __attribute__((__nodebug__)) void callee() { a = 1; callee2(); }
; void caller() { callee(); }
; by running
;   clang -S test.c -emit-llvm -O1 -gline-tables-only -fno-strict-aliasing


; This instruction did not have a !dbg metadata in the callee.

; This instruction came from callee with a !dbg metadata.

; The remaining instruction from the caller.

; Debug location of the code in caller() and of the inlined code that did not
; have any debug location before.

; Debug location of the inlined code.


target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@a = common global i32 0, align 4
@b = common global i32 0, align 4

; Function Attrs: nounwind
define void @callee() #0 {
entry:
  store i32 1, ptr @a, align 4
  store i32 2, ptr @b, align 4, !dbg !11
  ret void
}

; Function Attrs: nounwind
define void @caller() #0 !dbg !4 {
entry:
  tail call void @callee(), !dbg !12
  ret void, !dbg !12
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "frame-pointer"="none" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.5.0 (210174)", isOptimized: true, emissionKind: LineTablesOnly, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "test.c", directory: "/code/llvm/build0")
!2 = !{}
!4 = distinct !DISubprogram(name: "caller", line: 4, isLocal: false, isDefinition: true, virtualIndex: 6, isOptimized: true, unit: !0, scopeLine: 4, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "test.c", directory: "/code/llvm/build0")
!6 = !DISubroutineType(types: !2)
!7 = distinct !DISubprogram(name: "callee2", line: 2, isLocal: true, isDefinition: true, virtualIndex: 6, isOptimized: true, unit: !0, scopeLine: 2, file: !1, scope: !5, type: !6, retainedNodes: !2)
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{!"clang version 3.5.0 (210174)"}
!11 = !DILocation(line: 2, scope: !7)
!12 = !DILocation(line: 4, scope: !4)
