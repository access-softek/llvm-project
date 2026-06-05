; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIExpression: 3
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 2
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 9
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 2


;; Check that all DIAssignID metadata that are inlined are replaced with new
;; versions. Otherwise two inlined instances of an assignment will be considered
;; to be the same assignment.
;;
;; $cat test.cpp
;; __attribute__((always_inline))
;; int get() { int val = 5; return val; }
;; void fun() {
;;   get();
;;   get();
;; }

;
;
;

define dso_local i32 @_Z3getv() !dbg !7 {
entry:
  %val = alloca i32, align 4, !DIAssignID !13
  call void @llvm.dbg.assign(metadata i1 undef, metadata !12, metadata !DIExpression(), metadata !13, metadata ptr %val, metadata !DIExpression()), !dbg !14
  %0 = bitcast ptr %val to ptr, !dbg !15
  call void @llvm.lifetime.start.p0(i64 4, ptr %0), !dbg !15
  store i32 5, ptr %val, align 4, !dbg !16, !DIAssignID !21
  call void @llvm.dbg.assign(metadata i32 5, metadata !12, metadata !DIExpression(), metadata !21, metadata ptr %val, metadata !DIExpression()), !dbg !14
  %1 = load i32, ptr %val, align 4, !dbg !22
  %2 = bitcast ptr %val to ptr, !dbg !23
  call void @llvm.lifetime.end.p0(i64 4, ptr %2), !dbg !23
  ret i32 %1, !dbg !24
}

declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture)
declare void @llvm.dbg.declare(metadata, metadata, metadata)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture)
declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata)

; Function Attrs: nounwind mustprogress
define dso_local void @_Z3funv() !dbg !25 {
entry:
  %call = call i32 @_Z3getv(), !dbg !28
  %call1 = call i32 @_Z3getv(), !dbg !29
  ret void, !dbg !30
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !1000}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 12.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.cpp", directory: "")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 12.0.0"}
!7 = distinct !DISubprogram(name: "get", linkageName: "_Z3getv", scope: !1, file: !1, line: 2, type: !8, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !11)
!8 = !DISubroutineType(types: !9)
!9 = !{!10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !{!12}
!12 = !DILocalVariable(name: "val", scope: !7, file: !1, line: 2, type: !10)
!13 = distinct !DIAssignID()
!14 = !DILocation(line: 0, scope: !7)
!15 = !DILocation(line: 2, column: 13, scope: !7)
!16 = !DILocation(line: 2, column: 17, scope: !7)
!21 = distinct !DIAssignID()
!22 = !DILocation(line: 2, column: 33, scope: !7)
!23 = !DILocation(line: 2, column: 38, scope: !7)
!24 = !DILocation(line: 2, column: 26, scope: !7)
!25 = distinct !DISubprogram(name: "fun", linkageName: "_Z3funv", scope: !1, file: !1, line: 3, type: !26, scopeLine: 3, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!26 = !DISubroutineType(types: !27)
!27 = !{null}
!28 = !DILocation(line: 4, column: 3, scope: !25)
!29 = !DILocation(line: 5, column: 3, scope: !25)
!30 = !DILocation(line: 6, column: 1, scope: !25)
!1000 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
