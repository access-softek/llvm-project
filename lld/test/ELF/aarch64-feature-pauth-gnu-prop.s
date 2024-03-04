# REQUIRES: aarch64

# RUN: rm -rf %t && split-file %s %t && cd %t

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag1.s -o tag11.o
# RUN: cp tag11.o tag12.o
# RUN: ld.lld -shared tag11.o tag12.o -o tagok.so
# RUN: llvm-readelf -n tagok.so | FileCheck --check-prefix OK %s

# OK: Properties: AArch64 PAuth ABI tag: platform 0x2a, version 0x1

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag2.s -o tag2.o
# RUN: not ld.lld tag11.o tag12.o tag2.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR1 %s

# ERR1: error: incompatible values of AArch64 PAuth compatibility info found
# ERR1: {{.*}}: 0x2A000000000000000{{1|2}}00000000000000
# ERR1: {{.*}}: 0x2A000000000000000{{1|2}}00000000000000

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag-short.s -o short.o
# RUN: not ld.lld short.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR2 %s

# ERR2: error: short.o:(.note.gnu.property+0x0): size of GNU_PROPERTY_AARCH64_FEATURE_PAUTH property must be 16

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu abi-tag-multiple.s -o multiple.o
# RUN: not ld.lld multiple.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR3 %s
# ERR3: error: multiple.o:(.note.gnu.property+0x0): multiple GNU_PROPERTY_AARCH64_FEATURE_PAUTH properties are not allowed

# RUN: llvm-mc -filetype=obj -triple=aarch64-linux-gnu no-info.s -o noinfo1.o
# RUN: cp noinfo1.o noinfo2.o
# RUN: not ld.lld -z pauth-report=error tag11.o noinfo1.o noinfo2.o -o /dev/null 2>&1 | FileCheck --check-prefix ERR4 %s
# RUN: ld.lld -z pauth-report=warning tag11.o noinfo1.o noinfo2.o -o /dev/null 2>&1 | FileCheck --check-prefix WARN %s
# RUN: ld.lld -z pauth-report=none tag11.o noinfo1.o noinfo2.o -o /dev/null 2>&1 | FileCheck --check-prefix NONE %s

# ERR4:      error: {{.*}}noinfo1.o has no AArch64 PAuth compatibility info while {{.*}}tag11.o has one; either all or no input files must have it
# ERR4-NEXT: error: {{.*}}noinfo2.o has no AArch64 PAuth compatibility info while {{.*}}tag11.o has one; either all or no input files must have it
# WARN:      warning: {{.*}}noinfo1.o has no AArch64 PAuth compatibility info while {{.*}}tag11.o has one; either all or no input files must have it
# WARN-NEXT: warning: {{.*}}noinfo2.o has no AArch64 PAuth compatibility info while {{.*}}tag11.o has one; either all or no input files must have it
# NONE-NOT:  {{.*}} has no AArch64 PAuth compatibility info while {{.*}} has one; either all or no input files must have it

#--- abi-tag-short.s

# Version is 4 bytes instead of 8 bytes, must emit an error

.section ".note.gnu.property", "a"
.long 4
.long 20
.long 5
.asciz "GNU"
.long 0xc0000001
.long 12
.quad 2
.long 31

#--- abi-tag-multiple.s

.section ".note.gnu.property", "a"
.long 4
.long 48
.long 5
.asciz "GNU"
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 1  // version
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 1  // version

#--- abi-tag1.s

.section ".note.gnu.property", "a"
.long 4
.long 24
.long 5
.asciz "GNU"
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 1  // version

#--- abi-tag2.s

.section ".note.gnu.property", "a"
.long 4
.long 24
.long 5
.asciz "GNU"
.long 0xc0000001
.long 16
.quad 42 // platform
.quad 2  // version

#--- no-info.s

.section ".test", "a"
