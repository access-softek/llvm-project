//===-- mspabi_srll.S - __mspabi_srll implementation ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

// (r13:r12) := (u32)(r13:r12) >> r14
DEFINE_COMPILERRT_FUNCTION(__mspabi_srll)
LOCAL_LABEL(loop):
  dec r14
  jnc LOCAL_LABEL(exit)
  clrc
  rrc r13
  rrc r12
  jmp LOCAL_LABEL(loop)
LOCAL_LABEL(exit):
  ret
END_COMPILERRT_FUNCTION(__mspabi_srll)
