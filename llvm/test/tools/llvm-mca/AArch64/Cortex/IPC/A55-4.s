# RUN: llvm-mca -mtriple=aarch64 -mcpu=cortex-a55 --dispatch-stats --iterations=1000 < %s | FileCheck %s
# CHECK: IPC:
# CHECK-SAME: 0.64

# FIXME: div is not modeled precisely: on hardware IPC changes
# depending on operands and preceding instructions. MCA does not
# handle this.
# XFAIL: *

mov	w10, #4
mov	w12, #8
add	w8, w8, #1
add	w12, w8, #1
sdiv	w10, w12, w10
cmp	w8, w9
b.lt	.LBB0_5
