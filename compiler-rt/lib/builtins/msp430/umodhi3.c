//===-- umodhi3.c - Implement __umodhi3 -----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __umodhi3 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

typedef hu_int fixuint_t;
typedef hi_int fixint_t;
#include "../int_div_impl.inc"

// Returns: a % b

COMPILER_RT_ABI hu_int __umodhi3(hu_int a, hu_int b) {
  return __umodXi3(a, b);
}
#if defined(__MSP430__)
COMPILER_RT_ALIAS(__umodhi3, __mspabi_remu)
#endif
