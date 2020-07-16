//===-- mingw_fixfloat.c - Wrap int/float conversions for arm/windows -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "int_lib.h"

DECLARE_LIBCALL(di_int, __fixdfdi, double a);
DECLARE_LIBCALL(di_int, __fixsfdi, float a);
DECLARE_LIBCALL(du_int, __fixunsdfdi, double a);
DECLARE_LIBCALL(du_int, __fixunssfdi, float a);
DECLARE_LIBCALL(double, __floatdidf, di_int a);
DECLARE_LIBCALL(float, __floatdisf, di_int a);
DECLARE_LIBCALL(double, __floatundidf, du_int a);
DECLARE_LIBCALL(float, __floatundisf, du_int a);

DECLARE_LIBCALL(di_int, __dtoi64, double a) { return __fixdfdi(a); }

DECLARE_LIBCALL(di_int, __stoi64, float a) { return __fixsfdi(a); }

DECLARE_LIBCALL(du_int, __dtou64, double a) { return __fixunsdfdi(a); }

DECLARE_LIBCALL(du_int, __stou64, float a) { return __fixunssfdi(a); }

DECLARE_LIBCALL(double, __i64tod, di_int a) { return __floatdidf(a); }

DECLARE_LIBCALL(float, __i64tos, di_int a) { return __floatdisf(a); }

DECLARE_LIBCALL(double, __u64tod, du_int a) { return __floatundidf(a); }

DECLARE_LIBCALL(float, __u64tos, du_int a) { return __floatundisf(a); }
