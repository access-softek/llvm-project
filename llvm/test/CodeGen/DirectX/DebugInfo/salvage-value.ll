; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIExpression: 6
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DILocalVariable: 6
; CHECK: DILocation: 3
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


;; Hand-written (the debug info doesn't necessarily make sense and isn't fully
;; formed). Test salvaging a dbg.assign value and address. Checks and comments
;; are inline.

define dso_local void @fun(i32  %x, i32 %y, ptr %p) !dbg !7 {
entry:
  %add = add nsw i32 %x, 1, !dbg !22
  call void @llvm.dbg.assign(metadata i32 %add, metadata !14, metadata !DIExpression(), metadata !28, metadata ptr %p, metadata !DIExpression()), !dbg !16
;; %add is salvaged.

 %add1 = add nsw i32 %x, %y, !dbg !29
 call void @llvm.dbg.assign(metadata i32 %add1, metadata !32, metadata !DIExpression(), metadata !31, metadata ptr %p, metadata !DIExpression()), !dbg !16
;; %add1 is salvaged using a variadic expression.

  %arrayidx0 = getelementptr inbounds i32, ptr %p, i32 0
  call void @llvm.dbg.assign(metadata i32 %x, metadata !14, metadata !DIExpression(), metadata !17, metadata ptr %arrayidx0, metadata !DIExpression()), !dbg !16
;; %arrayidx0 is salvaged (zero offset, so the gep is just replaced with %p).

  %arrayidx1 = getelementptr inbounds i32, ptr %p, i32 1
  call void @llvm.dbg.assign(metadata i32 %x, metadata !33, metadata !DIExpression(), metadata !18, metadata ptr %arrayidx1, metadata !DIExpression()), !dbg !16
;; %arrayidx1 is salvaged.

  %arrayidx2 = getelementptr inbounds i32, ptr %p, i32 %x
  call void @llvm.dbg.assign(metadata i32 %x, metadata !34, metadata !DIExpression(), metadata !19, metadata ptr %arrayidx2, metadata !DIExpression()), !dbg !16
;; Variadic DIExpressions for dbg.assign address component is not supported -
;; set poison.

  ret void
}

declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !1000}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 14.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.cpp", directory: "/")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 7, !"uwtable", i32 1}
!6 = !{!"clang version 14.0.0"}
!7 = distinct !DISubprogram(name: "fun", linkageName: "fun", scope: !1, file: !1, line: 2, type: !8, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !11)
!8 = !DISubroutineType(types: !9)
!9 = !{null, !10, !10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !{!12, !13, !14}
!12 = !DILocalVariable(name: "x", arg: 1, scope: !7, file: !1, line: 2, type: !10)
!13 = !DILocalVariable(name: "y", arg: 2, scope: !7, file: !1, line: 2, type: !10)
!14 = !DILocalVariable(name: "Local", scope: !7, file: !1, line: 3, type: !10)
!16 = !DILocation(line: 0, scope: !7)
!17 = distinct !DIAssignID()
!18 = distinct !DIAssignID()
!19 = distinct !DIAssignID()
!21 = !DILocation(line: 3, column: 3, scope: !7)
!22 = !DILocation(line: 3, column: 17, scope: !7)
!28 = distinct !DIAssignID()
!29 = !DILocation(line: 4, column: 13, scope: !7)
!31 = distinct !DIAssignID()
!32 = !DILocalVariable(name: "Local1", scope: !7, file: !1, line: 3, type: !10)
!33 = !DILocalVariable(name: "Local2", scope: !7, file: !1, line: 3, type: !10)
!34 = !DILocalVariable(name: "Local3", scope: !7, file: !1, line: 3, type: !10)
!35 = !DILocalVariable(name: "Local4", scope: !7, file: !1, line: 3, type: !10)
!1000 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
