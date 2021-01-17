# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 1.50

add	w8, w8, #1
and	w12, w8, #0x3f
ldr	w14, [x10, w12, uxtw #2]
add	w13, w12, #0x1
and	w13, w13, #0x3f
ldr	w14, [x10, w13, uxtw #2]
