//===-- mspabi_cmpd.c - Implement __mspabi_cmpd ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __mspabi_cmpd for the compiler_rt library.
// __mspabi_cmpd is a weaker variant of __ledf2 that does not handle NaNs
// and uses a special calling convention.
//
//===----------------------------------------------------------------------===//

#include "../int_lib.h"

int __ledf2(double x, double y);

COMPILER_RT_ABI int __mspabi_cmpd(double x, double y)
{
  // For now, just adapt to the proper calling convention
  return __ledf2(x, y);
}
