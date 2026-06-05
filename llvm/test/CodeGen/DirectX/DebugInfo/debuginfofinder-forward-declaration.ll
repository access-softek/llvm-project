; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 2
; CHECK: DIDerivedType: 2
; CHECK: DIFile: 1
; CHECK: DIFlagFwdDecl: 1
; CHECK: DIGlobalVariable: 1


; This module is generated from the following c-code:
;
; > union X;
; >
; > struct Y {
; >     union X *x;
; > };
; >
; > struct Y y;


source_filename = "test/DebugInfo/Generic/debuginfofinder-forward-declaration.ll"

%struct.Y = type { ptr }
%struct.X = type opaque

@y = common global %struct.Y zeroinitializer, align 8, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!11, !12}
!llvm.ident = !{!13}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "y", scope: !2, file: !3, line: 7, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 3.7.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !4, globals: !5, imports: !4)
!3 = !DIFile(filename: "minimal.c", directory: "/tmp")
!4 = !{}
!5 = !{!0}
!6 = !DICompositeType(tag: DW_TAG_structure_type, name: "Y", file: !3, line: 3, size: 64, align: 64, elements: !7)
!7 = !{!8}
!8 = !DIDerivedType(tag: DW_TAG_member, name: "x", scope: !6, file: !3, line: 4, baseType: !9, size: 64, align: 64)
!9 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !10, size: 64, align: 64)
!10 = !DICompositeType(tag: DW_TAG_structure_type, name: "X", file: !3, line: 1, flags: DIFlagFwdDecl)
!11 = !{i32 2, !"Dwarf Version", i32 4}
!12 = !{i32 2, !"Debug Info Version", i32 3}
!13 = !{!"clang version 3.7.0"}

