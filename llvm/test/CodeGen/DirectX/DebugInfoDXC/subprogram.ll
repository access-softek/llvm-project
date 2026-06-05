;; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
;; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
;; RUN: %dxc /dumpbin %t.bc | FileCheck %s

define i32 @foo(i32 %a) !dbg !3 {
  %call = tail call i32 @bar(i32 %a)
  ret i32 %call
}

declare !dbg !7 i32 @bar(i32)

; CHECK-DAG: !llvm.dbg.cu = !{[[CU:![0-9]+]]}
!llvm.dbg.cu = !{!0}

!llvm.module.flags = !{!2}

; CHECK-DAG: [[CU]] = distinct !DICompileUnit(language: DW_LANG_C11, file: [[F:![0-9]+]], producer: "clang", isOptimized: true, runtimeVersion: 0, emissionKind: 1, subprograms: [[SPS:![0-9]+]])
; CHECK-DAG: [[F]] = !DIFile(filename: "subprogram.c", directory: "")
; CHECK-DAG: [[SPS]] = !{[[SP:![0-9]+]]}
; CHECK-DAG: [[SP]] = !DISubprogram(name: "foo", scope: [[F]], file: [[F]], line: 1, type: [[ST:![0-9]+]], isLocal: false, isDefinition: true, scopeLine: 1, flags: DIFlagPrototyped, isOptimized: true, function: i32 (i32)* @foo)
; CHECK-DAG: [[ST]] = !DISubroutineType(types: [[TS:![0-9]+]])
; CHECK-DAG: [[TS]] = !{[[BT:![0-9]+]], [[BT]]}
; CHECK-DAG: [[BT]] = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)

; CHECK-NOT: !DISubprogram

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "clang", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "subprogram.c", directory: "")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 1, type: !4, scopeLine: 1, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0)
!4 = !DISubroutineType(types: !5)
!5 = !{!6, !6}
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = !DISubprogram(name: "bar", scope: !1, file: !1, line: 1, type: !4, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
