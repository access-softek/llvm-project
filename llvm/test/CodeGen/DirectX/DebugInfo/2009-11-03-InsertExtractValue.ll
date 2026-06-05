; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIFlagProtected: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


!llvm.module.flags = !{!6}
!llvm.dbg.cu = !{!5}

!0 = distinct !DISubprogram(name: "bar", linkageName: "_ZN3foo3barEv", line: 3, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagProtected | DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !5, isOptimized: false, scopeLine: 3, file: !4, scope: !1, type: !2)
!1 = !DIFile(filename: "/foo", directory: "bar.cpp")
!2 = !DISubroutineType(types: !3)
!3 = !{null}
!4 = !DIFile(filename: "/foo", directory: "bar.cpp")
!5 = distinct !DICompileUnit(language: DW_LANG_C99, isOptimized: true, emissionKind: FullDebug, file: !4, enums: !{}, retainedTypes: !{})

define <{i32, i32}> @f1() !dbg !0 {
  %r = insertvalue <{ i32, i32 }> zeroinitializer, i32 4, 1, !dbgx !1
  %e = extractvalue <{ i32, i32 }> %r, 0, !dbgx !1
  ret <{ i32, i32 }> %r
}

!6 = !{i32 1, !"Debug Info Version", i32 3}
