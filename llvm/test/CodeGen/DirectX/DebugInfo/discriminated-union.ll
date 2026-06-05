; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 4
; CHECK: DIDerivedType: 5
; CHECK: DIExpression: 2
; CHECK: DIFile: 2
; CHECK: DIFlagPrototyped: 1
; CHECK: DILexicalBlock: 1
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 2
; CHECK: DINamespace: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


; Check for a variant part that has two members, one of which has a
; discriminant value.


%F = type { [0 x i8], ptr, [8 x i8] }
%"F::Nope" = type {}

define void @_ZN2e34main17h934ff72f9a38d4bbE() unnamed_addr #0 !dbg !5 {
start:
  %qq = alloca %F, align 8
  call void @llvm.dbg.declare(metadata ptr %qq, metadata !10, metadata !28), !dbg !29
  store ptr null, ptr %qq, !dbg !29
  ret void, !dbg !30
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

attributes #0 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.dbg.cu = !{!2}

!0 = !{i32 1, !"PIE Level", i32 2}
!1 = !{i32 2, !"Debug Info Version", i32 3}
!2 = distinct !DICompileUnit(language: DW_LANG_Rust, file: !3, producer: "clang LLVM (rustc version 1.24.0-dev)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4)
!3 = !DIFile(filename: "e3.rs", directory: "/home/tromey/Rust")
!4 = !{}
!5 = distinct !DISubprogram(name: "main", linkageName: "_ZN2e34mainE", scope: !6, file: !3, line: 2, type: !8, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagMainSubprogram, isOptimized: false, unit: !2, templateParams: !4, retainedNodes: !4)
!6 = !DINamespace(name: "e3", scope: null)
!7 = !DIFile(filename: "<unknown>", directory: "")
!8 = !DISubroutineType(types: !9)
!9 = !{null}
!10 = !DILocalVariable(name: "qq", scope: !11, file: !3, line: 3, type: !12, align: 8)
!11 = distinct !DILexicalBlock(scope: !5, file: !3, line: 3, column: 4)
!12 = !DICompositeType(tag: DW_TAG_structure_type, name: "F", scope: !6, file: !7, size: 128, align: 64, elements: !13, identifier: "7ce1efff6b82281ab9ceb730566e7e20")
!13 = !{!14}
!14 = !DICompositeType(tag: DW_TAG_variant_part, name: "", scope: !12, file: !7, size: 128, align: 64, elements: !16, identifier: "7ce1efff6b82281ab9ceb730566e7e20", discriminator: !15)
!15 = !DIDerivedType(tag: DW_TAG_member, scope: !14, file: !7, baseType: !27, size: 64, align: 64, flags: DIFlagArtificial)
!16 = !{!17, !24}
!17 = !DIDerivedType(tag: DW_TAG_member, scope: !14, file: !7, baseType: !18, size: 128, align: 64)
!18 = !DICompositeType(tag: DW_TAG_structure_type, name: "Yep", scope: !12, file: !7, size: 128, align: 64, elements: !19, identifier: "7ce1efff6b82281ab9ceb730566e7e20::Yep")
!19 = !{!20, !22}
!20 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !18, file: !7, baseType: !21, size: 8, align: 8, offset: 64)
!21 = !DIBasicType(name: "u8", size: 8, encoding: DW_ATE_unsigned)
!22 = !DIDerivedType(tag: DW_TAG_member, name: "__1", scope: !18, file: !7, baseType: !23, size: 64, align: 64)
!23 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&u8", baseType: !21, size: 64, align: 64)
!24 = !DIDerivedType(tag: DW_TAG_member, scope: !14, file: !7, baseType: !25, size: 128, align: 64, extraData: i128 18446744073709551616)
!25 = !DICompositeType(tag: DW_TAG_structure_type, name: "Nope", scope: !12, file: !7, size: 128, align: 64, elements: !4, identifier: "7ce1efff6b82281ab9ceb730566e7e20::Nope")
!27 = !DIBasicType(name: "u64", size: 64, encoding: DW_ATE_unsigned)
!28 = !DIExpression()
!29 = !DILocation(line: 3, scope: !11)
!30 = !DILocation(line: 4, scope: !5)
