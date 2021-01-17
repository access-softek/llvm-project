# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 2.00

# FIXME: this test does not work for some reason. There should be 1
# cycle stall for the second instruction.

add	w8, w8, #1
add	w10, w8, #1
add	w12, w8, #1
