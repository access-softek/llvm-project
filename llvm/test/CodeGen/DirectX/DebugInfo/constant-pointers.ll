; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIDerivedType: 2
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1
; CHECK: DITemplateValueParameter: 3


; Ensure that pointer constants are emitted as unsigned data. Alternatively,
; these could be signless data (dataN).

; Built with Clang from:
; template <ptr V, void (*F)(), int i>
; void func() {}
; template void func<nullptr, nullptr, 42>();


; Function Attrs: nounwind
define weak_odr void @_Z4funcILPv0ELPFvvE0ELi42EEvv() #0 !dbg !4 {
entry:
  ret void, !dbg !18
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!15, !16}
!llvm.ident = !{!17}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "constant-pointers.cpp", directory: "/tmp/dbginfo")
!2 = !{}
!4 = distinct !DISubprogram(name: "func<nullptr, nullptr, 42>", linkageName: "_Z4funcILPv0ELPFvvE0ELi42EEvv", line: 2, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 2, file: !1, scope: !5, type: !6, templateParams: !8, retainedNodes: !2)
!5 = !DIFile(filename: "constant-pointers.cpp", directory: "/tmp/dbginfo")
!6 = !DISubroutineType(types: !7)
!7 = !{null}
!8 = !{!9, !11, !13}
!9 = !DITemplateValueParameter(tag: DW_TAG_template_value_parameter, name: "V", type: !10, value: i8 0)
!10 = !DIDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: null)
!11 = !DITemplateValueParameter(tag: DW_TAG_template_value_parameter, name: "F", type: !12, value: i8 0)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !6)
!13 = !DITemplateValueParameter(tag: DW_TAG_template_value_parameter, name: "i", type: !14, value: i32 42)
!14 = !DIBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!15 = !{i32 2, !"Dwarf Version", i32 4}
!16 = !{i32 2, !"Debug Info Version", i32 3}
!17 = !{!"clang version 3.5.0 "}
!18 = !DILocation(line: 3, scope: !4)
