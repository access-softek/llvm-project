# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 1.33

add	w8, w8, #1
cmp	w8, #42
add	w12, w8, #1
mul	w10, w12, w10
