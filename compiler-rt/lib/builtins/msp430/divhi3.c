//===-- divhi3.c - Implement __divhi3 -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divhi3 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

// Returns: a / b

COMPILER_RT_ABI hi_int __divhi3(hi_int a, hi_int b) {
  const int bits_in_word_m1 = (int)(sizeof(hi_int) * CHAR_BIT) - 1;
  hi_int s_a = a >> bits_in_word_m1; // s_a = a < 0 ? -1 : 0
  hi_int s_b = b >> bits_in_word_m1; // s_b = b < 0 ? -1 : 0
  a = (a ^ s_a) - s_a;               // negate if s_a == -1
  b = (b ^ s_b) - s_b;               // negate if s_b == -1
  s_a ^= s_b;                        // sign of quotient
  //
  // On CPUs without unsigned hardware division support,
  //  this calls __udivhi3 (notice the cast to hu_int).
  // On CPUs with unsigned hardware division support,
  //  this uses the unsigned division instruction.
  //
  return ((hu_int)a / (hu_int)b ^ s_a) - s_a; // negate if s_a == -1
}
#if defined(__MSP430__)
COMPILER_RT_ALIAS(__divhi3, __mspabi_divi)
#endif
