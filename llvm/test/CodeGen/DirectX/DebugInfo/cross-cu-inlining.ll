; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: %dxc /dumpbin %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat

; CHECK: DIBasicType: 1
; CHECK: DICompileUnit: 2
; CHECK: DIExpression: 3
; CHECK: DIFile: 2
; CHECK: DIFlagPrototyped: 2
; CHECK: DILocalVariable: 1
; CHECK: DILocation: 5
; CHECK: DISubprogram: 2
; CHECK: DISubroutineType: 2

; FIXME: Missing DwarfAccelNamesSection on AIX
; XFAIL: target={{.*}}-aix{{.*}}

; Build from source:
; $ clang++ a.cpp b.cpp -g -c -emit-llvm
; $ llvm-link a.bc b.bc -o ab.bc
; $ opt -inline ab.bc -o ab-opt.bc
; $ cat a.cpp
; extern int i;
; int func(int);
; int main() {
;   return func(i);
; }
; $ cat b.cpp
; int __attribute__((always_inline)) func(int x) {
;   return x * 2;
; }

; Ensure that func inlined into main is described and references the abstract
; definition in b.cpp's CU.


; Check the abstract definition is in the 'b.cpp' CU and doesn't contain any
; concrete information (address range or variable location)


; Check the concrete out of line definition references the abstract and
; provides the address range and variable location

; Check that both the inline and the non out of line version of func are
; correctly referenced in the accelerator table. Before r221837, the one
; in the second compilation unit had a wrong offset

@i = external global i32

; Function Attrs:
define i32 @main() #0 !dbg !4 {
entry:
  %x.addr.i = alloca i32, align 4
  %retval = alloca i32, align 4
  store i32 0, ptr %retval
  %0 = load i32, ptr @i, align 4, !dbg !19
  call void @llvm.lifetime.start(i64 4, ptr %x.addr.i)
  store i32 %0, ptr %x.addr.i, align 4
  call void @llvm.dbg.declare(metadata ptr %x.addr.i, metadata !120, metadata !DIExpression()), !dbg !21
  %1 = load i32, ptr %x.addr.i, align 4, !dbg !22
  %mul.i = mul nsw i32 %1, 2, !dbg !22
  call void @llvm.lifetime.end(i64 4, ptr %x.addr.i), !dbg !22
  ret i32 %mul.i, !dbg !19
}

; Function Attrs: alwaysinline nounwind
define i32 @_Z4funci(i32 %x) #1 !dbg !12 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  call void @llvm.dbg.declare(metadata ptr %x.addr, metadata !20, metadata !DIExpression()), !dbg !23
  %0 = load i32, ptr %x.addr, align 4, !dbg !24
  %mul = mul nsw i32 %0, 2, !dbg !24
  ret i32 %mul, !dbg !24
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #2

; Function Attrs: nounwind
declare void @llvm.lifetime.start(i64, ptr nocapture) #3

; Function Attrs: nounwind
declare void @llvm.lifetime.end(i64, ptr nocapture) #3

attributes #0 = { "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }
attributes #1 = { alwaysinline nounwind "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "use-soft-float"="false" }
attributes #2 = { nounwind readnone }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!0, !9}
!llvm.module.flags = !{!16, !17}
!llvm.ident = !{!18, !18}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "a.cpp", directory: "/tmp/dbginfo")
!2 = !{}
!4 = distinct !DISubprogram(name: "main", line: 3, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 3, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "a.cpp", directory: "/tmp/dbginfo")
!6 = !DISubroutineType(types: !7)
!7 = !{!8}
!8 = !DIBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: FullDebug, file: !10, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!10 = !DIFile(filename: "b.cpp", directory: "/tmp/dbginfo")
!12 = distinct !DISubprogram(name: "func", linkageName: "_Z4funci", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !9, scopeLine: 1, file: !10, scope: !13, type: !14, retainedNodes: !2)
!13 = !DIFile(filename: "b.cpp", directory: "/tmp/dbginfo")
!14 = !DISubroutineType(types: !15)
!15 = !{!8, !8}
!16 = !{i32 2, !"Dwarf Version", i32 4}
!17 = !{i32 2, !"Debug Info Version", i32 3}
!18 = !{!"clang version 3.5.0 "}
!19 = !DILocation(line: 4, scope: !4)
!20 = !DILocalVariable(name: "x", line: 1, arg: 1, scope: !12, file: !13, type: !8)

!120 = !DILocalVariable(name: "x", line: 1, arg: 1, scope: !12, file: !13, type: !8)

!21 = !DILocation(line: 1, scope: !12, inlinedAt: !19)
!22 = !DILocation(line: 2, scope: !12, inlinedAt: !19)
!23 = !DILocation(line: 1, scope: !12)
!24 = !DILocation(line: 2, scope: !12)

