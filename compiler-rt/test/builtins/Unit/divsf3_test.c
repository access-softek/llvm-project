// RUN: %clang_builtins %s %librt -o %t && %run %t
// REQUIRES: librt_has_divsf3
//===--------------- divsf3_test.c - Test __divsf3 ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __divsf3 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "int_lib.h"
#include <stdio.h>

#include "fp_test.h"

// Returns: a / b
COMPILER_RT_ABI float __divsf3(float a, float b);

int test__divsf3(float a, float b, uint32_t expected)
{
    float x = __divsf3(a, b);
    int ret = compareResultF(x, expected);

    if (ret){
        printf("error in test__divsf3(%.20e, %.20e) = %.20e, "
               "expected %.20e\n", a, b, x,
               fromRep32(expected));
    }
    return ret;
}

int main()
{
    // qNaN / any = qNaN
    if (test__divsf3(makeQNaN32(), 3., 0x7fc00000U))
      return 1;
    // NaN / any = NaN
    if (test__divsf3(makeNaN32(0x400030U), 3., 0x7fc00000U))
      return 1;

    // +Inf / positive = +Inf
    if (test__divsf3(makeInf32(), 3., 0x7f800000U))
      return 1;
    // +Inf / negative = -Inf
    if (test__divsf3(makeInf32(), -3., 0xff800000U))
      return 1;
    // -Inf / positive = -Inf
    if (test__divsf3(makeNegativeInf32(), 3., 0xff800000U))
      return 1;
    // -Inf / negative = +Inf
    if (test__divsf3(makeNegativeInf32(), -3., 0x7f800000U))
      return 1;

    // Inf / Inf = NaN
    if (test__divsf3(makeInf32(), makeInf32(), 0x7fc00000U))
      return 1;
    // 0.0 / 0.0 = NaN
    if (test__divsf3(+0x0.0p+0, +0x0.0p+0, 0x7fc00000U))
      return 1;

    // positive / +0.0 = +Inf
    if (test__divsf3(+1.0, +0x0.0p+0, 0x7f800000U))
      return 1;
    // positive / -0.0 = -Inf
    if (test__divsf3(+1.0, -0x0.0p+0, 0xff800000U))
      return 1;
    // negative / +0.0 = -Inf
    if (test__divsf3(-1.0, +0x0.0p+0, 0xff800000U))
      return 1;
    // negative / -0.0 = +Inf
    if (test__divsf3(-1.0, -0x0.0p+0, 0x7f800000U))
      return 1;

    // 1/3
    if (test__divsf3(1.f, 3.f, 0x3EAAAAABU))
      return 1;
    // smallest normal result
    if (test__divsf3(2.3509887e-38, 2., 0x00800000U))
      return 1;

    return 0;
}
