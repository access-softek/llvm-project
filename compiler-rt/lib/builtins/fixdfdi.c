//===-- fixdfdi.c - Implement __fixdfdi -----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#define DOUBLE_PRECISION
#include "fp_lib.h"

#ifndef __SOFT_FP__
// Support for systems that have hardware floating-point; can set the invalid
// flag as a side-effect of computation.

DECLARE_LIBCALL(du_int, __fixunsdfdi, double a);

DECLARE_LIBCALL(di_int, __fixdfdi, double a) {
  if (a < 0.0) {
    return -__fixunsdfdi(-a);
  }
  return __fixunsdfdi(a);
}

#else
// Support for systems that don't have hardware floating-point; there are no
// flags to set, and we don't want to code-gen to an unknown soft-float
// implementation.

typedef di_int fixint_t;
typedef du_int fixuint_t;
#include "fp_fixint_impl.inc"

DECLARE_LIBCALL(di_int, __fixdfdi, fp_t a) { return __fixint(a); }

#endif

AUX_DECLS(__fixdfdi)
