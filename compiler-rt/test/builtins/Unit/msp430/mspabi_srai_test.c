// REQUIRES: target-is-msp430
// RUN: %clang_builtins %s %librt -o %t && %run %t
//===-- mspabi_srai_test.c - Test __mspabi_srai ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __mspabi_srai for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef int16_t inttest_t;
typedef uint16_t uinttest_t;

extern inttest_t __mspabi_srai(inttest_t x, int16_t n);

int test__mspabi_srai(uinttest_t x, int16_t n, uinttest_t expected) {
  uinttest_t actual = (uinttest_t) __mspabi_srai((inttest_t) x, n);
  if (actual != expected)
    printf("error in __mspabi_srai(0x%0X, %d) = 0x%0X, expected 0x%0X\n",
           x, n,
           actual, expected);
  return actual != expected;
}

int main()
{
  // condition is checked before the first iteration
  if (test__mspabi_srai(0x1234, 0, 0x1234))
    return 1;
  // just a common case
  if (test__mspabi_srai(0x1234, 1, 0x091A))
    return 1;
  // right shift is arithmetic
  if (test__mspabi_srai(0x8000, 1, 0xC000))
    return 1;
  // 16 is the maximum allowed shift amount (MSP430 EABI part 6.2)
  if (test__mspabi_srai(0x7FFF, 16, 0x0000))
    return 1;
  if (test__mspabi_srai(0xFFFF, 16, 0xFFFF))
    return 1;
}
