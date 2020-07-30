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

#define HW (typeWidth / 2)
#define loMask (REP_C(-1) >> HW)

#define NUMBER_OF_ITERATIONS \
  (NUMBER_OF_HALF_ITERATIONS + NUMBER_OF_FULL_ITERATIONS)

#if NUMBER_OF_FULL_ITERATIONS < 1
#   error At least one full iteration is required
#endif

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

  int writtenExponent = (aExponent - bExponent + scale) + exponentBias;

  const rep_t b_UQ1 = bSignificand << (typeWidth - significandBits - 1);

  // Align the significand of b as a UQ1.(n-1) fixed-point number in the range
  // [1.0, 2.0) and get a UQ0.n approximate reciprocal using a small minimax
  // polynomial approximation: x0 = 3/4 + 1/sqrt(2) - b/2.
  // In infinite precision, for b in [1, 2):
  //   0 < x0(b) < 1
  //   abs(x0(b) - 1/b) <= 3/4 - 1/sqrt(2)

  // Then, refine the reciprocal estimate using a Newton-Raphson iteration:
  //     x_{n+1} = x_n * (2 - x_n * b)
  // Let e_n := x_n - 1/b_hw
  //     E_n := x_n - 1/b
  // abs(E_n) <= abs(e_n) + (1/b_hw - 1/b)
  //           = abs(e_n) + (b - b_hw) / (b*b_hw)
  //          <= abs(e_n) + 2 * 2^-HW

#if NUMBER_OF_HALF_ITERATIONS > 0
  // Starting with (n-1) half-width iterations
  const half_rep_t b_UQ1_hw = bSignificand >> (significandBits + 1 - HW);

  // C is (3/4 + 1/sqrt(2)) - 1 truncated to W0 fractional bits as UQ0.HW
#if defined(SINGLE_PRECISION)
  const half_rep_t C_hw = HALF_REP_C(0x7504) << (HW - 16);
#else
  const half_rep_t C_hw = HALF_REP_C(0x7504F333) << (HW - 32);
#endif

  half_rep_t x_UQ0_hw = C_hw - (b_UQ1_hw /* b_hw/2 as UQ0.HW */);
  // An error due to truncated C + an error due to truncated x_UQ0_hw:
  // e_0 <= 3/4 - 1/sqrt(2) + 2^-W0 + 2^-HW

  // By construction, 1 <= b < 2
  // f(x)  = x * (2 - b*x) = 2*x - b*x^2
  // f'(x) = 2 * (1 - b*x)
  // f(x) is at most 1/b at x = 1/b, so it is always <= 1.0
  REPEAT_N_TIMES(NUMBER_OF_HALF_ITERATIONS, {
    // Cannot overflow by construction and is larger than 2 - b*x by at most 1*Ulp.
    half_rep_t corr_UQ1_hw = 0 /* = 2 */ - ((rep_t)x_UQ0_hw * b_UQ1_hw >> HW);
    // Would be at most [1.]00000 after overflow if rounding (0 - x_UQ0_hw * b_UQ1_hw) down.
    // Since it was virtually round up (first truncated, then negated),
    // there may be extra 1 added to x_UQ0_hw.
    x_UQ0_hw = (rep_t)x_UQ0_hw * corr_UQ1_hw >> (HW - 1);
    // Now either no overflow occurred or x_UQ0_hw is 0 or 1.
    // When x_UQ0_hw once became 0 or 1, it remains 0 or 1.
    // So, just subtract 2 from the final reciprocal approximation.

    // In infinite precision, with 0 <= eps1, eps2 <= Ulp = 2^-HW:
    // corr_UQ1_hw = 2 - (1/b_hw + e_n) * b_hw + 2*eps1
    //             = 1 - e_n * b_hw + 2*eps1
    // x_UQ0_hw = (1/b_hw + e_n) * (1 - e_n*b_hw + 2*eps1) - eps2
    //          = 1/b_hw - e_n + 2*eps1/b_hw + e_n - e_n^2*b_hw + 2*e_n*eps1 - eps2
    //          = 1/b_hw + 2*eps1/b_hw - e_n^2*b_hw + 2*e_n*eps1 - eps2
    // e_{n+1} = -e_n^2*b_hw + 2*eps1/b_hw + 2*e_n*eps1 - eps2
    //         = 2*e_n*eps1 - (e_n^2*b_hw + eps2) + 2*eps1/b_hw
    //                        \------ >0 -------/   \-- >0 ---/
    // abs(e_{n+1}) <= 2*abs(e_n)*Ulp + max(2 * Ulp, Ulp + 2*e_n^2)
  })
  // For initial half-width iterations, Ulp = 2^-HW
  // Let  abs(e_n)     <= u_n * Ulp,
  // then abs(e_{n+1}) <= Ulp * [2*u_n*Ulp + max(2, 1 + 2*u_n^2*Ulp)]
  // u_{n+1} <= 2 * u_n * Ulp + max(2, 1 + 2 * u_n^2 * Ulp)

  // Account for possible overflow (see above) while changing precision
  // because the condition b == 1.0 may become false here
  // if b is *close enough* to 1.0.
  x_UQ0_hw -= 1U;
  rep_t x_UQ0 = (rep_t)x_UQ0_hw << HW;
  x_UQ0 -= 1U;

#else
  // C is (3/4 + 1/sqrt(2)) - 1 truncated to 32 fractional bits as UQ0.n
  const rep_t C = REP_C(0x7504F333) << (typeWidth - 32);
  rep_t x_UQ0 = C - b_UQ1;
  // E_0 <= 3/4 - 1/sqrt(2) + 2 * 2^-32
#endif

  // Error estimations for full-precision iterations are calculated
  // just as above, but with Ulp := 2^-W. We need at least one such iteration.

#ifdef USE_NATIVE_FULL_ITERATIONS
  REPEAT_N_TIMES(NUMBER_OF_FULL_ITERATIONS, {
    rep_t corr_UQ1 = 0 /* = 2 */ - ((twice_rep_t)x_UQ0 * b_UQ1 >> typeWidth);
    x_UQ0 = (twice_rep_t)x_UQ0 * corr_UQ1 >> (typeWidth - 1);
  })
#else
# if NUMBER_OF_FULL_ITERATIONS != 1
#   error Only a single emulated full iteration is supported
# endif
  rep_t blo = b_UQ1 & loMask;
  // x_UQ0 = x_UQ0_hw * 2^HW - 1
  // x_UQ0 * b_UQ1 = (x_UQ0_hw * 2^HW) * (b_UQ1_hw * 2^HW + blo) - b_UQ1
  rep_t corr_UQ1 = 0 - (   (rep_t)x_UQ0_hw * b_UQ1_hw
                        + ((rep_t)x_UQ0_hw * blo >> HW)
                        - REP_C(1)); // to account for *possible* carry due to "- b_UQ1"
  rep_t lo_corr = corr_UQ1 & loMask;
  rep_t hi_corr = corr_UQ1 >> HW;
  // x_UQ0 * corr_UQ1 = (x_UQ0_hw * 2^HW) * (hi_corr * 2^HW + lo_corr) - corr_UQ1
  x_UQ0 =   ((rep_t)x_UQ0_hw * hi_corr << 1)
          + ((rep_t)x_UQ0_hw * lo_corr >> (HW - 1))
          - REP_C(2); // 1 to account for the highest bit of corr_UQ1 can be 1 and
                      // plus 1 to account for possible carry
  // Just like the case of half-width iterations but with possibility
  // of overflowing to 2
  x_UQ0 -= 1U;
  // ... and then traditional fixup by 2 should work

  // On error estimates, analogously to the half-width iterations:
  // abs(E_{N-1}) <= (u_{N-1} + 2 /* due to conversion e_n -> E_n */) * 2^-HW + (2^-HW + 2^-W))
  // abs(E_{N-1}) <= (u_{N-1} + 3.01) * 2^-HW

  // With 0 <= eps1 < 2^-W
  // E_N = -E_{N-1}^2*b + 4*eps1/b + 4*E_{N-1}*eps1 - (1+2+1)*eps2
  //     = 4*E_{N-1}*eps1 - (E_{N-1}^2 * b + 4 * eps2) + 4*eps1/b
  // E_N <= 2^-W * [ 4*(u_{N-1} + 3.01) * 2^-HW + 4 + 2 * (e_{N-1} + 3.01)^2 ]
#endif

  // Finally, account for possible overflow, as explained above.
  x_UQ0 -= 2U;

  // u_n for different precisions (with N-1 half-width iterations):
  // W0 is the precision of C
  //     u_0     = (3/4 - 1/sqrt(2) + 2^-W0) * 2^HW + 1

  //             | f32          | f64          | f128
  // Iterations  |              |              |
  // 0           | < 2813.1     | < 184224974  | < 791240229949381501
  // 1           | < 242.7      | < 15804007   | < 67877680634450550
  // 2           | < 2.81       | < 116308     | < 499533089406164
  // 3           |              | < 7.31       | < 27054455403
  // 4           |              |              | < 80.4

  // Final error | < 74 / 2^32  | < 220 / 2^64 | < 13921 * 2^-128

#if defined(SINGLE_PRECISION) && NUMBER_OF_HALF_ITERATIONS == 2
#   define RECIPROCAL_PRECISION REP_C(74)
#elif defined(SINGLE_PRECISION) && NUMBER_OF_ITERATIONS == 3
#   define RECIPROCAL_PRECISION REP_C(8)
#elif defined(DOUBLE_PRECISION) && NUMBER_OF_ITERATIONS == 4
#   define RECIPROCAL_PRECISION REP_C(220)
#elif defined(QUAD_PRECISION) && NUMBER_OF_ITERATIONS == 5
#   define RECIPROCAL_PRECISION REP_C(13921)
#else
#   error Invalid number of iterations
#endif

  // Suppose 1/b - P * 2^-W < x < 1/b + P * 2^-W
  x_UQ0 -= RECIPROCAL_PRECISION;
  // Now 1/b - (2*P) * 2^-W < x < 1/b
  // FIXME Is x_UQ0 still >= 0.5?

  rep_t quotient_UQ1, dummy;
  wideMultiply(x_UQ0, aSignificand << 1, &quotient_UQ1, &dummy);
  // Now, a/b - 4*P * 2^-W < q < a/b

  // quotient_UQ1 is in [0.5, 2.0) as UQ1.(SB+1), adjust it to be in [1.0, 2.0) as UQ1.SB
  rep_t residualLo;
  if (quotient_UQ1 < (implicitBit << 1)) {
    residualLo = (aSignificand << (significandBits + 1)) - quotient_UQ1 * bSignificand;
    writtenExponent -= 1;

    // the error is doubled
  } else {
    quotient_UQ1 >>= 1;
    residualLo = (aSignificand << significandBits) - quotient_UQ1 * bSignificand;
  }
  // Now, q cannot be greater than a/b and can differ by at most 8*P * 2^-W + 2^-SB
  // Each NextAfter() increments the floating point value by at least 2^-SB
  // (more, if exponent was incremented).
  // Different cases (<---> is of 2^-SB length, * = a/b that is shown as a midpoint):
  //   q
  //   |   | * |   |   |       |       |
  //       <--->      2^t
  //   |   |   |   |   |   *   |       |
  //               q
  // To require at most one NextAfter(), an error should be less than 1.5 * 2^-SB.
  // (8*P) * 2^-W + 2^-SB < 1.5 * 2^-SB <=> (8*P) * 2^-W < 0.5 * 2^-SB <=> P < 2^(W-4-SB)
  // Generally, for at most R NextAfter(), the P < (2*R - 1) * 2^(W-4-SB)
  // For f32: 8 < 32 (OK) but 71 > 32 (but two NextAfter() are enough)
  // For f64: 220 < 256 (OK)
  // For f128: 14120 > 4096 (*three* NextAfter() are required)

  // If we have overflowed the exponent, return infinity
  if (writtenExponent >= maxExponent)
    return fromRep(infRep | quotientSign);

  // Now, quotient_UQ1_SB <= the correctly-rounded result
  // and may need taking NextAfter() up to 3 times (see error estimates above)
  // r = a - b * q

  if (writtenExponent < 0) {
    // Result is definitely subnormal, flushing to zero
    return fromRep(quotientSign);
  }

  // Clear the implicit bit
  rep_t absResult = quotient_UQ1 & significandMask;
  // Insert the exponent
  absResult |= (rep_t)writtenExponent << significandBits;

  // Round
  residualLo <<= 1;
  residualLo += absResult & 1; // tie to even
  absResult += residualLo > bSignificand;
#if defined(QUAD_PRECISION) || (defined(SINGLE_PRECISION) && NUMBER_OF_HALF_ITERATIONS > 0)
  // Do not round Infinity to NaN
  absResult += absResult < infRep && residualLo > (2 + 1) * bSignificand;
#endif
#if defined(QUAD_PRECISION)
  absResult += absResult < infRep && residualLo > (4 + 1) * bSignificand;
#endif

  if ((absResult & ~significandMask) == 0) {
    // Result is subnormal, flushing to zero
    return fromRep(quotientSign);
  }
  // Result is normal, insert the sign and return
  return fromRep(absResult | quotientSign);
}
