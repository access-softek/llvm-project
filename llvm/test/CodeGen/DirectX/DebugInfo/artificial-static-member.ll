; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 1
; CHECK: DIDerivedType: 1
; CHECK: DIFile: 1
; CHECK: DIFlagArtificial: 1
; CHECK: DIFlagStaticMember: 1
; CHECK: DIGlobalVariable: 1

; REQUIRES: target={{x86_64-.*-linux.*}}

; LLVM IR generated from:

; struct S {
;   static int Member;   <-- Manually marked as artificial
; };
; int S::Member = 1;

source_filename = "artificial-static-member.cpp"
target triple = "x86_64-pc-linux-gnu"

@_ZN1S6MemberE = dso_local global i32 1, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!9, !10}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "Member", linkageName: "_ZN1S6MemberE", scope: !2, type: !5, isLocal: false, isDefinition: true, declaration: !6)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !3, emissionKind: FullDebug, globals: !4)
!3 = !DIFile(filename: "artificial-static-member.cpp", directory: "")
!4 = !{!0}
!5 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!6 = !DIDerivedType(tag: DW_TAG_variable, name: "Member", scope: !7, baseType: !5, flags: DIFlagArtificial | DIFlagStaticMember)
!7 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "S", size: 8, flags: DIFlagTypePassByValue, elements: !8, identifier: "_ZTS1S")
!8 = !{!6}
!9 = !{i32 7, !"Dwarf Version", i32 5}
!10 = !{i32 2, !"Debug Info Version", i32 3}


