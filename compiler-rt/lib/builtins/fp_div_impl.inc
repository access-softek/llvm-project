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

// Force unrolling the code specified to be repeated N times.
#define REPEAT_1_TIMES(code_to_repeat) code_to_repeat
#define REPEAT_2_TIMES(code_to_repeat) \
  code_to_repeat \
  code_to_repeat
#define REPEAT_3_TIMES(code_to_repeat) \
  code_to_repeat \
  code_to_repeat \
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
  //   abs(x0(b) - 1/b) <= (3 - 2sqrt(2)) / 4
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
  //     X_0 = x_0, abs(X_0 - 1/b) <= 1/20
  //     R_{n+1} = 2 - X_n * b
  //     X_{n+1} = X_n * R_n
  //
  //     abs(X_n - 1/b) = abs(X_0 - 1/b) ^ (2^n)
  //
  // Let x_0 be initial approximation to X_0, x_n are calcucated in
  // fixed precision, e_n := x_n - X_n.

#if defined(SINGLE_PRECISION)
#define NUMBER_OF_HALF_ITERATIONS 2
#elif defined(DOUBLE_PRECISION)
#define NUMBER_OF_HALF_ITERATIONS 3
#elif defined(QUAD_PRECISION)
#define NUMBER_OF_HALF_ITERATIONS 4
#else
#error Unsupported precision
#endif
  // Let Uhw := 1/2^(HW-1), suppose abs(e_n) <= Uhw*q^n
  REPEAT_N_TIMES(NUMBER_OF_HALF_ITERATIONS, {
    half_rep_t corr_UQ1_hw;
    corr_UQ1_hw = (0 /* 2 as UQ1.n */) - ((rep_t)x_UQ0_hw * b_UQ1_hw >> HW);
    // corr_UQ1_hw = 2 - (X_n + e_n) * (b + eps1) + eps2 in infinite precision, where
    //     abs(eps1), abs(eps2) <= Uhw
    // Thus, abs(corr_UQ1_hw - R_{n+1}) <= Uhw*q^n * (2+Uhw) + 2*Uhw

    x_UQ0_hw   = (rep_t)x_UQ0_hw * corr_UQ1_hw >> (HW - 1);
    // x_UQ1_h = (X_n + e_n) * (R_{n+1} + eps1) + 2*eps2 in infinite precision, where
    //     abs(eps1) <= Uhw*q^n*(2+Uhw) + 2*Uhw,
    //     abs(eps2) <= Uhw,
    // e_{n+1} <= Uhw*q^n * (2 + Uhw*q^n*(2+Uhw) + 2*Uhw) + 3*Uhw = Uhw*q^n * (2 + Uhw*q^n*(2+Uhw) + 2*Uhw + 3/(Uhw*q^n))

    // q = 3 should be sufficient
  })
  //        | abs(X_n - 1/b)  | e_n
  // f32    | < 1/2^18        | < 1/2^12
  // f64    | < 1/2^35        | < 1/2^27
  // f128   | < 1/2^70        | < 1/2^57
  rep_t x_UQ0 = ((rep_t)x_UQ0_hw) << HW;

  // Now, one another iteration with full precision
  rep_t corr_UQ1, tmp;
  wideMultiply(x_UQ0, b_UQ1, &corr_UQ1, &tmp);
  wideMultiply(x_UQ0, -corr_UQ1, &x_UQ0, &tmp);
  wideLeftShift(&x_UQ0, &tmp, 1);

  // Adust the final rep_t-sized reciprocal estimate downward to ensure that
  // it is strictly smaller than the infinitely precise exact reciprocal.
  // Because the computation of the Newton-Raphson step is truncating at every
  // step, this adjustment is small; most of the work is already done.
  x_UQ0 -= 2;

  // FIXME: Generalize the description from float32 to other sizes.
  // The numerical reciprocal is accurate to within 2^-28, lies in the
  // interval [0x1.000000eep-1, 0x1.fffffffcp-1], and is strictly smaller
  // than the true reciprocal of b.  Multiplying a by this reciprocal thus
  // gives a numerical q = a/b in Q24 with the following properties:
  //
  //    1. q < a/b
  //    2. q is in the interval [0x1.000000eep-1, 0x1.fffffffcp0)
  //    3. The error in q is at most 2^-24 + 2^-27 -- the 2^24 term comes
  //       from the fact that we truncate the product, and the 2^27 term
  //       is the error in the reciprocal of b scaled by the maximum
  //       possible value of a.  As a consequence of this error bound,
  //       either q or nextafter(q) is the correctly rounded.
  rep_t quotient, dummy;
  wideMultiply(x_UQ0, aSignificand << 1, &quotient, &dummy);

  // Two cases: quotient is in [0.5, 1.0) or quotient is in [1.0, 2.0).
  // In either case, we are going to compute a residual of the form
  //
  //     r = a - q*b
  //
  // We know from the construction of q that r satisfies:
  //
  //     0 <= r < ulp(q)*b
  //
  // If r is greater than 1/2 ulp(q)*b, then q rounds up.  Otherwise, we
  // already have the correct result.  The exact halfway case cannot occur.
  // We also take this time to right shift quotient if it falls in the [1,2)
  // range and adjust the exponent accordingly.
  rep_t residual;
  rep_t qb;

  bool qShifted = false;
  if (quotient < (implicitBit << 1)) {
    wideMultiply(quotient, bSignificand, &dummy, &qb);
    residual = (aSignificand << (significandBits + 1)) - qb;
    quotientExponent--;
  } else {
    quotient >>= 1;
    qShifted = true;
    wideMultiply(quotient, bSignificand, &dummy, &qb);
    residual = (aSignificand << significandBits) - qb;
  }

  const int writtenExponent = quotientExponent + exponentBias;

  if (writtenExponent >= maxExponent) {
    // If we have overflowed the exponent, return infinity.
    return fromRep(infRep | quotientSign);
  } else if (writtenExponent < 1) {
    if (writtenExponent == 0) {
      // Check whether the rounded result is normal.
      const bool round = (residual << 1) > bSignificand;
      // Clear the implicit bit.
      rep_t absResult = quotient & significandMask;
      // Round.
      absResult += round;
      if (absResult & ~significandMask) {
        // The rounded result is normal; return it.
        return fromRep(absResult | quotientSign);
      }
    }
    // quotient is Q1.SB and is >= 1
    assert(quotient >= implicitBit);
    assert(quotient < (implicitBit << 1));

    // Prevent UB
    if (-writtenExponent + 1 >= (int)typeWidth)
      return fromRep(quotientSign);

    rep_t resSignificand = quotient >> (-writtenExponent + 1);
    wideMultiply(resSignificand, bSignificand, &dummy, &qb);
    const int shiftAmount = significandBits + writtenExponent - qShifted;

    if (shiftAmount > 0)
      residual = (aSignificand << shiftAmount) - qb;
    else
      residual = (aSignificand >> -shiftAmount) - qb;
    const bool round = ((residual << 1) > bSignificand) ||
        ((residual << 1) == bSignificand && (resSignificand & 1));
    resSignificand += round;
    return fromRep(resSignificand | quotientSign);
  } else {
    const bool round = (residual << 1) > bSignificand;
    // Clear the implicit bit.
    rep_t absResult = quotient & significandMask;
    // Insert the exponent.
    absResult |= (rep_t)writtenExponent << significandBits;
    // Round.
    absResult += round;
    // Insert the sign and return.
    const fp_t result = fromRep(absResult | quotientSign);
    return result;
  }
}
