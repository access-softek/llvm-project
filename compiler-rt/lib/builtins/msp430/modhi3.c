//===-- modhi3.c - Implement __modhi3 -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __modhi3 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

// Returns: a % b

COMPILER_RT_ABI hi_int __divhi3(hi_int a, hi_int b);

COMPILER_RT_ABI hi_int __modhi3(hi_int a, hi_int b) {
  return a - __divhi3(a, b) * b;
}
#if defined(__MSP430__)
COMPILER_RT_ALIAS(__modhi3, __mspabi_remi)
#endif
