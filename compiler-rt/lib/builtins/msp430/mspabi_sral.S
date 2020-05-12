//===-- mspabi_sral.S - __mspabi_sral implementation ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

// (r13:r12) := (s32)(r13:r12) >> r14
DEFINE_COMPILERRT_FUNCTION(__mspabi_sral)
LOCAL_LABEL(loop):
  dec r14
  jnc LOCAL_LABEL(exit)
  rra r13
  rrc r12
  jmp LOCAL_LABEL(loop)
LOCAL_LABEL(exit):
  ret
END_COMPILERRT_FUNCTION(__mspabi_sral)
