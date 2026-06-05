; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -O0 -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIExpression: 2
; CHECK: DIFile: 1
; CHECK: DILocalVariable: 2
; CHECK: DILocation: 15
; CHECK: DISubprogram: 3


; The '%bar' alloca will be promoted to an SSA register by mem2reg: test that
; zero line number are assigned to the dbg.value intrinsics that are inserted
; to represent changes in variable value. No machine instructions are
; generated from these dbg.values so their lines are irrelevant, only the
; scope and inlining information must be correct.

; In the second function here, LowerDbgDeclare will promote various variable
; accesses of a dbg.declare'd alloca into dbg.values. Check that their line
; numbers are sane too. (IR copied from DebugInfo/X86/formal_parameter.ll).


;

define i32 @foo(ptr %bees, ptr %output) {
entry:
  %bar = alloca i32
  call void @llvm.dbg.declare(metadata ptr %bar, metadata !7, metadata !DIExpression()), !dbg !6
  store i32 0, ptr %bar
  br label %bb1, !dbg !6

bb1:
  %totest = load i32, ptr %bees, !dbg !8
  %load1 = load i32, ptr %bar, !dbg !9
  %add = add i32 %load1, 1, !dbg !10
  store i32 %add, ptr %bar, !dbg !11
  %toret = add i32 %add, 2, !dbg !12
  %cond = icmp ult i32 %totest, %load1, !dbg !13
  br i1 %cond, label %bb1, label %bb2, !dbg !14

bb2:
  store i32 %toret, ptr %bar, !dbg !16
  ret i32 %toret
}

; In the following, the dbg.value created for the store should get the stores
; line number, the other dbg.values should be unknown.
;

define void @bar(i32 %map) !dbg !20 {
entry:
  %map.addr = alloca i32, align 4
  store i32 %map, ptr %map.addr, align 4, !dbg !27
  call void @llvm.dbg.declare(metadata ptr %map.addr, metadata !21, metadata !DIExpression()), !dbg !22
  %call = call i32 (ptr, ...) @lookup(ptr %map.addr), !dbg !23
%0 = load i32, ptr %map.addr, align 4, !dbg !24
  %call1 = call i32 (i32, ...) @verify(i32 %0), !dbg !25
  ret void, !dbg !26
}

declare void @llvm.dbg.value(metadata, metadata, metadata)
declare void @llvm.dbg.declare(metadata, metadata, metadata)
declare i32 @verify(...)
declare i32 @lookup(...)



!llvm.module.flags = !{!4}
!llvm.dbg.cu = !{!2}
!1 = !DILocalVariable(name: "bees", scope: !5, type: null)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !3, producer: "beards", isOptimized: true, runtimeVersion: 4, emissionKind: FullDebug)
!3 = !DIFile(filename: "bees.cpp", directory: "")
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = distinct !DISubprogram(name: "nope", scope: !3, file: !3, line: 1, unit: !2)
!6 = !DILocation(line: 1, scope: !5)
!7 = !DILocalVariable(name: "flannel", scope: !5, type: null)
!8 = !DILocation(line: 2, scope: !5)
!9 = !DILocation(line: 3, scope: !5)
!10 = !DILocation(line: 4, scope: !5)
!11 = !DILocation(line: 5, scope: !5)
!12 = !DILocation(line: 6, scope: !5)
!13 = !DILocation(line: 7, scope: !5)
!14 = !DILocation(line: 8, scope: !5)
!15 = distinct !DISubprogram(name: "wat", scope: !2, file: !3, line: 10, unit: !2)
!16 = !DILocation(line: 9, scope: !15, inlinedAt: !14)
!20 = distinct !DISubprogram(name: "thin", scope: !3, file: !3, line: 20, unit: !2)
!21 = !DILocalVariable(name: "floogie", scope: !20, type: null)
!22 = !DILocation(line: 21, scope: !20)
!23 = !DILocation(line: 22, scope: !20)
!24 = !DILocation(line: 23, scope: !20)
!25 = !DILocation(line: 24, scope: !20)
!26 = !DILocation(line: 25, scope: !20)
!27 = !DILocation(line: 20, scope: !20)
