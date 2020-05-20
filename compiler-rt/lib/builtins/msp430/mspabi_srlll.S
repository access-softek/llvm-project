//===-- mspabi_srlll.S - __mspabi_srlll implementation ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"
#include "msp430.S.inc"

// (r15:r14:r13:r12) := (u64)(r11:r10:r9:r8) >> [...]:r12
DEFINE_COMPILERRT_FUNCTION(__mspabi_srlll)
MSP430_I64_SHIFT_PROLOGUE
LOCAL_LABEL(loop):
  dec r11
  jnc LOCAL_LABEL(exit)
  clrc
  rrc r15
  rrc r14
  rrc r13
  rrc r12
  jmp LOCAL_LABEL(loop)
LOCAL_LABEL(exit):
  ret
END_COMPILERRT_FUNCTION(__mspabi_srlll)
