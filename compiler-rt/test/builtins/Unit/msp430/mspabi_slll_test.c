// REQUIRES: target-is-msp430
// RUN: %clang_builtins %s %librt -o %t && %run %t
//===-- mspabi_slll_test.c - Test __mspabi_slll ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __mspabi_slll for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint32_t uinttest_t;

extern uinttest_t __mspabi_slll(uinttest_t x, int16_t n);

int test__mspabi_slll(uinttest_t x, int16_t n, uinttest_t expected) {
  uinttest_t actual = __mspabi_slll(x, n);
  if (actual != expected)
    printf("error in __mspabi_slll(0x%0lX, %d) = 0x%0lX, expected 0x%0lX\n",
           x, n,
           actual, expected);
  return actual != expected;
}

int main()
{
  // condition is checked before the first iteration
  if (test__mspabi_slll(0x12345678L, 0, 0x12345678L))
    return 1;
  // carrying "zero" bit (...34[5 - 0101]6...)
  if (test__mspabi_slll(0x12345678L, 1, 0x2468ACF0L))
    return 1;
  // carrying "one" bit (...34[5 - 0101]6...)
  if (test__mspabi_slll(0x12345678L, 2, 0x48D159E0L))
    return 1;
  // 32 is the maximum allowed shift amount (MSP430 EABI part 6.2)
  if (test__mspabi_slll(0xFFFFFFFFL, 31, 0x80000000L))
    return 1;
  if (test__mspabi_slll(0xFFFFFFFFL, 32, 0x00000000L))
    return 1;
}
