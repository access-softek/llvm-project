; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DICompileUnit: 1
; CHECK: DIDerivedType: 1
; CHECK: DIExpression: 1
; CHECK: DIFile: 1
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 1
; CHECK: DISubprogram: 1
; CHECK: DISubroutineType: 1

; REQUIRES: bug-attr-kind

define void @CGRectStandardize(ptr sret(i32) %agg.result, ptr byval(i32) %rect) nounwind ssp !dbg !0 {
entry:
  call void @llvm.dbg.declare(metadata ptr %rect, metadata !23, metadata !DIExpression()), !dbg !24
  ret void
}

declare void @llvm.dbg.declare(metadata, metadata, metadata) nounwind readnone

declare void @llvm.memcpy.p0.p0.i32(ptr nocapture, ptr nocapture, i32, i1) nounwind


!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!27}
!0 = distinct !DISubprogram(name: "CGRectStandardize", linkageName: "CGRectStandardize", line: 54, isLocal: false, isDefinition: true, virtualIndex: 6, isOptimized: false, unit: !2, file: !1, scope: null, type: !28)
!1 = !DIFile(filename: "GSFusedSilica.m", directory: "/Volumes/Data/Users/sabre/Desktop")
!2 = distinct !DICompileUnit(language: DW_LANG_ObjC, producer: "clang version 2.9 (trunk 115292)", isOptimized: true, runtimeVersion: 1, emissionKind: FullDebug, file: !25, enums: !26, retainedTypes: !26)
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "CGRect", line: 49, file: !25, baseType: null)
!23 = !DILocalVariable(name: "rect", line: 53, arg: 2, scope: !0, file: !1, type: !5)
!24 = !DILocation(line: 53, column: 33, scope: !0)
!25 = !DIFile(filename: "GSFusedSilica.m", directory: "/Volumes/Data/Users/sabre/Desktop")
!26 = !{}
!27 = !{i32 1, !"Debug Info Version", i32 3}
!28 = !DISubroutineType(types: !29)
!29 = !{null}
