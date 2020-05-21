// REQUIRES: target-is-msp430
// RUN: %clang_builtins %s %librt -o %t && %run %t
//===-- mspabi_sllll_test.c - Test __mspabi_sllll -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __mspabi_sllll for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint64_t uinttest_t;

extern uinttest_t __attribute__((msp430_builtin)) __mspabi_sllll(uinttest_t x, int64_t n);

int test__mspabi_sllll(uinttest_t x, int16_t n, uinttest_t expected) {
  uinttest_t actual = __mspabi_sllll(x, n);
  if (actual != expected)
    printf("error in __mspabi_sllll(0x%08lX%08lX, %d) = 0x%08lX%08lX, expected 0x%08lX%08lX\n",
           (uint32_t) (x >> 32), (uint32_t) x, n,
           (uint32_t) (actual >> 32), (uint32_t) actual,
           (uint32_t) (expected >> 32), (uint32_t) expected);
  return actual != expected;
}

int main()
{
  // condition is checked before the first iteration
  if (test__mspabi_sllll(0x123456789ABCDEF0LL, 0, 0x123456789ABCDEF0LL))
    return 1;
  // carrying all "zero" bits (...34[1 - 0001]2...)
  if (test__mspabi_sllll(0x1234123412341234LL, 1, 0x2468246824682468LL))
    return 1;
  // carrying all "one" bits (...34[1 - 0001]2...)
  if (test__mspabi_sllll(0x1234123412341234LL, 4, 0x2341234123412340LL))
    return 1;
  // check for 64bit-ness
  if (test__mspabi_sllll(0x123456789ABCDEF0LL, 3, 0x91A2B3C4D5E6F780LL))
    return 1;
  // 64 is the maximum allowed shift amount (MSP430 EABI part 6.2)
  if (test__mspabi_sllll(0xFFFFFFFFFFFFFFFFLL, 63, 0x8000000000000000LL))
    return 1;
  if (test__mspabi_sllll(0xFFFFFFFFFFFFFFFFLL, 64, 0x0000000000000000LL))
    return 1;
}
