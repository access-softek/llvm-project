; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DILexicalBlock: 1
; CHECK: DILocation: 2
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; XFAIL: target={{.*}}-aix{{.*}}

; DISABLE-NOT: DW_AT_APPLE_omit_frame_ptr


define i32 @foo() nounwind ssp !dbg !1 {
entry:
  %retval = alloca i32                            ; <ptr> [#uses=2]
  %0 = alloca i32                                 ; <ptr> [#uses=2]
  %"alloca point" = bitcast i32 0 to i32          ; <i32> [#uses=0]
  store i32 42, ptr %0, align 4, !dbg !0
  %1 = load i32, ptr %0, align 4, !dbg !0             ; <i32> [#uses=1]
  store i32 %1, ptr %retval, align 4, !dbg !0
  br label %return, !dbg !0

return:                                           ; preds = %entry
  %retval1 = load i32, ptr %retval, !dbg !0           ; <i32> [#uses=1]
  ret i32 %retval1, !dbg !7
}

!llvm.dbg.cu = !{!3}
!llvm.module.flags = !{!12}
!9 = !{!1}

!0 = !DILocation(line: 2, scope: !1)
!1 = distinct !DISubprogram(name: "foo", linkageName: "foo", line: 2, isLocal: false, isDefinition: true, virtualIndex: 6, isOptimized: false, unit: !3, scopeLine: 2, file: !10, scope: null, type: !4)
!2 = !DIFile(filename: "a.c", directory: "/tmp")
!3 = distinct !DICompileUnit(language: DW_LANG_C89, producer: "4.2.1 (Based on Apple Inc. build 5658) (LLVM build)", isOptimized: false, emissionKind: FullDebug, file: !10, enums: !11, retainedTypes: !11, imports:  null)
!4 = !DISubroutineType(types: !5)
!5 = !{!6}
!6 = !DIBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!7 = !DILocation(line: 2, scope: !8)
!8 = distinct !DILexicalBlock(line: 2, column: 0, file: !10, scope: !1)
!10 = !DIFile(filename: "a.c", directory: "/tmp")
!11 = !{}
!12 = !{i32 1, !"Debug Info Version", i32 3}
