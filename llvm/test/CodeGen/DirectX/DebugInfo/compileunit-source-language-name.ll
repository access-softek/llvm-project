; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 3
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DIGlobalVariable: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; AIX doesn't have support for DWARF 6 DW_AT_language_name
; XFAIL: target={{.*}}-zos{{.*}}, target={{.*}}-aix{{.*}}


@x = global i32 0, align 4, !dbg !0

; Function Attrs: mustprogress noinline nounwind optnone ssp(sync)
define void @_Z4funcv() !dbg !8 {
  ret void, !dbg !11
}

!llvm.dbg.cu = !{!2, !12, !13}
!llvm.module.flags = !{!6, !7}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "x", scope: !2, file: !3, line: 1, type: !5, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(sourceLanguageName: DW_LNAME_ObjC_plus_plus, file: !3, producer: "handwritten", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
!3 = !DIFile(filename: "cu.cpp", directory: "/tmp")
!4 = !{!0}
!5 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!6 = !{i32 7, !"Dwarf Version", i32 5}
!7 = !{i32 2, !"Debug Info Version", i32 3}
!8 = distinct !DISubprogram(name: "func", linkageName: "_Z4funcv", scope: !3, file: !3, line: 2, type: !9, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2)
!9 = !DISubroutineType(types: !10)
!10 = !{null}
!11 = !DILocation(line: 2, column: 14, scope: !8)
!12 = distinct !DICompileUnit(sourceLanguageName: DW_LNAME_C_plus_plus, sourceLanguageVersion: 201100, file: !3, producer: "handwritten", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
!13 = distinct !DICompileUnit(sourceLanguageName: DW_LNAME_Rust, sourceLanguageVersion: 0, file: !3, producer: "handwritten", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
