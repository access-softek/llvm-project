//===-- msp430.S.inc - MSP430-specific asm helpers ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

/// Actually, I64 shift helpers are defined as
///   [u]int64_t __mspabi_s{rl,ra,ll}ll([u]int64_t shifted_data, int16_t amount)
/// and are called according to the MSP430 EABI, part 6.3 as helpers having
/// two 64-bit arguments passed via R8::R11 and R12::R15 register quads.
///
/// This macro moves the input arguments so
/// * `shifted_data` is moved to R12::R15 (to be shifted in-place and returned)
/// * `amount` is moved to a single 16-bit R11 (not callee-saved)
/// * all callee-saved registers remain untouched
#define MSP430_I64_SHIFT_PROLOGUE                                              \
  /* r13, r14, r15 do not carry any significant data */                        \
  mov r9, r13  SEPARATOR                                                       \
  mov r10, r14 SEPARATOR                                                       \
  mov r11, r15 SEPARATOR                                                       \
  /* now, move shift amount from r12 to r11 (not callee-saved, unused) */      \
  mov r12, r11 SEPARATOR                                                       \
  /* and finally place the entire shifted value to R12::R15 register quad */   \
  mov r8, r12  SEPARATOR
