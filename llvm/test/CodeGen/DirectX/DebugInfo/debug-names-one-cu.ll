; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 2
; CHECK: DIDerivedType: 1
; CHECK: DIFile: 1
; CHECK: DIFlagFwdDecl: 1
; CHECK: DIGlobalVariable: 2

; XFAIL: target={{.*}}-aix{{.*}}

; Check the header



; The entry for A::B must not have an IDX_Parent, since A is only a forward
; declaration.



; VERIFY: No errors.

@foobar = common dso_local global ptr null, align 8, !dbg !0
@someA_B = common dso_local global ptr null, align 8, !dbg !18

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!7, !8, !9}
!llvm.ident = !{!10}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "foobar", scope: !2, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 7.0.0 (trunk 325496) (llvm/trunk 325732)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5)
!3 = !DIFile(filename: "/tmp/cu1.c", directory: "/tmp")
!4 = !{}
!5 = !{!0, !18}
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!7 = !{i32 2, !"Dwarf Version", i32 4}
!8 = !{i32 2, !"Debug Info Version", i32 3}
!9 = !{i32 1, !"wchar_size", i32 4}
!10 = !{!"clang version 7.0.0 (trunk 325496) (llvm/trunk 325732)"}

!13 = !{}
!15 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "B", scope: !16, file: !3, line: 3, size: 8, elements: !13, identifier: "type_A::B")
!16 = !DICompositeType(tag: DW_TAG_structure_type, name: "A", file: !3, line: 1, size: 8, flags: DIFlagFwdDecl, identifier: "type_A")
!17 = distinct !DIGlobalVariable(name: "someA_B", scope: !2, file: !3, line: 1, type: !15, isLocal: false, isDefinition: true)
!18 = !DIGlobalVariableExpression(var: !17, expr: !DIExpression())
