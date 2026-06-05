; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 1
; CHECK: DIDerivedType: 1
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 3
; CHECK: DIFlagStaticMember: 1
; CHECK: DIImportedEntity: 1
; CHECK: DILocalVariable: 1
; CHECK: DINamespace: 1
; CHECK: DISubprogram: 3


; This is to track DebugInfoFinder's ability to find the debug info metadata,
; in particular, properly visit DISubprogram's retainedNodes.


%struct.T = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp(sync)
define noundef i32 @_Z3foov() !dbg !7 {
entry:
  ret i32 0
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang version 21.0.0git", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "source.cpp", directory: "/somewhere")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 8, !"PIC Level", i32 2}
!6 = !{!"clang version 21.0.0git"}
!7 = distinct !DISubprogram(name: "foo", linkageName: "_Z3foov", scope: !1, file: !1, line: 1, scopeLine: 1, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !8)
!8 = !{!9, !15}
!9 = !DILocalVariable(name: "v", scope: !7, file: !1, line: 8, type: !10)
!10 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "T", scope: !7, file: !1, line: 2, size: 32, flags: DIFlagTypePassByValue, elements: !11)
!11 = !{!12, !14}
!12 = !DIDerivedType(tag: DW_TAG_member, name: "x", scope: !10, file: !1, line: 3, baseType: !13, size: 32)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !DISubprogram(name: "bar", scope: !10, file: !1, line: 5, scopeLine: 5, flags: DIFlagPrototyped | DIFlagStaticMember, spFlags: DISPFlagLocalToUnit)
!15 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !7, entity: !16, file: !1, line: 7)
!16 = distinct !DISubprogram(name: "imported", scope: !17, file: !1, line: 3, scopeLine: 3, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0)
!17 = !DINamespace(name: "ns", scope: null)