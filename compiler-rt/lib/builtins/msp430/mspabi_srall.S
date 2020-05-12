//===-- mspabi_srall.S - __mspabi_srall implementation ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

// (r15:r14:r13:r12) := (s64)(r11:r10:r9:r8) >> [...]:r12
DEFINE_COMPILERRT_FUNCTION(__mspabi_srall)
LOCAL_LABEL(loop):
  dec r12
  jnc LOCAL_LABEL(exit)
  rra r11
  rrc r10
  rrc r9
  rrc r8
  jmp LOCAL_LABEL(loop)
LOCAL_LABEL(exit):
  mov r8, r12
  mov r9, r13
  mov r10, r14
  mov r11, r15
  ret
END_COMPILERRT_FUNCTION(__mspabi_srall)
