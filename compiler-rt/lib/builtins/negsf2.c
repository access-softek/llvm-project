//===-- lib/negsf2.c - single-precision negation ------------------*- C -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements single-precision soft-float negation.
//
//===----------------------------------------------------------------------===//

#define SINGLE_PRECISION
#include "fp_lib.h"

DECLARE_LIBCALL(fp_t, __negsf2, fp_t a) { return fromRep(toRep(a) ^ signBit); }

AUX_DECLS(__negsf2)
