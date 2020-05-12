// REQUIRES: target-is-msp430
// First, it MUST be detected as a test fail by the testing environment
// RUN: %clang_builtins %s %librt -o %t && not %run %t
// Next, test how it interferes with stdout
// RUN: %clang_builtins %s %librt -o %t && not %run %t 2>&1 | FileCheck %s
//===-- sim_abort_test.c - Test abort() -----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Test that the standard abort() function works as expected by the testing
// environment.
//
//===----------------------------------------------------------------------===//

#include <stdio.h>
#include <stdlib.h>

int main()
{
  printf("NORMAL TEXT\n");
// CHECK: NORMAL TEXT
  abort();
  // This should not be executed
  return 0;
}
