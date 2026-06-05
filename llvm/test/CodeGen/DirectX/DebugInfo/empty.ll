; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: llvm-dis %t.bc -o - | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1

; UNSUPPORTED: target={{.*}}-aix{{.*}}

; Expect no line table entry since there are no functions and file references in this compile unit


!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!5}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.1 (trunk 143523)", isOptimized: true, emissionKind: FullDebug, file: !4, enums: !2, retainedTypes: !6, globals: !2)
!2 = !{}
!3 = !DIFile(filename: "empty.c", directory: "/home/nlewycky")
!4 = !DIFile(filename: "empty.c", directory: "/home/nlewycky")
!5 = !{i32 1, !"Debug Info Version", i32 3}
!6 = !{!7}
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
