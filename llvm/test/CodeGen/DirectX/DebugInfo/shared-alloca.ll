; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 1
; CHECK: DIDerivedType: 1
; CHECK: DIExpression: 1
; CHECK: DIFile: 1
; CHECK: DIFlagFwdDecl: 1
; CHECK: DIFlagNonTrivial: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DILexicalBlock: 2
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


;; The dbg.assign linked to the large alloca describes a variable sitting at
;; offset 0, size 64. Check:
;; A) an inlined store to the alloca outside of the bits 0-64 is not attributed
;;    to the variable.
;; B) a fragment expression is not created if the inlined store is the size of
;;    the variable.
;; C) a fragment expression is created if the inlined store is not the size of
;;    the variable.

;; Test A:

;; Test B:

%"struct.llvm::detail::DenseMapPair" = type { %"struct.std::pair" }
%"struct.std::pair" = type { ptr, %"class.llvm::SmallVector" }
%"class.llvm::SmallVector" = type { %"class.llvm::SmallVectorImpl", %"struct.llvm::SmallVectorStorage" }
%"class.llvm::SmallVectorImpl" = type { %"class.llvm::SmallVectorTemplateBase" }
%"class.llvm::SmallVectorTemplateBase" = type { %"class.llvm::SmallVectorTemplateCommon" }
%"class.llvm::SmallVectorTemplateCommon" = type { %"class.llvm::SmallVectorBase" }
%"class.llvm::SmallVectorBase" = type { ptr, i64, i64 }
%"struct.llvm::SmallVectorStorage" = type { [40 x i8] }

define void @_Z6verifyv() {
entry:
  %0 = alloca %"struct.llvm::detail::DenseMapPair", i32 0, align 8, !DIAssignID !5
  call void @llvm.dbg.assign(metadata i1 undef, metadata !6, metadata !DIExpression(), metadata !5, metadata ptr %0, metadata !DIExpression()), !dbg !14
  call void @_ZN4llvm6detail12DenseMapPairIP4SCEVNS_11SmallVectorI6FoldIDLj40EEEEC2ERKS7_(ptr %0)
  ret void
}

define linkonce_odr void @_ZN4llvm6detail12DenseMapPairIP4SCEVNS_11SmallVectorI6FoldIDLj40EEEEC2ERKS7_(ptr %this) {
entry:
  %second.i = getelementptr %"struct.std::pair", ptr %this, i64 0, i32 1
  store i32 0, ptr %second.i, align 4
  %test = getelementptr %"struct.std::pair", ptr %this, i64 0, i32 0
  store i64 1, ptr %test
  store i32 2, ptr %test
  ret void
}

declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 17.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !2, globals: !2, imports: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "reduce.cpp", directory: "")
!2 = !{}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!5 = distinct !DIAssignID()
!6 = !DILocalVariable(name: "a", scope: !7, file: !1, line: 10, type: !12)
!7 = distinct !DILexicalBlock(scope: !8, file: !1, line: 10, column: 3)
!8 = distinct !DILexicalBlock(scope: !9, file: !1, line: 10, column: 3)
!9 = distinct !DISubprogram(name: "verify", linkageName: "_Z6verifyv", scope: !1, file: !1, line: 9, type: !10, scopeLine: 9, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!10 = !DISubroutineType(types: !11)
!11 = !{null}
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "SCEV", file: !1, line: 3, flags: DIFlagFwdDecl | DIFlagNonTrivial, identifier: "_ZTS4SCEV")
!14 = !DILocation(line: 0, scope: !7)

