; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIDerivedType: 2
; CHECK: DIFile: 1
; CHECK: DIGlobalVariable: 1


; From source:
; typedef void x;
; x *y;

; Check that a typedef with no DW_AT_type is produced. The absence of a type is used to imply the 'void' type.


source_filename = "test/DebugInfo/Generic/typedef.ll"

@y = global ptr null, align 8, !dbg !0

!llvm.dbg.cu = !{!5}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "y", scope: null, file: !2, line: 2, type: !3, isLocal: false, isDefinition: true)
!2 = !DIFile(filename: "typedef.cpp", directory: "/tmp/dbginfo")
!3 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64, align: 64)
!4 = !DIDerivedType(tag: DW_TAG_typedef, name: "x", file: !2, line: 1, baseType: null)
!5 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !2, producer: "clang version 3.5.0 ", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !6, retainedTypes: !6, globals: !7, imports: !6)
!6 = !{}
!7 = !{!0}
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 1, !"Debug Info Version", i32 3}
!10 = !{!"clang version 3.5.0 "}

