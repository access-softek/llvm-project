; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 1
; CHECK: DIDerivedType: 4
; CHECK: DIFile: 1
; CHECK: DIFlagArtificial: 2
; CHECK: DIFlagObjectPointer: 1
; CHECK: DIFlagPrototyped: 4
; CHECK: DISubprogram: 4
; CHECK: DISubroutineType: 2


; Generated from the following C++ source code:
;
; struct A {
;   virtual void f();
;   virtual void g();
; };
;
; void A::f() {}
; void A::g() {}
;
; and manually edited to set virtualIndex attribute on the A::g subprogram to
; 4294967295.



%struct.A = type { ptr }

@_ZTV1A = unnamed_addr constant [4 x ptr] [ptr null, ptr null, ptr @_ZN1A1fEv, ptr @_ZN1A1gEv], align 8

define void @_ZN1A1fEv(ptr %this) unnamed_addr !dbg !18 {
  ret void
}

define void @_ZN1A1gEv(ptr %this) unnamed_addr !dbg !19 {
  ret void
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!20, !21}
!llvm.ident = !{!22}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "x", directory: "x")
!2 = !{}
!3 = !{!4}
!4 = !DICompositeType(tag: DW_TAG_structure_type, name: "A", file: !1, line: 1, size: 64, align: 64, elements: !5, vtableHolder: !4, identifier: "_ZTS1A")
!5 = !{!6, !12, !16}
!6 = !DIDerivedType(tag: DW_TAG_member, name: "_vptr$A", scope: !1, file: !1, baseType: !7, size: 64, flags: DIFlagArtificial)
!7 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !8, size: 64)
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "__vtbl_ptr_type", baseType: !9, size: 64)
!9 = !DISubroutineType(types: !10)
!10 = !{!11}
!11 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!12 = !DISubprogram(name: "f", linkageName: "_ZN1A1fEv", scope: !4, file: !1, line: 2, type: !13, isLocal: false, isDefinition: false, scopeLine: 2, containingType: !4, virtuality: DW_VIRTUALITY_virtual, virtualIndex: 0, flags: DIFlagPrototyped, isOptimized: false)
!13 = !DISubroutineType(types: !14)
!14 = !{null, !15}
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64, align: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!16 = !DISubprogram(name: "g", linkageName: "_ZN1A1gEv", scope: !4, file: !1, line: 3, type: !13, isLocal: false, isDefinition: false, scopeLine: 3, containingType: !4, virtuality: DW_VIRTUALITY_virtual, virtualIndex: 4294967295, flags: DIFlagPrototyped, isOptimized: false)
!18 = distinct !DISubprogram(name: "f", linkageName: "_ZN1A1fEv", scope: !4, file: !1, line: 6, type: !13, isLocal: false, isDefinition: true, scopeLine: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, declaration: !12, retainedNodes: !2)
!19 = distinct !DISubprogram(name: "g", linkageName: "_ZN1A1gEv", scope: !4, file: !1, line: 7, type: !13, isLocal: false, isDefinition: true, scopeLine: 7, flags: DIFlagPrototyped, isOptimized: false, unit: !0, declaration: !16, retainedNodes: !2)
!20 = !{i32 2, !"Dwarf Version", i32 4}
!21 = !{i32 2, !"Debug Info Version", i32 3}
!22 = !{!"clang version 3.9.0 (trunk 263469) (llvm/trunk 263156)"}
!23 = !DILocalVariable(name: "this", arg: 1, scope: !18, type: !24, flags: DIFlagArtificial | DIFlagObjectPointer)
!24 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64, align: 64)
!25 = !DIExpression()
!26 = !DILocation(line: 0, scope: !18)
!27 = !DILocation(line: 6, column: 14, scope: !18)
!28 = !DILocalVariable(name: "this", arg: 1, scope: !19, type: !24, flags: DIFlagArtificial | DIFlagObjectPointer)
!29 = !DILocation(line: 0, scope: !19)
!30 = !DILocation(line: 7, column: 14, scope: !19)
