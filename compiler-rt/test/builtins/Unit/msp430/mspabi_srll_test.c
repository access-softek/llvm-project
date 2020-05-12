// REQUIRES: target-is-msp430
// RUN: %clang_builtins %s %librt -o %t && %run %t
//===-- mspabi_srll_test.c - Test __mspabi_srll ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __mspabi_srll for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint32_t uinttest_t;

extern uinttest_t __mspabi_srll(uinttest_t x, int16_t n);

int test__mspabi_srll(uinttest_t x, int16_t n, uinttest_t expected) {
  uinttest_t actual = __mspabi_srll(x, n);
  if (actual != expected)
    printf("error in __mspabi_srll(0x%0lX, %d) = 0x%0lX, expected 0x%0lX\n",
           x, n,
           actual, expected);
  return actual != expected;
}

int main()
{
  // condition is checked before the first iteration
  if (test__mspabi_srll(0x12345678L, 0, 0x12345678L))
    return 1;
  // carrying "zero" bit (...3[4 - 0100]5...)
  if (test__mspabi_srll(0x12345678L, 1, 0x091A2b3CL))
    return 1;
  // carrying "one" bit (...3[4 - 0100]5...)
  if (test__mspabi_srll(0x12345678L, 3, 0x02468ACFL))
    return 1;
  // right shift is logical
  if (test__mspabi_srll(0xFFFFFFFFL, 31, 0x00000001L))
    return 1;
  // 32 is the maximum allowed shift amount (MSP430 EABI part 6.2)
  if (test__mspabi_srll(0xFFFFFFFFL, 32, 0x00000000L))
    return 1;
}
