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
