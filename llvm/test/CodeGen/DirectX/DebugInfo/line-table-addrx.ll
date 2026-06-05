; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; FIXME: Missing DwarfAddrSection on AIX
; XFAIL: target={{.*}}-aix{{.*}}

;; In DWARF v5, emit DW_AT_addr_base as DW_AT_addr_base is used for DW_AT_low_pc.

define i64 @foo() !dbg !7 {
entry:
  ret i64 0
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, emissionKind: LineTablesOnly, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "a.cc", directory: "/tmp")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 5}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!7 = distinct !DISubprogram(name: "a", scope: !1, file: !1, line: 22, type: !8, scopeLine: 22, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !2)
