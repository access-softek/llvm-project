//===-- mspabi_func_epilog.S - MSP430 EABI epilog helper functions --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

#define MSPABI_FUNC_EPILOG_ENTRY(n) \
  DEFINE_COMPILERRT_FUNCTION(__mspabi_func_epilog_##n)
#define MSPABI_FUNC_EPILOG_MARK_END_FOR(n) \
  END_COMPILERRT_FUNCTION(__mspabi_func_epilog_##n)

MSPABI_FUNC_EPILOG_ENTRY(7)
  pop r4
MSPABI_FUNC_EPILOG_ENTRY(6)
  pop r5
MSPABI_FUNC_EPILOG_ENTRY(5)
  pop r6
MSPABI_FUNC_EPILOG_ENTRY(4)
  pop r7
MSPABI_FUNC_EPILOG_ENTRY(3)
  pop r8
MSPABI_FUNC_EPILOG_ENTRY(2)
  pop r9
MSPABI_FUNC_EPILOG_ENTRY(1)
  pop r10
  ret
MSPABI_FUNC_EPILOG_MARK_END_FOR(1)
MSPABI_FUNC_EPILOG_MARK_END_FOR(2)
MSPABI_FUNC_EPILOG_MARK_END_FOR(3)
MSPABI_FUNC_EPILOG_MARK_END_FOR(4)
MSPABI_FUNC_EPILOG_MARK_END_FOR(5)
MSPABI_FUNC_EPILOG_MARK_END_FOR(6)
MSPABI_FUNC_EPILOG_MARK_END_FOR(7)
