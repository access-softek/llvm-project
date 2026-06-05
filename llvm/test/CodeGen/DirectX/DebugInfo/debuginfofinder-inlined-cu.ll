; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 2
; CHECK: DIFile: 2
; CHECK: DILocation: 2
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 1


; Verify that both compile units, even though one compile units's functions
; were entirely inlined into the other.

define void @f() !dbg !4 {
  ret void, !dbg !15
}

!llvm.dbg.cu = !{!0, !8}
!llvm.module.flags = !{!13, !16}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.4 (192092)", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "test1.c", directory: "/tmp")
!2 = !{}
!4 = distinct !DISubprogram(name: "f", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, isOptimized: false, unit: !0, scopeLine: 1, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "test1.c", directory: "/tmp")
!6 = !DISubroutineType(types: !7)
!7 = !{null}
!8 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.4 (192092)", isOptimized: false, emissionKind: FullDebug, file: !9, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!9 = !DIFile(filename: "test2.c", directory: "/tmp")
!11 = distinct !DISubprogram(name: "g", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, isOptimized: false, unit: !8, scopeLine: 1, file: !9, scope: !12, type: !6, retainedNodes: !2)
!12 = !DIFile(filename: "test2.c", directory: "/tmp")
!13 = !{i32 2, !"Dwarf Version", i32 4}
!14 = !DILocation(line: 1, scope: !4)
!15 = !DILocation(line: 1, scope: !11, inlinedAt: !14)
!16 = !{i32 1, !"Debug Info Version", i32 3}
