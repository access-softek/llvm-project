; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 2
; CHECK: DICompileUnit: 1
; CHECK: DICompositeType: 1
; CHECK: DIExpression: 2
; CHECK: DIFile: 1
; CHECK: DIFlagFwdDecl: 1
; CHECK: DIGlobalVariable: 1
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; Generated at -O2 -g from:
; typedef struct {} a;
; static struct {
;     long b;
;     a c;
; } d;
; e() {
;     long f = d.b + 1;
;     d.b = f;
; }
; (IR is modified so that d's struct type is forward declared.)

; Check that the global variable "d" is not
; emitted as a fragment if its struct type is
; forward declared but d.c has zero length, so
; a fragment shouldn't be emitted.

source_filename = "t.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.anon = type { i64, %struct.a }
%struct.a = type {}

@d = internal global %struct.anon zeroinitializer, align 8, !dbg !0

; Function Attrs: noinline nounwind
define dso_local i32 @e() #0 !dbg !18 {
entry:
  %0 = load i64, ptr @d, align 8
  %add = add nsw i64 %0, 1
  call void @llvm.dbg.value(metadata i64 %add, metadata !24, metadata !DIExpression()), !dbg !25
  store i64 %add, ptr @d, align 8
  ret i32 undef
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata)

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!14, !15}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "d", scope: !2, file: !3, line: 6, type: !7, isLocal: true, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !{}, globals: !{!0}, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/")
!7 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 3, flags: DIFlagFwdDecl)
!10 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "a", file: !3, line: 2, baseType: !13)
!13 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 1, elements: !{})
!14 = !{i32 7, !"Dwarf Version", i32 4}
!15 = !{i32 2, !"Debug Info Version", i32 3}
!18 = distinct !DISubprogram(name: "e", scope: !3, file: !3, line: 7, type: !19, scopeLine: 7, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !{})
!19 = !DISubroutineType(types: !{!21})
!21 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!24 = !DILocalVariable(name: "f", scope: !18, file: !3, line: 8, type: !10)
!25 = !DILocation(line: 0, scope: !18)
