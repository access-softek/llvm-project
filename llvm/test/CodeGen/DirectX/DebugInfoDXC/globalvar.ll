;; RUN: llc -O0 -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.O0.dxbc %s
;; RUN: llvm-objcopy --dump-section=ILDB=%t.O0.bc %t.O0.dxbc
;; RUN: %dxc /dumpbin %t.O0.bc | FileCheck %s --check-prefixes=CHECK,CHECK-O0

;; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.default.dxbc %s
;; RUN: llvm-objcopy --dump-section=ILDB=%t.default.bc %t.default.dxbc
;; RUN: %dxc /dumpbin %t.default.bc | FileCheck %s --check-prefixes=CHECK,CHECK-DEFAULT

;; Without -O0 @x is optimized away. DIGLobalVariable stays, but its
;; variable operand is null (not printed).

@x = global i32 0, align 4, !dbg !0

; CHECK-DAG: !llvm.dbg.cu = !{![[CU:[0-9]+]]}
; CHECK-DAG: ![[CU]] = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "handwritten", isOptimized: false, runtimeVersion: 0, emissionKind: 1, globals: ![[GLOBALS:[0-9]+]])
; CHECK-DAG: ![[GLOBALS]] = !{![[GV:[0-9]+]]}
; CHECK-O0-DAG:      ![[GV]] = !DIGlobalVariable(name: "x", scope: ![[CU]], file: ![[FILE:[0-9]+]], line: 1, type: ![[TYPE:[0-9]+]], isLocal: false, isDefinition: true, variable: i32* @x)
; CHECK-DEFAULT-DAG: ![[GV]] = !DIGlobalVariable(name: "x", scope: ![[CU]], file: ![[FILE:[0-9]+]], line: 1, type: ![[TYPE:[0-9]+]], isLocal: false, isDefinition: true)
; CHECK-DAG: ![[FILE]] = !DIFile(filename: "cu.cpp", directory: "/tmp")
; CHECK-DAG: ![[TYPE]] = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!6, !7}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "x", scope: !2, file: !3, line: 1, type: !5, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C, file: !3, producer: "handwritten", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/")
!3 = !DIFile(filename: "cu.cpp", directory: "/tmp")
!4 = !{!0}
!5 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!6 = !{i32 7, !"Dwarf Version", i32 5}
!7 = !{i32 2, !"Debug Info Version", i32 3}
