; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIExpression: 11
; CHECK: DIFile: 2
; CHECK: DIFlagPrototyped: 2
; CHECK: DILexicalBlock: 1
; CHECK: DILocalVariable: 2
; CHECK: DILocation: 10
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 2


;; Test that dbg.value intrinsics are inlined, remapped, and have their
;; dilocation updated just like normal instructions. This becomes
;; important when debug-info records case to be instructions.
;;
;; test should be inlined into test2

;;
;; dbg.values in this block should be remapped to the local load, but also
;; the Argument to the calling test2 function.
;;
;
;; Similarly, the end block should retain remapped dbg.values, with the second
;; referring to the @global_var load in the entry block. Check that we clone
;; from the terminator correctly.
;
;
;; More or less the same checks again in the exit block, this time at the head
;; of the block, and on a terminator that gets elided.
;
;
;
;; Test that the metadata maps onto the correct things, and that the DILocations
;; attached to the intrinsics have been inlined.
;

target triple = "x86_64--"

@global_var = external global i32

define internal i32 @test(i32 %k, i32 %foo, i32 %bar)  !dbg !4 {
entry:
  %retval = alloca i32, align 4
  %k.addr = alloca i32, align 4
  %k2 = alloca i32, align 4
  store i32 %k, ptr %k.addr, align 4
  call void @llvm.dbg.value(metadata ptr %k.addr, metadata !13, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.value(metadata ptr %k2, metadata !15, metadata !DIExpression()), !dbg !16
  %0 = load i32, ptr %k.addr, align 4, !dbg !16
  %call = call i32 @_Z8test_exti(i32 %0), !dbg !16
  store i32 %call, ptr %k2, align 4, !dbg !16
  %1 = load i32, ptr %k2, align 4, !dbg !17
  %cmp = icmp sgt i32 %1, 100, !dbg !17
  br i1 %cmp, label %if.then, label %if.end, !dbg !17

if.then:                                          ; preds = %entry
  %2 = load i32, ptr %k2, align 4, !dbg !18
  call void @llvm.dbg.value(metadata i32 %2, metadata !13, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.value(metadata i32 %foo, metadata !15, metadata !DIExpression()), !dbg !16
  store i32 %2, ptr %retval, !dbg !18
  br label %return, !dbg !18

if.end:                                           ; preds = %entry
  store i32 0, ptr %retval, !dbg !19
  call void @llvm.dbg.value(metadata i32 0, metadata !13, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.value(metadata i32 %k, metadata !15, metadata !DIExpression()), !dbg !16
  br label %return, !dbg !19

return:                                           ; preds = %if.end, %if.then
  call void @llvm.dbg.value(metadata i32 %k, metadata !13, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.value(metadata i32 %bar, metadata !15, metadata !DIExpression()), !dbg !16
  %3 = load i32, ptr %retval, !dbg !20
  call void @llvm.dbg.value(metadata i32 1, metadata !13, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.value(metadata i32 1, metadata !15, metadata !DIExpression()), !dbg !16
  ret i32 %3, !dbg !20
}

declare i32 @_Z8test_exti(i32)

define i32 @test2(i32 %foo, i32 %bar) !dbg !10 {
entry:
  %exn.slot = alloca ptr
  %ehselector.slot = alloca i32
  %e = alloca i32, align 4
  %0 = load i32, ptr @global_var, align 4, !dbg !21
  %call = call i32 @test(i32 %0, i32 %foo, i32 %bar), !dbg !21
  br label %try.cont, !dbg !23

try.cont:                                         ; preds = %catch, %invoke.cont
  store i32 1, ptr @global_var, align 4, !dbg !29
  ret i32 0, !dbg !30
}

declare void @llvm.dbg.value(metadata, metadata, metadata) #1

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!31}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.3 ", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "<unknown>", directory: "")
!2 = !{}
!4 = distinct !DISubprogram(name: "test", linkageName: "_Z4testi", line: 4, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 4, file: !5, scope: !6, type: !7, retainedNodes: !2)
!5 = !DIFile(filename: "test.cpp", directory: "")
!6 = !DIFile(filename: "test.cpp", directory: "")
!7 = !DISubroutineType(types: !8)
!8 = !{!9, !9}
!9 = !DIBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = distinct !DISubprogram(name: "test2", linkageName: "_Z5test2v", line: 11, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 11, file: !5, scope: !6, type: !11, retainedNodes: !2)
!11 = !DISubroutineType(types: !12)
!12 = !{!9}
!13 = !DILocalVariable(name: "k", line: 4, arg: 1, scope: !4, file: !6, type: !9)
!14 = !DILocation(line: 4, scope: !4)
!15 = !DILocalVariable(name: "k2", line: 5, scope: !4, file: !6, type: !9)
!16 = !DILocation(line: 5, scope: !4)
!17 = !DILocation(line: 6, scope: !4)
!18 = !DILocation(line: 7, scope: !4)
!19 = !DILocation(line: 8, scope: !4)
!20 = !DILocation(line: 9, scope: !4)
!21 = !DILocation(line: 14, scope: !22)
!22 = distinct !DILexicalBlock(line: 13, column: 0, file: !5, scope: !10)
!23 = !DILocation(line: 15, scope: !22)
!24 = !DILocalVariable(name: "e", line: 16, scope: !10, file: !6, type: !9)
!25 = !DILocation(line: 16, scope: !10)
!26 = !DILocation(line: 17, scope: !27)
!27 = distinct !DILexicalBlock(line: 16, column: 0, file: !5, scope: !10)
!28 = !DILocation(line: 18, scope: !27)
!29 = !DILocation(line: 19, scope: !10)
!30 = !DILocation(line: 20, scope: !10)
!31 = !{i32 1, !"Debug Info Version", i32 3}
