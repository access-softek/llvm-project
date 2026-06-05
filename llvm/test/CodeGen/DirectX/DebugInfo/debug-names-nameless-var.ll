; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIGlobalVariable: 1

; XFAIL: target={{.*}}-aix{{.*}}

@nameless_var = constant i8 0, !dbg !0

; VERIFY: No errors

!llvm.dbg.cu = !{!10}
!llvm.module.flags = !{!14, !15}
!llvm.ident = !{!20}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !11, line: 1, type: !5, isLocal: true, isDefinition: true)
!5 = !DIBasicType(size: 8, encoding: DW_ATE_signed_char)
!10 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !11, producer: "blah", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !12, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
!11 = !DIFile(filename: "blah", directory: "blah")
!12 = !{!0}
!14 = !{i32 7, !"Dwarf Version", i32 5}
!15 = !{i32 2, !"Debug Info Version", i32 3}
!20 = !{!"blah"}
