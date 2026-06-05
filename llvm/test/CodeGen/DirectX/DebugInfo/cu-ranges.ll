; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIExpression: 3
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 2
; CHECK: DILocalVariable: 2
; CHECK: DILocation: 4
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 1


; Check that we emit ranges for this which has a non-traditional section and a normal section.


; FIXME: When we get better dumping facilities we'll want to elaborate here.

; Function Attrs: nounwind
define i32 @foo(i32 %a) #0 section "__TEXT,__foo" !dbg !4 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  call void @llvm.dbg.declare(metadata ptr %a.addr, metadata !13, metadata !DIExpression()), !dbg !14
  %0 = load i32, ptr %a.addr, align 4, !dbg !15
  %add = add nsw i32 %0, 5, !dbg !15
  ret i32 %add, !dbg !15
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: nounwind
define i32 @bar(i32 %a) #0 !dbg !9 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  call void @llvm.dbg.declare(metadata ptr %a.addr, metadata !16, metadata !DIExpression()), !dbg !17
  %0 = load i32, ptr %a.addr, align 4, !dbg !18
  %add = add nsw i32 %0, 5, !dbg !18
  ret i32 %add, !dbg !18
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!10, !11}
!llvm.ident = !{!12}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.5.0 (trunk 204164) (llvm/trunk 204183)", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "foo.c", directory: "/usr/local/google/home/echristo")
!2 = !{}
!4 = distinct !DISubprogram(name: "foo", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 1, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "foo.c", directory: "/usr/local/google/home/echristo")
!6 = !DISubroutineType(types: !7)
!7 = !{!8, !8}
!8 = !DIBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = distinct !DISubprogram(name: "bar", line: 5, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 5, file: !1, scope: !5, type: !6, retainedNodes: !2)
!10 = !{i32 2, !"Dwarf Version", i32 4}
!11 = !{i32 1, !"Debug Info Version", i32 3}
!12 = !{!"clang version 3.5.0 (trunk 204164) (llvm/trunk 204183)"}
!13 = !DILocalVariable(name: "a", line: 1, arg: 1, scope: !4, file: !5, type: !8)
!14 = !DILocation(line: 1, scope: !4)
!15 = !DILocation(line: 2, scope: !4)
!16 = !DILocalVariable(name: "a", line: 5, arg: 1, scope: !9, file: !5, type: !8)
!17 = !DILocation(line: 5, scope: !9)
!18 = !DILocation(line: 6, scope: !9)

