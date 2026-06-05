; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; DXDI note: DILabel and llvm.dbg.label are not supported
; DXDI note: llvm.dbg.label reference 2 DILocation.

; Test DBG_LABEL MachineInstr for label debugging.
; REQUIRES: asserts
;
; CHECKMI: DBG_LABEL "top", debug-location !9
; CHECKMI: DBG_LABEL "done", debug-location !11
;
;
; CHECKASM: DEBUG_LABEL: foo:top
; CHECKASM: DEBUG_LABEL: foo:done

source_filename = "debug-label-mi.c"

; Function Attrs: noinline nounwind optnone
define i32 @foo(i32 signext %a, i32 signext %b) #0 !dbg !4 {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  %sum = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  br label %top

top:                                              ; preds = %entry
  call void @llvm.dbg.label(metadata !8), !dbg !9
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %add = add nsw i32 %0, %1
  store i32 %add, ptr %sum, align 4
  br label %done

done:                                             ; preds = %top
  call void @llvm.dbg.label(metadata !10), !dbg !11
  %2 = load i32, ptr %sum, align 4
  ret i32 %2
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.label(metadata)

attributes #0 = { noinline nounwind optnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, isOptimized: false, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "debug-label-mi.c", directory: "./")
!2 = !{}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 1, type: !5, isLocal: false, isDefinition: true, scopeLine: 2, isOptimized: false, unit: !0, retainedNodes: !2)
!5 = !DISubroutineType(types: !6)
!6 = !{!7, !7, !7}
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!8 = !DILabel(scope: !4, name: "top", file: !1, line: 4)
!9 = !DILocation(line: 4, column: 1, scope: !4)
!10 = !DILabel(scope: !4, name: "done", file: !1, line: 7)
!11 = !DILocation(line: 7, column: 1, scope: !4)
