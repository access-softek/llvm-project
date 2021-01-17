# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 1.33

add	w8, w8, #1
and	w12, w8, #0x3f
ldr	w14, [x10, w12, uxtw #2]
ldr	w15, [x10, w12, uxtw #2]
