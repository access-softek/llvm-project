# RUN: rm -rf %t && split-file %s %t && cd %t

#--- tag-42-1.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 42         // platform
.quad 1          // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-42-1.s -o tag-42-1.o
# RUN: llvm-readelf --notes tag-42-1.o | \
# RUN:   FileCheck --check-prefix ELF-TAG -DPLATFORM="0x2a (unknown)" -DVERSION=0x1 %s
# RUN: llvm-readobj --notes tag-42-1.o | \
# RUN:   FileCheck --check-prefix OBJ-TAG -DPLATFORM=42 -DPLATFORMDESC=unknown -DVERSION=1 %s

# ELF-TAG: AArch64 PAuth ABI tag: platform [[PLATFORM]], version [[VERSION]]

# OBJ-TAG:      Notes [
# OBJ-TAG-NEXT:   NoteSection {
# OBJ-TAG-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-NEXT:     Offset: 0x40
# OBJ-TAG-NEXT:     Size: 0x20
# OBJ-TAG-NEXT:     Note {
# OBJ-TAG-NEXT:       Owner: ARM
# OBJ-TAG-NEXT:       Data size: 0x10
# OBJ-TAG-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-NEXT:       Platform: [[PLATFORM]]
# OBJ-TAG-NEXT:       PlatformDesc: [[PLATFORMDESC]]
# OBJ-TAG-NEXT:       Version: [[VERSION]]
# OBJ-TAG-NEXT:     }
# OBJ-TAG-NEXT:   }
# OBJ-TAG-NEXT: ]

#--- tag-0-0.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 0          // platform
.quad 0          // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-0-0.s -o tag-0-0.o
# RUN: llvm-readelf --notes tag-0-0.o | \
# RUN:   FileCheck --check-prefix ELF-TAG -DPLATFORM="0x0 (invalid)" -DVERSION=0x0 %s
# RUN: llvm-readobj --notes tag-0-0.o | \
# RUN:   FileCheck --check-prefix OBJ-TAG -DPLATFORM=0 -DPLATFORMDESC=invalid -DVERSION=0 %s

#--- tag-1-0.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 1          // platform
.quad 0          // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-1-0.s -o tag-1-0.o
# RUN: llvm-readelf --notes tag-1-0.o | \
# RUN:   FileCheck --check-prefix ELF-TAG -DPLATFORM="0x1 (baremetal)" -DVERSION=0x0 %s
# RUN: llvm-readobj --notes tag-1-0.o | \
# RUN:   FileCheck --check-prefix OBJ-TAG -DPLATFORM=1 -DPLATFORMDESC=baremetal -DVERSION=0 %s

#--- tag-0x10000002-85.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 16
.long 1
.asciz "ARM"

.quad 0x10000002 // platform
.quad 85         // version

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-0x10000002-85.s -o tag-0x10000002-85.o
# RUN: llvm-readelf --notes tag-0x10000002-85.o | \
# RUN:   FileCheck --check-prefix ELF-TAG -DPLATFORM="0x10000002 (llvm_linux)" \
# RUN:   -DVERSION="0x55 (PointerAuthIntrinsics, !PointerAuthCalls, PointerAuthReturns, !PointerAuthAuthTraps, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini)" %s
# RUN: llvm-readobj --notes tag-0x10000002-85.o | \
# RUN:   FileCheck --check-prefix OBJ-TAG-LINUX -DPLATFORM=268435458 -DPLATFORMDESC=llvm_linux -DVERSION=85 \
# RUN:   -DVERSIONDESC="PointerAuthIntrinsics, !PointerAuthCalls, PointerAuthReturns, !PointerAuthAuthTraps, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini" %s

# OBJ-TAG-LINUX:      Notes [
# OBJ-TAG-LINUX-NEXT:   NoteSection {
# OBJ-TAG-LINUX-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-LINUX-NEXT:     Offset: 0x40
# OBJ-TAG-LINUX-NEXT:     Size: 0x20
# OBJ-TAG-LINUX-NEXT:     Note {
# OBJ-TAG-LINUX-NEXT:       Owner: ARM
# OBJ-TAG-LINUX-NEXT:       Data size: 0x10
# OBJ-TAG-LINUX-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-LINUX-NEXT:       Platform: [[PLATFORM]]
# OBJ-TAG-LINUX-NEXT:       PlatformDesc: [[PLATFORMDESC]]
# OBJ-TAG-LINUX-NEXT:       Version: [[VERSION]]
# OBJ-TAG-LINUX-NEXT:       VersionDesc: [[VERSIONDESC]]
# OBJ-TAG-LINUX-NEXT:     }
# OBJ-TAG-LINUX-NEXT:   }
# OBJ-TAG-LINUX-NEXT: ]

#--- tag-short.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 12
.long 1
.asciz "ARM"

.quad 42
.word 1

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-short.s -o tag-short.o
# RUN: llvm-readelf --notes tag-short.o | FileCheck --check-prefix ELF-TAG-SHORT %s
# RUN: llvm-readobj --notes tag-short.o | FileCheck --check-prefix OBJ-TAG-SHORT %s

# ELF-TAG-SHORT:  AArch64 PAuth ABI tag: <corrupted size: expected 16, got 12>

# OBJ-TAG-SHORT:      Notes [
# OBJ-TAG-SHORT-NEXT:   NoteSection {
# OBJ-TAG-SHORT-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-SHORT-NEXT:     Offset: 0x40
# OBJ-TAG-SHORT-NEXT:     Size: 0x1C
# OBJ-TAG-SHORT-NEXT:     Note {
# OBJ-TAG-SHORT-NEXT:       Owner: ARM
# OBJ-TAG-SHORT-NEXT:       Data size: 0xC
# OBJ-TAG-SHORT-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-SHORT-NEXT:       Description data (
# OBJ-TAG-SHORT-NEXT:         0000: 2A000000 00000000 01000000
# OBJ-TAG-SHORT-NEXT:       )
# OBJ-TAG-SHORT-NEXT:     }
# OBJ-TAG-SHORT-NEXT:   }
# OBJ-TAG-SHORT-NEXT: ]

#--- tag-long.s

.section ".note.AARCH64-PAUTH-ABI-tag", "a"
.long 4
.long 24
.long 1
.asciz "ARM"

.quad 42         // platform
.quad 1          // version
.quad 0x0123456789ABCDEF // extra data

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu tag-long.s -o tag-long.o
# RUN: llvm-readelf --notes tag-long.o | FileCheck --check-prefix ELF-TAG-LONG %s
# RUN: llvm-readobj --notes tag-long.o | FileCheck --check-prefix OBJ-TAG-LONG %s

# ELF-TAG-LONG:   AArch64 PAuth ABI tag: <corrupted size: expected 16, got 24>

# OBJ-TAG-LONG:      Notes [
# OBJ-TAG-LONG-NEXT:   NoteSection {
# OBJ-TAG-LONG-NEXT:     Name: .note.AARCH64-PAUTH-ABI-tag
# OBJ-TAG-LONG-NEXT:     Offset: 0x40
# OBJ-TAG-LONG-NEXT:     Size: 0x28
# OBJ-TAG-LONG-NEXT:     Note {
# OBJ-TAG-LONG-NEXT:       Owner: ARM
# OBJ-TAG-LONG-NEXT:       Data size: 0x18
# OBJ-TAG-LONG-NEXT:       Type: NT_ARM_TYPE_PAUTH_ABI_TAG
# OBJ-TAG-LONG-NEXT:       Description data (
# OBJ-TAG-LONG-NEXT:         0000: 2A000000 00000000 01000000 00000000
# OBJ-TAG-LONG-NEXT:         0010: EFCDAB89 67452301
# OBJ-TAG-LONG-NEXT:       )
# OBJ-TAG-LONG-NEXT:     }
# OBJ-TAG-LONG-NEXT:   }
# OBJ-TAG-LONG-NEXT: ]

#--- gnu-42-1.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 42          /* PAuth ABI platform */
  .quad 1           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-42-1.s -o gnu-42-1.o
# RUN: llvm-readelf --notes gnu-42-1.o | \
# RUN:   FileCheck --check-prefix=ELF-GNU -DPLATFORM="0x2a (unknown)" -DVERSION=0x1 %s
# RUN: llvm-readobj --notes gnu-42-1.o | \
# RUN:   FileCheck --check-prefix=OBJ-GNU -DPLATFORM="0x2a (unknown)" -DVERSION=0x1 %s

# ELF-GNU: Displaying notes found in: .note.gnu.property
# ELF-GNU-NEXT:   Owner                 Data size	Description
# ELF-GNU-NEXT:   GNU                   0x00000018	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-NEXT:   AArch64 PAuth ABI tag: platform [[PLATFORM]], version [[VERSION]]

# OBJ-GNU:      Notes [
# OBJ-GNU-NEXT:   NoteSection {
# OBJ-GNU-NEXT:     Name: .note.gnu.property
# OBJ-GNU-NEXT:     Offset: 0x40
# OBJ-GNU-NEXT:     Size: 0x28
# OBJ-GNU-NEXT:     Note {
# OBJ-GNU-NEXT:       Owner: GNU
# OBJ-GNU-NEXT:       Data size: 0x18
# OBJ-GNU-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-NEXT:       Property [
# OBJ-GNU-NEXT:         AArch64 PAuth ABI tag: platform [[PLATFORM]], version [[VERSION]]
# OBJ-GNU-NEXT:       ]
# OBJ-GNU-NEXT:     }
# OBJ-GNU-NEXT:   }
# OBJ-GNU-NEXT: ]

#--- gnu-0-0.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 0           /* PAuth ABI platform */
  .quad 0           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-0-0.s -o gnu-0-0.o
# RUN: llvm-readelf --notes gnu-0-0.o | \
# RUN:   FileCheck --check-prefix=ELF-GNU -DPLATFORM="0x0 (invalid)" -DVERSION=0x0 %s
# RUN: llvm-readobj --notes gnu-0-0.o | \
# RUN:   FileCheck --check-prefix=OBJ-GNU -DPLATFORM="0x0 (invalid)" -DVERSION=0x0 %s

#--- gnu-1-0.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 1           /* PAuth ABI platform */
  .quad 0           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-1-0.s -o gnu-1-0.o
# RUN: llvm-readelf --notes gnu-1-0.o | \
# RUN:   FileCheck --check-prefix=ELF-GNU -DPLATFORM="0x1 (baremetal)" -DVERSION=0x0 %s
# RUN: llvm-readobj --notes gnu-1-0.o | \
# RUN:   FileCheck --check-prefix=OBJ-GNU -DPLATFORM="0x1 (baremetal)" -DVERSION=0x0 %s

#--- gnu-0x10000002-85.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 16          /* Data size */
  .quad 0x10000002  /* PAuth ABI platform */
  .quad 85          /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-0x10000002-85.s -o gnu-0x10000002-85.o
# RUN: llvm-readelf --notes gnu-0x10000002-85.o | \
# RUN:   FileCheck --check-prefix=ELF-GNU -DPLATFORM="0x10000002 (llvm_linux)" \
# RUN:   -DVERSION="0x55 (PointerAuthIntrinsics, !PointerAuthCalls, PointerAuthReturns, !PointerAuthAuthTraps, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini)" %s
# RUN: llvm-readobj --notes gnu-0x10000002-85.o | \
# RUN:   FileCheck --check-prefix=OBJ-GNU -DPLATFORM="0x10000002 (llvm_linux)" \
# RUN:   -DVERSION="0x55 (PointerAuthIntrinsics, !PointerAuthCalls, PointerAuthReturns, !PointerAuthAuthTraps, PointerAuthVTPtrAddressDiscrimination, !PointerAuthVTPtrTypeDiscrimination, PointerAuthInitFini)" %s

#--- gnu-short.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 12          /* Data size */
  .quad 42          /* PAuth ABI platform */
  .word 1           /* PAuth ABI version */
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-short.s -o gnu-short.o
# RUN: llvm-readelf --notes gnu-short.o | \
# RUN:   FileCheck --check-prefix=ELF-GNU-ERR -DSIZE=28 -DDATASIZE=18 \
# RUN:   -DERR="<corrupted size: expected 16, got 12>" %s
# RUN: llvm-readobj --notes gnu-short.o | \
# RUN:   FileCheck --check-prefix=OBJ-GNU-ERR -DSIZE=28 -DDATASIZE=18 \
# RUN:   -DERR="<corrupted size: expected 16, got 12>" %s

# ELF-GNU-ERR: Displaying notes found in: .note.gnu.property
# ELF-GNU-ERR-NEXT:   Owner                 Data size	Description
# ELF-GNU-ERR-NEXT:   GNU                   0x000000[[DATASIZE]]	NT_GNU_PROPERTY_TYPE_0 (property note)
# ELF-GNU-ERR-NEXT:   AArch64 PAuth ABI tag: [[ERR]]

# OBJ-GNU-ERR:      Notes [
# OBJ-GNU-ERR-NEXT:   NoteSection {
# OBJ-GNU-ERR-NEXT:     Name: .note.gnu.property
# OBJ-GNU-ERR-NEXT:     Offset: 0x40
# OBJ-GNU-ERR-NEXT:     Size: 0x[[SIZE]]
# OBJ-GNU-ERR-NEXT:     Note {
# OBJ-GNU-ERR-NEXT:       Owner: GNU
# OBJ-GNU-ERR-NEXT:       Data size: 0x[[DATASIZE]]
# OBJ-GNU-ERR-NEXT:       Type: NT_GNU_PROPERTY_TYPE_0 (property note)
# OBJ-GNU-ERR-NEXT:       Property [
# OBJ-GNU-ERR-NEXT:         AArch64 PAuth ABI tag: [[ERR]]
# OBJ-GNU-ERR-NEXT:       ]
# OBJ-GNU-ERR-NEXT:     }
# OBJ-GNU-ERR-NEXT:   }
# OBJ-GNU-ERR-NEXT: ]

#--- gnu-long.s

.section ".note.gnu.property", "a"
  .long 4           /* Name length is always 4 ("GNU") */
  .long end - begin /* Data length */
  .long 5           /* Type: NT_GNU_PROPERTY_TYPE_0 */
  .asciz "GNU"      /* Name */
  .p2align 3
begin:
  /* PAuth ABI property note */
  .long 0xc0000001  /* Type: GNU_PROPERTY_AARCH64_FEATURE_PAUTH */
  .long 24          /* Data size */
  .quad 42          /* PAuth ABI platform */
  .quad 1           /* PAuth ABI version */
  .quad 0x0123456789ABCDEF
  .p2align 3        /* Align to 8 byte for 64 bit */
end:

# RUN: llvm-mc -filetype=obj -triple aarch64-linux-gnu gnu-long.s -o gnu-long.o
# RUN: llvm-readelf --notes gnu-long.o | \
# RUN:   FileCheck --check-prefix=ELF-GNU-ERR -DSIZE=30 -DDATASIZE=20 \
# RUN:   -DERR="<corrupted size: expected 16, got 24>" %s
# RUN: llvm-readobj --notes gnu-long.o | \
# RUN:   FileCheck --check-prefix=OBJ-GNU-ERR -DSIZE=30 -DDATASIZE=20 \
# RUN:   -DERR="<corrupted size: expected 16, got 24>" %s
