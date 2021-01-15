# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 1.66

add	w8, w8, #1
add	w12, w8, #1
mul	w10, w10, w10
cmp	w8, w9
b.lt	.LBB0_5
