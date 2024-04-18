# REQUIRES: aarch64

# RUN: rm -rf %t && split-file %s %t && cd %t

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux %p/Inputs/shared.s -o a.o
# RUN: ld.lld -shared a.o -o a.so

#--- ok.s

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux ok.s -o ok.o

# RUN: ld.lld ok.o a.so -o external
# RUN: llvm-readelf -r -S -x .got external | FileCheck %s --check-prefix=EXTERNAL

# RUN: ld.lld ok.o a.o -o local
# RUN: llvm-readelf -r -S -x .got -s local | FileCheck %s --check-prefix=LOCAL

# EXTERNAL:      Offset            Info             Type                    Symbol's Value   Symbol's Name + Addend
# EXTERNAL-NEXT: 0000000000220370  000000010000e201 R_AARCH64_AUTH_GLOB_DAT 0000000000000000 bar + 0
# EXTERNAL-NEXT: 0000000000220378  000000020000e201 R_AARCH64_AUTH_GLOB_DAT 0000000000000000 zed + 0

## Symbol's values for bar and zed are equal since they contain no content (see Inputs/shared.s)
# LOCAL:         Offset            Info             Type                    Symbol's Value   Symbol's Name + Addend
# LOCAL-NEXT:    00000000002201e0  0000000000000411 R_AARCH64_AUTH_RELATIVE 2101e0
# LOCAL-NEXT:    00000000002201e8  0000000000000411 R_AARCH64_AUTH_RELATIVE 2101e0

# EXTERNAL:      Hex dump of section '.got':
# EXTERNAL-NEXT: 0x00220370 00000000 00000080 00000000 000000a0
#                                          ^^
#                                          0b10000000 bit 63 address diversity = true, bits 61..60 key = IA
#                                                            ^^
#                                                            0b10100000 bit 63 address diversity = true, bits 61..60 key = DA

# LOCAL: Symbol table '.symtab' contains {{.*}} entries:
# LOCAL:    Num:    Value          Size Type    Bind   Vis       Ndx Name
# LOCAL:         00000000002101e0     0 FUNC    GLOBAL DEFAULT     2 bar
# LOCAL:         00000000002101e0     0 NOTYPE  GLOBAL DEFAULT     2 zed

# LOCAL:         Hex dump of section '.got':
# LOCAL-NEXT:    0x002201e0 00000000 00000080 00000000 000000a0
#                                          ^^
#                                          0b10000000 bit 63 address diversity = true, bits 61..60 key = IA
#                                                            ^^
#                                                            0b10100000 bit 63 address diversity = true, bits 61..60 key = DA

# RUN: llvm-objdump -d external | FileCheck %s --check-prefix=EXTERNAL-ASM

# EXTERNAL-ASM:      <_start>:
# EXTERNAL-ASM-NEXT: adrp x0, 0x220000
# EXTERNAL-ASM-NEXT: ldr  x0, [x0, #0x370]
# EXTERNAL-ASM-NEXT: adrp x1, 0x220000
# EXTERNAL-ASM-NEXT: add  x1, x1, #0x370
# EXTERNAL-ASM-NEXT: adrp x0, 0x220000
# EXTERNAL-ASM-NEXT: ldr  x0, [x0, #0x378]
# EXTERNAL-ASM-NEXT: adrp x1, 0x220000
# EXTERNAL-ASM-NEXT: add  x1, x1, #0x378

# RUN: llvm-objdump -d local | FileCheck %s --check-prefix=LOCAL-ASM

# LOCAL-ASM:         <_start>:
# LOCAL-ASM-NEXT:    adrp x0, 0x220000
# LOCAL-ASM-NEXT:    ldr  x0, [x0, #0x1e0]
# LOCAL-ASM-NEXT:    adrp x1, 0x220000
# LOCAL-ASM-NEXT:    add  x1, x1, #0x1e0
# LOCAL-ASM-NEXT:    adrp x0, 0x220000
# LOCAL-ASM-NEXT:    ldr  x0, [x0, #0x1e8]
# LOCAL-ASM-NEXT:    adrp x1, 0x220000
# LOCAL-ASM-NEXT:    add  x1, x1, #0x1e8

.globl _start
_start:
  adrp x0, :got_auth:bar
  ldr  x0, [x0, :got_auth_lo12:bar]
  adrp x1, :got_auth:bar
  add  x1, x1, :got_auth_lo12:bar
  adrp x0, :got_auth:zed
  ldr  x0, [x0, :got_auth_lo12:zed]
  adrp x1, :got_auth:zed
  add  x1, x1, :got_auth_lo12:zed

#--- ok-tiny.s

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux ok-tiny.s -o ok-tiny.o

# RUN: ld.lld ok-tiny.o a.so --image-base=0x10000 -o external-tiny
# RUN: llvm-readelf -r -S -x .got external-tiny | FileCheck %s --check-prefix=EXTERNAL-TINY

# RUN: ld.lld ok-tiny.o a.o --image-base=0x10000 -o local-tiny
# RUN: llvm-readelf -r -S -x .got -s local-tiny | FileCheck %s --check-prefix=LOCAL-TINY

# EXTERNAL-TINY:      Offset            Info             Type                    Symbol's Value   Symbol's Name + Addend
# EXTERNAL-TINY-NEXT: 0000000000030370  000000010000e201 R_AARCH64_AUTH_GLOB_DAT 0000000000000000 bar + 0
# EXTERNAL-TINY-NEXT: 0000000000030378  000000020000e201 R_AARCH64_AUTH_GLOB_DAT 0000000000000000 zed + 0

## Symbol's values for bar and zed are equal since they contain no content (see Inputs/shared.s)
# LOCAL-TINY:         Offset            Info             Type                    Symbol's Value   Symbol's Name + Addend
# LOCAL-TINY-NEXT:    00000000000301e0  0000000000000411 R_AARCH64_AUTH_RELATIVE 201e0
# LOCAL-TINY-NEXT:    00000000000301e8  0000000000000411 R_AARCH64_AUTH_RELATIVE 201e0

# EXTERNAL-TINY:      Hex dump of section '.got':
# EXTERNAL-TINY-NEXT: 0x00030370 00000000 00000080 00000000 000000a0
#                                               ^^
#                                               0b10000000 bit 63 address diversity = true, bits 61..60 key = IA
#                                                                 ^^
#                                                                 0b10100000 bit 63 address diversity = true, bits 61..60 key = DA

# LOCAL-TINY: Symbol table '.symtab' contains {{.*}} entries:
# LOCAL-TINY:    Num:    Value          Size Type    Bind   Vis       Ndx Name
# LOCAL-TINY:         00000000000201e0     0 FUNC    GLOBAL DEFAULT     2 bar
# LOCAL-TINY:         00000000000201e0     0 NOTYPE  GLOBAL DEFAULT     2 zed

# LOCAL-TINY:         Hex dump of section '.got':
# LOCAL-TINY-NEXT:    0x000301e0 00000000 00000080 00000000 000000a0
#                                               ^^
#                                               0b10000000 bit 63 address diversity = true, bits 61..60 key = IA
#                                                                 ^^
#                                                                 0b10100000 bit 63 address diversity = true, bits 61..60 key = DA

# RUN: llvm-objdump -d external-tiny | FileCheck %s --check-prefix=EXTERNAL-TINY-ASM

# EXTERNAL-TINY-ASM:      <_start>:
# EXTERNAL-TINY-ASM-NEXT: adr x0, 0x30370
# EXTERNAL-TINY-ASM-NEXT: ldr x1, [x0]
# EXTERNAL-TINY-ASM-NEXT: adr x0, 0x30370
# EXTERNAL-TINY-ASM-NEXT: ldr x1, 0x30370
# EXTERNAL-TINY-ASM-NEXT: adr x0, 0x30378
# EXTERNAL-TINY-ASM-NEXT: ldr x1, [x0]
# EXTERNAL-TINY-ASM-NEXT: adr x0, 0x30378
# EXTERNAL-TINY-ASM-NEXT: ldr x1, 0x30378

# RUN: llvm-objdump -d local-tiny | FileCheck %s --check-prefix=LOCAL-TINY-ASM

# LOCAL-TINY-ASM:         <_start>:
# LOCAL-TINY-ASM-NEXT:    adr x0, 0x301e0
# LOCAL-TINY-ASM-NEXT:    ldr x1, [x0]
# LOCAL-TINY-ASM-NEXT:    adr x0, 0x301e0
# LOCAL-TINY-ASM-NEXT:    ldr x1, 0x301e0
# LOCAL-TINY-ASM-NEXT:    adr x0, 0x301e8
# LOCAL-TINY-ASM-NEXT:    ldr x1, [x0]
# LOCAL-TINY-ASM-NEXT:    adr x0, 0x301e8
# LOCAL-TINY-ASM-NEXT:    ldr x1, 0x301e8

.globl _start
_start:
  adr  x0, :got_auth:bar
  ldr  x1, [x0]
  adr  x0, :got_auth:bar
  ldr  x1, :got_auth:bar
  adr  x0, :got_auth:zed
  ldr  x1, [x0]
  adr  x0, :got_auth:zed
  ldr  x1, :got_auth:zed

#--- err.s

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux err.s -o err.o

# RUN: not ld.lld err.o a.so -o /dev/null 2>&1 | FileCheck %s --check-prefix=ERR

# ERR: error: both AUTH and non-AUTH GOT entries for 'bar' requested, but only one type of GOT entry per symbol is supported

.globl _start
_start:
  adrp x0, :got_auth:bar
  ldr  x0, [x0, :got_auth_lo12:bar]
  adrp x0, :got:bar
  ldr  x0, [x0, :got_lo12:bar]
