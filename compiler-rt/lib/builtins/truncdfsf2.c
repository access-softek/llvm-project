//===-- lib/truncdfsf2.c - double -> single conversion ------------*- C -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#define SRC_DOUBLE
#define DST_SINGLE
#include "fp_trunc_impl.inc"

DECLARE_LIBCALL(float, __truncdfsf2, double a) { return __truncXfYf2__(a); }

AUX_DECLS(__truncdfsf2)
