; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 2
; CHECK: DILexicalBlockFile: 1
; CHECK: DILocation: 5
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 1


; Given the following source, ensure that the discriminator is emitted for
; the inlined callsite.

;void xyz();
;static void __attribute__((always_inline)) bar() { xyz(); }
;void foo() {
;  bar(); bar();
;}


; Function Attrs:
define void @_Z3foov() #0 !dbg !4 {
  tail call void @_Z3xyzv(), !dbg !11
  tail call void @_Z3xyzv(), !dbg !13
  ret void, !dbg !16
}

declare void @_Z3xyzv() #1

attributes #0 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="none" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="none" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang version 3.8.0 (trunk 252497)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "a.cc", directory: "/tmp")
!2 = !{}
!4 = distinct !DISubprogram(name: "foo", linkageName: "_Z3foov", scope: !1, file: !1, line: 3, type: !5, isLocal: false, isDefinition: true, scopeLine: 3, flags: DIFlagPrototyped, isOptimized: true, unit: !0, retainedNodes: !2)
!5 = !DISubroutineType(types: !6)
!6 = !{null}
!7 = distinct !DISubprogram(name: "bar", linkageName: "_ZL3barv", scope: !1, file: !1, line: 2, type: !5, isLocal: true, isDefinition: true, scopeLine: 2, flags: DIFlagPrototyped, isOptimized: true, unit: !0, retainedNodes: !2)
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{!"clang version 3.8.0 (trunk 252497)"}
!11 = !DILocation(line: 2, column: 52, scope: !7, inlinedAt: !12)
!12 = distinct !DILocation(line: 4, column: 3, scope: !4)
!13 = !DILocation(line: 2, column: 52, scope: !7, inlinedAt: !14)
!14 = distinct !DILocation(line: 4, column: 10, scope: !15)
!15 = !DILexicalBlockFile(scope: !4, file: !1, discriminator: 1)
!16 = !DILocation(line: 5, column: 1, scope: !4)
