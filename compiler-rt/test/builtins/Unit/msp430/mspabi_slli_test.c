// REQUIRES: target-is-msp430
// RUN: %clang_builtins %s %librt -o %t && %run %t
//===-- mspabi_slli_test.c - Test __mspabi_slli ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __mspabi_slli for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint16_t uinttest_t;

extern uinttest_t __mspabi_slli(uinttest_t x, int16_t n);

int test__mspabi_slli(uinttest_t x, int16_t n, uinttest_t expected) {
  uinttest_t actual = __mspabi_slli(x, n);
  if (actual != expected)
    printf("error in __mspabi_slli(0x%0X, %d) = 0x%0X, expected 0x%0X\n",
           x, n,
           actual, expected);
  return actual != expected;
}

int main()
{
  // condition is checked before the first iteration
  if (test__mspabi_slli(0x1234, 0, 0x1234))
    return 1;
  // just a common case
  if (test__mspabi_slli(0x1234, 1, 0x2468))
    return 1;
  // 16 is the maximum allowed shift amount (MSP430 EABI part 6.2)
  if (test__mspabi_slli(0xFFFF, 15, 0x8000))
    return 1;
  if (test__mspabi_slli(0xFFFF, 16, 0x0000))
    return 1;
}
