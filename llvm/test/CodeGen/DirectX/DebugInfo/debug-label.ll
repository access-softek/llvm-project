; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; DXDI note: DILabel and llvm.dbg.label are not supported
; DXDI note: llvm.dbg.label reference 2 DILocation.

;
;
;
; ASM: [[TOP_LOW_PC:[.0-9a-zA-Z]+]]:{{[[:space:]].*}}DEBUG_LABEL: foo:top
; ASM: [[DONE_LOW_PC:[.0-9a-zA-Z]+]]:{{[[:space:]].*}}DEBUG_LABEL: foo:done
; ASM-LABEL: {{debug_info|dwinfo}}
; ASM: DW_TAG_label
; ASM-NEXT: DW_AT_name
; ASM: 1 {{.*}} DW_AT_decl_file
; ASM-NEXT: 4 {{.*}} DW_AT_decl_line
; ASM-NEXT: 9 {{.*}} DW_AT_decl_column
; ASM-NEXT: [[TOP_LOW_PC]]{{.*}} DW_AT_low_pc
; ASM: DW_TAG_label
; ASM-NEXT: DW_AT_name
; ASM: 1 {{.*}} DW_AT_decl_file
; ASM-NEXT: 7 {{.*}} DW_AT_decl_line
; ASM-NEXT: [[DONE_LOW_PC]]{{.*}} DW_AT_low_pc

source_filename = "debug-label.c"

define dso_local i32 @foo(i32 %a, i32 %b) !dbg !6 {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  %sum = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  br label %top

top:
  call void @llvm.dbg.label(metadata !10), !dbg !11
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %add = add nsw i32 %0, %1
  store i32 %add, ptr %sum, align 4
  br label %done

done:
  call void @llvm.dbg.label(metadata !12), !dbg !13
  %2 = load i32, ptr %sum, align 4
  ret i32 %2, !dbg !14
}

declare void @llvm.dbg.label(metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!4}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, isOptimized: false, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "debug-label.c", directory: "./")
!2 = !{}
!3 = !{!10}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!6 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 1, type: !7, isLocal: false, isDefinition: true, scopeLine: 2, isOptimized: false, unit: !0, retainedNodes: !3)
!7 = !DISubroutineType(types: !8)
!8 = !{!9, !9, !9}
!9 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!10 = !DILabel(scope: !6, name: "top", file: !1, line: 4, column: 9)
!11 = !DILocation(line: 4, column: 1, scope: !6)
!12 = !DILabel(scope: !15, name: "done", file: !1, line: 7)
!13 = !DILocation(line: 7, column: 1, scope: !6)
!14 = !DILocation(line: 8, column: 3, scope: !6)
!15 = !DILexicalBlockFile(discriminator: 2, file: !1, scope: !6)
