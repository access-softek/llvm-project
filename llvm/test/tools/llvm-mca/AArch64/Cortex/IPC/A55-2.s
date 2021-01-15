# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 2.00

add	w8, w8, #1
add	w10, w10, #1
add	w11, w10, #1
add	w12, w8, #1
cmp	w8, w9
b.lt	.LBB0_5
