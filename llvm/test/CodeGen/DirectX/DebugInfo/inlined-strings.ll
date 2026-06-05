; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 1
; CHECK: DIFile: 1
; CHECK: DIFlagPrototyped: 1
; CHECK: DIGlobalVariable: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1


; Also test that the null streamer doesn't crash with debug info.

; generated from the following source compiled to bitcode with clang -g -O1
; static int i;
; int main() {
;   (void)&i;
; }



source_filename = "test/DebugInfo/Generic/global.ll"

; Function Attrs: nounwind readnone
define i32 @main() #0 !dbg !9 {
entry:
  ret i32 0, !dbg !12
}

attributes #0 = { nounwind readnone "less-precise-fpmad"="false" "frame-pointer"="none" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!7, !8}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang version 3.4 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !2, globals: !3, imports: !2)
!1 = !DIFile(filename: "global.cpp", directory: "/tmp")
!2 = !{}
!3 = !{!4}
!4 = !DIGlobalVariableExpression(var: !5, expr: !DIExpression())
!5 = !DIGlobalVariable(name: "i", linkageName: "_ZL1i", scope: null, file: !1, line: 1, type: !6, isLocal: true, isDefinition: true)
!6 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!7 = !{i32 2, !"Dwarf Version", i32 3}
!8 = !{i32 1, !"Debug Info Version", i32 3}
!9 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 2, type: !10, isLocal: false, isDefinition: true, scopeLine: 2, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, unit: !0, retainedNodes: !2)
!10 = !DISubroutineType(types: !11)
!11 = !{!6}
!12 = !DILocation(line: 4, scope: !9)

