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
    if (test__divdf3(4.450147717014403e-308, 2., 0x10000000000000U))
      return 1;

    return 0;
}
