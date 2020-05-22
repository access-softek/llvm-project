//===-- lib/divtf3.c - Quad-precision division --------------------*- C -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements quad-precision soft-float division
// with the IEEE-754 default rounding (to nearest, ties to even).
//
// For simplicity, this implementation currently flushes denormals to zero.
// It should be a fairly straightforward exercise to implement gradual
// underflow with correct rounding.
//
//===----------------------------------------------------------------------===//

#define QUAD_PRECISION
#include "fp_lib.h"

#if defined(CRT_HAS_128BIT) && defined(CRT_LDBL_128BIT)

#define INITIALIZATION_CONSTANT \
  ((REP_C(UINT64_C(0x7504F333F9DE6484)) << 64) | REP_C(0x597D89B3754ABE9F))
#define NUMBER_OF_ITERATIONS 5
#include "fp_div_impl.inc"

COMPILER_RT_ABI fp_t __divtf3(fp_t a, fp_t b) { return __divXf3(a, b); }

#endif
