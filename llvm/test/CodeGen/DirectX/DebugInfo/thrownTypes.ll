; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; DXDI note: DICompositeType here is only used for thrownTypes metadata, which is not supported.

; Function Attrs: nounwind
define void @f() #0 !dbg !5 {
entry:
  ret void, !dbg !11
}

attributes #0 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}

!0 = distinct !DICompileUnit(language: DW_LANG_Swift, producer: "swiftc", isOptimized: false, emissionKind: FullDebug, file: !1)
!1 = !DIFile(filename: "f.swift", directory: "/")
!3 = !DICompositeType(tag: DW_TAG_structure_type, name: "Error")
!4 = !DICompositeType(tag: DW_TAG_structure_type, name: "DifferentError")
!5 = distinct !DISubprogram(name: "f", line: 2, isLocal: false, isDefinition: true, unit: !0, scopeLine: 2, file: !1, scope: !1, type: !6, thrownTypes: !{!3, !4})
!6 = !DISubroutineType(types: !7)
!7 = !{null}
!8 = !{i32 2, !"Dwarf Version", i32 4}
!9 = !{i32 1, !"Debug Info Version", i32 3}
!11 = !DILocation(line: 3, scope: !5)
