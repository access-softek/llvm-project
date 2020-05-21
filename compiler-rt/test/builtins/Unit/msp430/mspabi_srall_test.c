// REQUIRES: target-is-msp430
// RUN: %clang_builtins %s %librt -o %t && %run %t
//===-- mspabi_srall_test.c - Test __mspabi_srall -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __mspabi_srall for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef int64_t inttest_t;
typedef uint64_t uinttest_t;

extern inttest_t __attribute__((msp430_builtin)) __mspabi_srall(inttest_t x, int64_t n);

int test__mspabi_srall(uinttest_t x, int16_t n, uinttest_t expected) {
  uinttest_t actual = (uinttest_t) __mspabi_srall((inttest_t) x, n);
  if (actual != expected)
    printf("error in __mspabi_srall(0x%08lX%08lX, %d) = 0x%08lX%08lX, expected 0x%08lX%08lX\n",
           (uint32_t) (x >> 32), (uint32_t) x, n,
           (uint32_t) (actual >> 32), (uint32_t) actual,
           (uint32_t) (expected >> 32), (uint32_t) expected);
  return actual != expected;
}

int main()
{
  // condition is checked before the first iteration
  if (test__mspabi_srall(0x123456789ABCDEF0LL, 0, 0x123456789ABCDEF0LL))
    return 1;
  // carrying all "zero" bits (...3[4 - 0100]1...)
  if (test__mspabi_srall(0x1234123412341234LL, 1, 0x091A091A091A091ALL))
    return 1;
  // carrying all "one" bits (...3[4 - 0100]1...)
  if (test__mspabi_srall(0x1234123412341234LL, 3, 0x0246824682468246LL))
    return 1;
  // check for 64bit-ness
  if (test__mspabi_srall(0x123456789ABCDEF0LL, 3, 0x02468ACF13579BDELL))
    return 1;
  // right shift is arithmetic
  if (test__mspabi_srall(0x8000000000000000LL, 1, 0xC000000000000000LL))
    return 1;
  // 64 is the maximum allowed shift amount (MSP430 EABI part 6.2)
  if (test__mspabi_srall(0x7FFFFFFFFFFFFFFFLL, 64, 0x0000000000000000LL))
    return 1;
  if (test__mspabi_srall(0xFFFFFFFFFFFFFFFFLL, 64, 0xFFFFFFFFFFFFFFFFLL))
    return 1;
}
