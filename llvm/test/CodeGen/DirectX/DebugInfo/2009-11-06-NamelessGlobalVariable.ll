; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIGlobalVariable: 1

source_filename = "test/DebugInfo/Generic/2009-11-06-NamelessGlobalVariable.ll"

@0 = internal constant i32 1, !dbg !0

!llvm.dbg.cu = !{!4}
!llvm.module.flags = !{!7}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "a", scope: null, file: !2, line: 2, type: !3, isLocal: false, isDefinition: true)
!2 = !DIFile(filename: "g.c", directory: "/private/tmp")
!3 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!4 = distinct !DICompileUnit(language: DW_LANG_C99, file: !2, producer: "clang version 3.0 (trunk 139632)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !5, retainedTypes: !5, globals: !6)
!5 = !{}
!6 = !{!0}
!7 = !{i32 1, !"Debug Info Version", i32 3}
