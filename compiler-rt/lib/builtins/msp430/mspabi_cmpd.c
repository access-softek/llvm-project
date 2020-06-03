//===-- mspabi_cmpd.c - Implement __mspabi_cmpd ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __mspabi_cmpd for the compiler_rt library.
//
// On MSP430, __mspabi_cmpd is NOT an alias for __ledf2:
// * it is explicitly defined as UB to pass NaN to it
// * it has different calling convention
//   * __mspabi_cmpd has two 64-bit arguments and is a builtin using a special
//     calling convention
//   * __ledf2, on the other hand, is just a libgcc/compiler-rt traditional
//     builtin with two 64-bit arguments behaving like a regular function
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

COMPILER_RT_ABI int __ledf2(double x, double y);

COMPILER_RT_ABI MSP430_SPECIAL int __mspabi_cmpd(double x, double y)
{
  // For now, just adapt to the proper calling convention
  return __ledf2(x, y);
}
