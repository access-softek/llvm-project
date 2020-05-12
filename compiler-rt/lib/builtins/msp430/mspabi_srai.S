//===-- mspabi_srai.S - __mspabi_srai implementation ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

// r12 := (s16)r12 >> r13
DEFINE_COMPILERRT_FUNCTION(__mspabi_srai)
LOCAL_LABEL(loop):
  dec r13
  jnc LOCAL_LABEL(exit)
  rra r12
  jmp LOCAL_LABEL(loop)
LOCAL_LABEL(exit):
  ret
END_COMPILERRT_FUNCTION(__mspabi_srai)
