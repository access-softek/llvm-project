; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 2
; CHECK: DIDerivedType: 1
; CHECK: DIFile: 1
; CHECK: DIGlobalVariable: 2

; XFAIL: target={{.*}}-aix{{.*}}

; Check the header




; VERIFY: No errors.

!llvm.dbg.cu = !{!12, !22}
!llvm.module.flags = !{!7, !8, !9}
!llvm.ident = !{!0}
!7 = !{i32 2, !"Dwarf Version", i32 4}
!8 = !{i32 2, !"Debug Info Version", i32 3}
!9 = !{i32 1, !"wchar_size", i32 4}
!0 = !{!"clang version 7.0.0 (trunk 325496) (llvm/trunk 325732)"}
!4 = !{}
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!3 = !DIFile(filename: "/tmp/cu2.c", directory: "/tmp")

@foobar1 = common dso_local global ptr null, align 8, !dbg !10
!10 = !DIGlobalVariableExpression(var: !11, expr: !DIExpression())
!11 = distinct !DIGlobalVariable(name: "foobar1", scope: !12, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!12 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 7.0.0 (trunk 325496) (llvm/trunk 325732)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !15)
!15 = !{!10}

@foobar2 = common dso_local global ptr null, align 8, !dbg !20
!20 = !DIGlobalVariableExpression(var: !21, expr: !DIExpression())
!21 = distinct !DIGlobalVariable(name: "foobar2", scope: !22, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!22 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 7.0.0 (trunk 325496) (llvm/trunk 325732)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !25)
!25 = !{!20}
