; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIExpression: 6
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DILexicalBlock: 1
; CHECK: DILocalVariable: 2
; CHECK: DILocation: 8
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


;; Test assignment tracking debug info when mem2reg promotes an alloca with
;; stores requiring insertion of a phi. Check the output when the stores are
;; tagged and also untagged (test manually updated for the latter by linking a
;; dbg.assgin for another variable "b" to the alloca).



;; $ cat test.cpp
;; int f(int a) {
;;   if (a)
;;     a += 1;
;;   else
;;     a = -1;
;;   return a;
;; }

define dso_local noundef i32 @_Z1fi(i32 noundef %a) #0 !dbg !7 {
entry:
  %a.addr = alloca i32, align 4, !DIAssignID !13
  call void @llvm.dbg.assign(metadata i1 undef, metadata !12, metadata !DIExpression(), metadata !13, metadata ptr %a.addr, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.assign(metadata i1 undef, metadata !30, metadata !DIExpression(), metadata !13, metadata ptr %a.addr, metadata !DIExpression()), !dbg !14
  store i32 %a, ptr %a.addr, align 4, !DIAssignID !19
  call void @llvm.dbg.assign(metadata i32 %a, metadata !12, metadata !DIExpression(), metadata !19, metadata ptr %a.addr, metadata !DIExpression()), !dbg !14
  %0 = load i32, ptr %a.addr, align 4, !dbg !20
  %tobool = icmp ne i32 %0, 0, !dbg !20
  br i1 %tobool, label %if.then, label %if.else, !dbg !22

if.then:                                          ; preds = %entry
  %1 = load i32, ptr %a.addr, align 4, !dbg !23
  %add = add nsw i32 %1, 1, !dbg !23
  store i32 %add, ptr %a.addr, align 4, !dbg !23, !DIAssignID !24
  call void @llvm.dbg.assign(metadata i32 %add, metadata !12, metadata !DIExpression(), metadata !24, metadata ptr %a.addr, metadata !DIExpression()), !dbg !14
  br label %if.end, !dbg !25

if.else:                                          ; preds = %entry
  store i32 -1, ptr %a.addr, align 4, !dbg !26, !DIAssignID !27
  call void @llvm.dbg.assign(metadata i32 -1, metadata !12, metadata !DIExpression(), metadata !27, metadata ptr %a.addr, metadata !DIExpression()), !dbg !14
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %2 = load i32, ptr %a.addr, align 4, !dbg !28
  ret i32 %2, !dbg !29
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
!7 = distinct !DISubprogram(name: "f", linkageName: "_Z1fi", scope: !1, file: !1, line: 1, type: !8, scopeLine: 1, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !11)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !{!12}
!12 = !DILocalVariable(name: "a", arg: 1, scope: !7, file: !1, line: 1, type: !10)
!13 = distinct !DIAssignID()
!14 = !DILocation(line: 0, scope: !7)
!19 = distinct !DIAssignID()
!20 = !DILocation(line: 2, column: 7, scope: !21)
!21 = distinct !DILexicalBlock(scope: !7, file: !1, line: 2, column: 7)
!22 = !DILocation(line: 2, column: 7, scope: !7)
!23 = !DILocation(line: 3, column: 7, scope: !21)
!24 = distinct !DIAssignID()
!25 = !DILocation(line: 3, column: 5, scope: !21)
!26 = !DILocation(line: 5, column: 7, scope: !21)
!27 = distinct !DIAssignID()
!28 = !DILocation(line: 6, column: 10, scope: !7)
!29 = !DILocation(line: 6, column: 3, scope: !7)
!30 = !DILocalVariable(name: "b", arg: 2, scope: !7, file: !1, line: 1, type: !10)
!1000 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
