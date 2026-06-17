;; Check that slim debug (-dx-Zs) produces the same shader hash as full debug
;; when -dx-Zss is not enabled.

; RUN: llc %S/Inputs/SourceInfo.ll --filetype=obj -o - | obj2yaml -o %t.zi.yaml
; RUN: llc %S/Inputs/SourceInfo.ll --filetype=obj -dx-Zs -o - | obj2yaml -o %t.zs.yaml
; RUN: cat %t.zi.yaml %t.zs.yaml | FileCheck %s

; CHECK: --- !dxcontainer
; CHECK: - Name:            ILDB
; CHECK: - Name:            HASH
; CHECK:   Hash:
; CHECK:     IncludesSource:  false
; CHECK:     Digest:          [ [[HASH:.+]]
; CHECK: ...
; CHECK: --- !dxcontainer
; CHECK: - Name:            HASH
; CHECK:   Hash:
; CHECK:     IncludesSource:  false
; CHECK:     Digest:          [ [[HASH]]

;; With /Zs, /Zss hashes from ILDB (even though ILDB is omitted from output)
;; and produces a different digest with IncludesSource set.

; RUN: llc %S/Inputs/SourceInfo.ll --filetype=obj -dx-Zs -o - | obj2yaml -o %t.zs-noss.yaml
; RUN: llc %S/Inputs/SourceInfo.ll --filetype=obj -dx-Zs -dx-Zss -o - | obj2yaml -o %t.zs-zss.yaml
; RUN: cat %t.zs-noss.yaml %t.zs-zss.yaml | FileCheck %s --check-prefix=CHECK-ZSS

; CHECK-ZSS: --- !dxcontainer
; CHECK-ZSS: - Name:            HASH
; CHECK-ZSS:   Hash:
; CHECK-ZSS:     IncludesSource:  false
; CHECK-ZSS:     Digest:          [ [[ZSHASH:.+]]
; CHECK-ZSS: ...
; CHECK-ZSS: --- !dxcontainer
; CHECK-ZSS: - Name:            HASH
; CHECK-ZSS:   Hash:
; CHECK-ZSS-NOT: [[ZSHASH]]
; CHECK-ZSS:     IncludesSource:  true
; CHECK-ZSS-NOT: [[ZSHASH]]

target triple = "dxil-unknown-shadermodel6.5-library"

define i32 @add(i32 %a, i32 %b) {
  %sum = add i32 %a, %b
  ret i32 %sum
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Some Compiler", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "hlsl.hlsl", directory: "/some-path")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 2}
!4 = !{i32 2, !"Debug Info Version", i32 3}
