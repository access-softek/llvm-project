// RUN: %clang_builtins %s %librt -o %t && %run %t
// REQUIRES: librt_has_divdf3
//===--------------- divdf3_test.c - Test __divdf3 ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file tests __divdf3 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "int_lib.h"
#include <stdio.h>

#include "fp_test.h"

// Returns: a / b
COMPILER_RT_ABI double __divdf3(double a, double b);

int test__divdf3(double a, double b, uint64_t expected)
{
    double x = __divdf3(a, b);
    int ret = compareResultD(x, expected);

    if (ret){
        printf("error in test__divdf3(%.20e, %.20e) = %.20e, "
               "expected %.20e\n", a, b, x,
               fromRep64(expected));
    }
    return ret;
}

int main()
{
    // qNaN / any = qNaN
    if (test__divdf3(makeQNaN64(), 3., 0x7ff8000000000000U))
      return 1;
    // NaN / any = NaN
    if (test__divdf3(makeNaN64(0x800030000000ULL), 3., 0x7ff8000000000000U))
      return 1;

    // +Inf / positive = +Inf
    if (test__divdf3(makeInf64(), 3., 0x7ff0000000000000U))
      return 1;
    // +Inf / negative = -Inf
    if (test__divdf3(makeInf64(), -3., 0xfff0000000000000U))
      return 1;
    // -Inf / positive = -Inf
    if (test__divdf3(makeNegativeInf64(), 3., 0xfff0000000000000U))
      return 1;
    // -Inf / negative = +Inf
    if (test__divdf3(makeNegativeInf64(), -3., 0x7ff0000000000000U))
      return 1;

    // Inf / Inf = NaN
    if (test__divdf3(makeInf64(), makeInf64(), 0x7ff8000000000000U))
      return 1;
    // 0.0 / 0.0 = NaN
    if (test__divdf3(+0x0.0p+0, +0x0.0p+0, 0x7ff8000000000000U))
      return 1;

    // positive / +0.0 = +Inf
    if (test__divdf3(+1.0, +0x0.0p+0, 0x7ff0000000000000U))
      return 1;
    // positive / -0.0 = -Inf
    if (test__divdf3(+1.0, -0x0.0p+0, 0xfff0000000000000U))
      return 1;
    // negative / +0.0 = -Inf
    if (test__divdf3(-1.0, +0x0.0p+0, 0xfff0000000000000U))
      return 1;
    // negative / -0.0 = +Inf
    if (test__divdf3(-1.0, -0x0.0p+0, 0x7ff0000000000000U))
      return 1;

    // 1/3
    if (test__divdf3(1., 3., 0x3fd5555555555555U))
      return 1;
    // smallest normal result
    if (test__divdf3(0x1.0p-1021, 2.0, 0x0010000000000000U))
      return 1;

    // smallest normal value divided by 2.0
    if (test__divdf3(0x1.0p-1022, 2.0, 0x0008000000000000U))
      return 1;
    // smallest subnormal result
    if (test__divdf3(0x1.0p-1022, 0x1p+52, 0x0000000000000001U))
      return 1;

    // some misc test cases obtained by fuzzing against h/w implementation
    if (test__divdf3(0x1.0p-1022, 0x1.9p+5, 0x000051eb851eb852U))
      return 1;
    if (test__divdf3(0x1.0p-1022, 0x1.0028p+41, 0x00000000000007ffU))
      return 1;
    if (test__divdf3(0x1.0p-1022, 0x1.0028p+52, 0x1U))
      return 1;

    return 0;
}
