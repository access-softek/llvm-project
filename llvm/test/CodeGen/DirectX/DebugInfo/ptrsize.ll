; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIDerivedType: 2
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 2
; CHECK: DILocation: 2
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 2


; Check that pointers and references get emitted without size information in
; DWARF, even if they are so specified in the IR



define i32 @foo() !dbg !4 {
entry:
  ret i32 0, !dbg !13
}

define i32 @bar() !dbg !5 {
entry:
  ret i32 0, !dbg !16
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!11, !12}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "dwarf-test.c", directory: "test")
!2 = !{}
!4 = distinct !DISubprogram(name: "foo", scope: !0, file: !1, line: 6, type: !6, isLocal: false, isDefinition: true, scopeLine: 6, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, retainedNodes: !2)
!5 = distinct !DISubprogram(name: "bar", scope: !0, file: !1, line: 6, type: !15, isLocal: false, isDefinition: true, scopeLine: 6, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, retainedNodes: !2)
!6 = !DISubroutineType(types: !7)
!7 = !{!9}
!8 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = !DIDerivedType(tag: DW_TAG_pointer_type, scope: !0, baseType: !8, size: 64, align: 64)
!10 = !DIDerivedType(tag: DW_TAG_reference_type, scope: !0, baseType: !8, size: 64, align: 64)
!11 = !{i32 2, !"Dwarf Version", i32 3}
!12 = !{i32 1, !"Debug Info Version", i32 3}
!13 = !DILocation(line: 7, scope: !4)
!14 = !{!10}
!15 = !DISubroutineType(types: !14)
!16 = !DILocation(line: 7, scope: !5)
