//===-- lib/fp_div_impl.inc - Floating point division -------------*- C -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements soft-float division with the IEEE-754 default
// rounding (to nearest, ties to even).
//
//===----------------------------------------------------------------------===//

#include <assert.h>
#include <stdio.h>
// Force unrolling the code specified to be repeated N times.
#define REPEAT_1_TIMES(code_to_repeat) code_to_repeat
#define REPEAT_2_TIMES(code_to_repeat) \
  code_to_repeat \
  code_to_repeat
#define REPEAT_3_TIMES(code_to_repeat) \
  REPEAT_2_TIMES(code_to_repeat) \
  code_to_repeat
#define REPEAT_4_TIMES(code_to_repeat) \
  REPEAT_3_TIMES(code_to_repeat) \
  code_to_repeat

#define REPEAT_N_TIMES_(N, code_to_repeat) REPEAT_##N##_TIMES(code_to_repeat)
#define REPEAT_N_TIMES(N, code_to_repeat) REPEAT_N_TIMES_(N, code_to_repeat)

#define HW (typeWidth / 2)

static __inline fp_t __divXf3(fp_t a, fp_t b) {

  const unsigned int aExponent = toRep(a) >> significandBits & maxExponent;
  const unsigned int bExponent = toRep(b) >> significandBits & maxExponent;
  const rep_t quotientSign = (toRep(a) ^ toRep(b)) & signBit;

  rep_t aSignificand = toRep(a) & significandMask;
  rep_t bSignificand = toRep(b) & significandMask;
  int scale = 0;

  // Detect if a or b is zero, denormal, infinity, or NaN.
  if (aExponent - 1U >= maxExponent - 1U ||
      bExponent - 1U >= maxExponent - 1U) {

    const rep_t aAbs = toRep(a) & absMask;
    const rep_t bAbs = toRep(b) & absMask;

    // NaN / anything = qNaN
    if (aAbs > infRep)
      return fromRep(toRep(a) | quietBit);
    // anything / NaN = qNaN
    if (bAbs > infRep)
      return fromRep(toRep(b) | quietBit);

    if (aAbs == infRep) {
      // infinity / infinity = NaN
      if (bAbs == infRep)
        return fromRep(qnanRep);
      // infinity / anything else = +/- infinity
      else
        return fromRep(aAbs | quotientSign);
    }

    // anything else / infinity = +/- 0
    if (bAbs == infRep)
      return fromRep(quotientSign);

    if (!aAbs) {
      // zero / zero = NaN
      if (!bAbs)
        return fromRep(qnanRep);
      // zero / anything else = +/- zero
      else
        return fromRep(quotientSign);
    }
    // anything else / zero = +/- infinity
    if (!bAbs)
      return fromRep(infRep | quotientSign);

    // One or both of a or b is denormal.  The other (if applicable) is a
    // normal number.  Renormalize one or both of a and b, and set scale to
    // include the necessary exponent adjustment.
    if (aAbs < implicitBit)
      scale += normalize(&aSignificand);
    if (bAbs < implicitBit)
      scale -= normalize(&bSignificand);
  }

  // Set the implicit significand bit.  If we fell through from the
  // denormal path it was already set by normalize( ), but setting it twice
  // won't hurt anything.
  aSignificand |= implicitBit;
  bSignificand |= implicitBit;
  int quotientExponent = aExponent - bExponent + scale;

  // Align the significand of b as a UQ1.n fixed-point number in the range
  // [1, 2.0) and get a UQ0.n approximate reciprocal using a small minimax
  // polynomial approximation: x0 = 3/4 + 1/sqrt(2) - b/2.
  // In infinite precision, for b in [1, 2):
  //   0 < x0(b) < 1
  //   abs(x0(b) - 1/b) <= 3/4 - 1/sqrt(2)
  const rep_t b_UQ1 = bSignificand << (typeWidth - significandBits - 1);
  assert(b_UQ1 & signBit);
  const half_rep_t b_UQ1_hw = b_UQ1 >> HW;
  // C is approximately (3/4 + 1/sqrt(2)) - 1 as UQ0.n
  const half_rep_t C = HALF_REP_C(0x7504) << (HW - 16);
  half_rep_t x_UQ0_hw = C - (b_UQ1_hw /* b/2 as UQ0.n */);

  // Now refine the reciprocal estimate using a Newton-Raphson iteration:
  //     x_{n+1} = x_n * (2 - x_n * b)
  //
  // In infinite precision:
  //     X_0 = x_0, abs(X_0 - 1/b) <= 3/4 - 1/sqrt(2) + 2^-16
  //     R_{n+1} = 2 - X_n * b
  //     X_{n+1} = X_n * R_n

#if defined(SINGLE_PRECISION)
#define NUMBER_OF_HALF_ITERATIONS 2
#define RECIPROCAL_PRECISION 24
#elif defined(DOUBLE_PRECISION)
#define NUMBER_OF_HALF_ITERATIONS 3
#define RECIPROCAL_PRECISION 55
#elif defined(QUAD_PRECISION)
#define NUMBER_OF_HALF_ITERATIONS 4
#define RECIPROCAL_PRECISION 114
#else
#error Unsupported precision
#endif
  // e_n := x_n - 1/b_hw
  REPEAT_N_TIMES(NUMBER_OF_HALF_ITERATIONS, {
    half_rep_t corr_UQ1_hw;
    corr_UQ1_hw = (0 /* 2 as UQ1.n */) - ((rep_t)x_UQ0_hw * b_UQ1_hw >> HW);
    x_UQ0_hw   = (rep_t)x_UQ0_hw * corr_UQ1_hw >> (HW - 1);
    // In infinite precision, with abs(eps1), abs(eps2) <= Ulp:
    // corr_UQ1_hw = 2 - (1/b_hw + e_n) * b_hw + eps1
    //             = 1 - e_n * b_hw + eps1
    // x_UQ0_hw = (1/b_hw + e_n) * (1 - e_n*b_hw + eps1) + eps2
    //          = 1/b_hw - e_n + eps1/b_hw + e_n - e_n^2*b_hw + e_n * eps1 + eps2
    //          = 1/b_hw + eps1/b_hw - e_n^2*b_hw + e_n * eps1 + eps2
    // abs(e_{n+1}) <= b_hw * abs(e_n)^2 + U * (1 + 1/b_hw + abs(e_n))
    //              <= 2 * abs(e_n)^2 + 3 * Ulp
  })
  // For initial N-1 half-width iterations, Ulp_h = 2^-(HW-1)
  // Let abs(e_n) <= u_n * Ulp_h
  //     abs(e_{n+1}) <= (2 * u_n^2 * Ulp_h + 3) * Ulp_h
  // after all half-width iterations:
  //    abs(e_{N-1}) <= u_{N-1} * 2^(HW-1)
  // with Ulp = 2^-(W-1):
  //    abs(e_N) <= 2 * u_{N-1}^2 * 2^(W-2) + 3 * 2^(W-1)
  //              = (8 * u_{N-1}^2 + 6) * 2^-W

  rep_t x_UQ0 = ((rep_t)x_UQ0_hw) << HW;

  // Now, one another iteration with full precision
  // Error estimatiobs are calculated just as above, but with Ulp := 1/2^(W-1)
  rep_t corr_UQ1, tmp;
  wideMultiply(x_UQ0, b_UQ1, &corr_UQ1, &tmp);
  wideMultiply(x_UQ0, -corr_UQ1, &x_UQ0, &tmp);
  wideLeftShift(&x_UQ0, &tmp, 1);

  // u_n for different precisions:
  //     u_{n+1} = u_n^2 / 2^(HW-2) + 3
  //             | f32     | f64        | f128
  // Iterations  |         |            |
  // 0           | < 1410  | < 92405760 | < 396879717162024960
  // 1           | < 125   | < 7952403  | < 34155297924710403
  // 2           | < 4     | < 58901    | < 252962663040003.1
  // 3           |         | < 6.3      | < 13875643018.8
  // 4           |         |            | < 44.8
  //     (8 * u_{N-1}^2 + 6) * 2^-W
  // Final error | < 2^-24 | < 2^-55    | < 2^-114

  const rep_t a_UQ1 = aSignificand << (typeWidth - significandBits - 1);
  rep_t quotient_UQ1, dummy;
  wideMultiply(x_UQ0, a_UQ1, &quotient_UQ1, &dummy);

  // First, adjust quotient to be in [1.0, 2.0)
  bool qWasNormalized = false;
  if ((quotient_UQ1 & signBit) == 0) {
    quotient_UQ1 <<= 1;
    quotientExponent--;
    qWasNormalized = true;
    // Now absolute error is two times worse (2^-22 / 2^-53 / 2^-112)
  }

  const int writtenExponent = quotientExponent + exponentBias;

  if (writtenExponent >= maxExponent) {
    // If we have overflowed the exponent, return infinity.
    return fromRep(infRep | quotientSign);
  }

  const int shiftAmount = typeWidth - significandBits - 1;
  rep_t absResult = quotient_UQ1 >> shiftAmount;

  if (writtenExponent >= 0) {
    // including the case when the results becomes normal after rounding
    rep_t midpoint_UQ1 = (2 * absResult + 1) << (shiftAmount - 1);
    wideMultiply(midpoint_UQ1, b_UQ1, &dummy/* UQ2.n */, &tmp);
    int round = dummy < (a_UQ1 >> (1 - qWasNormalized) /* exact */);
    absResult &= significandMask;
    absResult |= (rep_t)writtenExponent << significandBits;
    absResult += round;
    if (absResult & exponentMask)
      return fromRep(absResult | quotientSign);
  }

  // subnormal result
  const int extraShiftAmount = -writtenExponent + 1; // >= 1
  // Prevent UB. The result is zero anyway.
  if (extraShiftAmount >= (int)typeWidth)
    return fromRep(quotientSign);

  absResult >>= extraShiftAmount;
  rep_t midpoint_UQ1 = (2 * absResult + 1) << (shiftAmount + extraShiftAmount - 1);
  wideMultiply(midpoint_UQ1, b_UQ1, &dummy/* UQ2.n */, &tmp);
  printf("q   = 0x%016lx\n", (long)quotient_UQ1);
  printf("m_UQ1 = 0x%016lx\n", (long)(midpoint_UQ1));
  printf("dummy = 0x%016lx\n", (long)(dummy << extraShiftAmount));
  printf("a_UQ1 = 0x%016lx\n", (long)(a_UQ1 >> (1 - qWasNormalized)));
  int round = (dummy << extraShiftAmount) < (a_UQ1 >> (1 - qWasNormalized) /* exact */);
  printf("abs = 0x%016lx\n", (long)absResult);
  absResult += round;
  return fromRep(absResult | quotientSign);
}
