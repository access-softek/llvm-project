; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 3
; CHECK: DIFile: 3



!llvm.dbg.cu = !{!0, !6, !10}
!llvm.module.flags = !{!8, !9}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "test1.c", directory: "/tmp")
!2 = !{}
!3 = !DIFile(filename: "test1.c", directory: "/tmp")
!4 = !DISubroutineType(types: !7)
!5 = !{null}
!6 = distinct !DICompileUnit(sourceLanguageName: DW_LNAME_C, producer: "clang", isOptimized: false, emissionKind: FullDebug, file: !7, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!7 = !DIFile(filename: "test2.c", directory: "/tmp")
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 1, !"Debug Info Version", i32 3}
!10 = distinct !DICompileUnit(sourceLanguageName: 0, producer: "clang", isOptimized: false, emissionKind: FullDebug, file: !11, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!11 = !DIFile(filename: "test3.c", directory: "/tmp")
