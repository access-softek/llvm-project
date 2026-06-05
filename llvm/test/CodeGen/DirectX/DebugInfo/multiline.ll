; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DILocation: 7
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; XFAIL: target={{.*}}-aix{{.*}}

; Check that the assembly output properly handles is_stmt changes. And since
; we're testing anyway, check the integrated assembler too.

; Generated with clang from multiline.c:
; void f1();
; void f2() {
;   f1(); f1(); f1();
;   f1(); f1(); f1();
; }



; INT: {{^}}Address
; INT: -----
; INT:      3 3 1 0 0 0 is_stmt prologue_end{{$}}
; INT-NEXT: 3 9 1 0 0 0 {{$}}
; INT-NEXT: 3 15 1 0 0 0 {{$}}
; INT-NEXT: 4 3 1 0 0 0 is_stmt{{$}}
; INT-NEXT: 4 9 1 0 0 0 {{$}}
; INT-NEXT: 4 15 1 0 0 0 {{$}}
; INT-NEXT: 5 1 1 0 0 0 is_stmt{{( epilogue_begin)?}}{{$}}


; Function Attrs: nounwind
define void @f2() #0 !dbg !4 {
entry:
  call void (...) @f1(), !dbg !11
  call void (...) @f1(), !dbg !12
  call void (...) @f1(), !dbg !13
  call void (...) @f1(), !dbg !14
  call void (...) @f1(), !dbg !15
  call void (...) @f1(), !dbg !16
  ret void, !dbg !17
}

declare void @f1(...) #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.6.0 (trunk 225000) (llvm/trunk 224999)", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "multiline.c", directory: "/tmp/dbginfo")
!2 = !{}
!4 = distinct !DISubprogram(name: "f2", line: 2, isLocal: false, isDefinition: true, isOptimized: false, unit: !0, scopeLine: 2, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "multiline.c", directory: "/tmp/dbginfo")
!6 = !DISubroutineType(types: !7)
!7 = !{null}
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{!"clang version 3.6.0 (trunk 225000) (llvm/trunk 224999)"}
!11 = !DILocation(line: 3, column: 3, scope: !4)
!12 = !DILocation(line: 3, column: 9, scope: !4)
!13 = !DILocation(line: 3, column: 15, scope: !4)
!14 = !DILocation(line: 4, column: 3, scope: !4)
!15 = !DILocation(line: 4, column: 9, scope: !4)
!16 = !DILocation(line: 4, column: 15, scope: !4)
!17 = !DILocation(line: 5, column: 1, scope: !4)
