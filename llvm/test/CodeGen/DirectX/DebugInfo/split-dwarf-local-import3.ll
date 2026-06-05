; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 2
; CHECK: DIFile: 2
; CHECK: DIFlagPrototyped: 2
; CHECK: DIGlobalVariable: 1
; CHECK: DIImportedEntity: 1
; CHECK: DILocation: 2
; CHECK: DINamespace: 1
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 1

; REQUIRES: x86_64-linux

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Ensure that the imported entity 'nn::A' gets emitted in 'foo()'s abstract tree
; in the destination (where 'foo()' was inlined) compile unit.







define dso_local noundef i32 @main() local_unnamed_addr !dbg !20 {
entry:
  ret i32 42, !dbg !21
}

!llvm.dbg.cu = !{!0, !2}
!llvm.module.flags = !{!13, !14}
!llvm.ident = !{!19, !19}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 15.0.0", isOptimized: true, runtimeVersion: 0, splitDebugFilename: "test.dwo", emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: GNU)
!1 = !DIFile(filename: "test.cpp", directory: "/", checksumkind: CSK_MD5, checksum: "e7c2808ee27614e496499d55e4b37962")
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !3, producer: "clang version 15.0.0", isOptimized: true, runtimeVersion: 0, splitDebugFilename: "cu1.dwo", emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: GNU)
!3 = !DIFile(filename: "cu1.cpp", directory: "/", checksumkind: CSK_MD5, checksum: "c0b84240ef5682b87083b33cf9038171")
!4 = !{!5}
!5 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !6, entity: !11, file: !3, line: 5)
!6 = distinct !DISubprogram(name: "foo", linkageName: "_Z3foov", scope: !3, file: !3, line: 5, type: !7, scopeLine: 5, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !4)
!7 = !DISubroutineType(types: !8)
!8 = !{!9}
!9 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!10 = !{}
!11 = distinct !DIGlobalVariable(name: "A", linkageName: "_ZN2nn1AE", scope: !12, file: !3, line: 2, type: !9, isLocal: false, isDefinition: true)
!12 = !DINamespace(name: "nn", scope: null)
!13 = !{i32 7, !"Dwarf Version", i32 5}
!14 = !{i32 2, !"Debug Info Version", i32 3}
!19 = !{!"clang version 15.0.0"}
!20 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 3, type: !7, scopeLine: 3, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!21 = !DILocation(line: 4, column: 3, scope: !6, inlinedAt: !22)
!22 = !DILocation(line: 4, column: 3, scope: !20)
