; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DILocation: 4
; CHECK: DISubprogram: 4
; CHECK: DISubroutineType: 1

; Test for DISPFlagPure, DISPFlagElement and DISPFlagRecursive.  These
; three DISPFlags are used to attach DW_AT_pure, DW_AT_element, and
; DW_AT_recursive attributes to DW_TAG_subprogram DIEs.

; -- test the resulting DWARF to make sure we're emitting
; DW_AT_{pure,elemental,recursive}.




; Function Attrs: noinline nounwind optnone
define dso_local void @subroutine1() !dbg !7 {
entry:
  ret void, !dbg !10
}

; Function Attrs: noinline nounwind optnone
define dso_local void @subroutine2() !dbg !11 {
entry:
  ret void, !dbg !12
}

; Function Attrs: noinline nounwind optnone
define dso_local void @subroutine3() !dbg !13 {
entry:
  ret void, !dbg !14
}

; Function Attrs: noinline nounwind optnone
define dso_local void @subroutine4() !dbg !15 {
entry:
  ret void, !dbg !16
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "c", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "x.f", directory: "/tmp")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"c"}
!7 = distinct !DISubprogram(name: "subroutine1", scope: !1, file: !1, line: 1, type: !8, scopeLine: 2, spFlags: DISPFlagDefinition | DISPFlagPure, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{null}
!10 = !DILocation(line: 3, column: 1, scope: !7)
!11 = distinct !DISubprogram(name: "subroutine2", scope: !1, file: !1, line: 5, type: !8, scopeLine: 6, spFlags: DISPFlagDefinition | DISPFlagElemental, unit: !0, retainedNodes: !2)
!12 = !DILocation(line: 7, column: 1, scope: !11)
!13 = distinct !DISubprogram(name: "subroutine3", scope: !1, file: !1, line: 9, type: !8, scopeLine: 10, spFlags: DISPFlagDefinition | DISPFlagRecursive, unit: !0, retainedNodes: !2)
!14 = !DILocation(line: 11, column: 1, scope: !13)
!15 = distinct !DISubprogram(name: "subroutine4", scope: !1, file: !1, line: 13, type: !8, scopeLine: 14, spFlags: DISPFlagDefinition | DISPFlagPure | DISPFlagElemental | DISPFlagRecursive, unit: !0, retainedNodes: !2)
!16 = !DILocation(line: 15, column: 1, scope: !15)
