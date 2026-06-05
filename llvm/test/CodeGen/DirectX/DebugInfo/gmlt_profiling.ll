; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


; With debug-info-for-profiling attribute, we need to emit decl_file and
; decl_line of the subprogram.

; Function Attrs: nounwind
define void @_Z2f1v() !dbg !4 {
entry:
  ret void, !dbg !13
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!10, !11}
!llvm.ident = !{!12}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.6.0 ", isOptimized: false, emissionKind: LineTablesOnly, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2, debugInfoForProfiling: true)
!1 = !DIFile(filename: "gmlt.cpp", directory: "/tmp/dbginfo")
!2 = !{}
!4 = distinct !DISubprogram(name: "f1", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 1, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "gmlt.cpp", directory: "/tmp/dbginfo")
!6 = !DISubroutineType(types: !2)
!10 = !{i32 2, !"Dwarf Version", i32 4}
!11 = !{i32 2, !"Debug Info Version", i32 3}
!12 = !{!"clang version 3.6.0 "}
!13 = !DILocation(line: 1, column: 12, scope: !4)
