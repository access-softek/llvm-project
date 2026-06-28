//===- DXSAResourceOps.td - DXSA resource ops --------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Resource instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSARESOURCEOPS
#define MLIR_DIALECT_DXSA_IR_DXSARESOURCEOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.eval_centroid
//===----------------------------------------------------------------------===//

def DXSA_EvalCentroid : DXSA_UnaryOp<"eval_centroid"> {
  let summary = "evaluate a pixel shader input at the centroid location";
  let description = [{
    The `dxsa.eval_centroid` operation samples the pixel shader input
    attribute `$src` at the centroid location within the pixel and writes
    the result to `$dst`.

    Example:

    ```mlir
    dxsa.eval_centroid r<0>, r<1>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.eval_sample_index
//===----------------------------------------------------------------------===//

def DXSA_EvalSampleIndex : DXSA_BinaryOp<"eval_sample_index"> {
  let summary = "evaluate a pixel shader input at a given sample index";
  let description = [{
    The `dxsa.eval_sample_index` operation samples the pixel shader input
    attribute `$lhs` at the sample whose index is the scalar operand
    `$rhs` and writes the result to `$dst`. `$rhs` is either an integer
    immediate or a single-component register reference.

    Example:

    ```mlir
    dxsa.eval_sample_index r<0>, r<1>, l(0x2)
    dxsa.eval_sample_index r<0>, r<1>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.eval_snapped
//===----------------------------------------------------------------------===//

def DXSA_EvalSnapped : DXSA_BinaryOp<"eval_snapped"> {
  let summary = "evaluate a pixel shader input at a snapped pixel offset";
  let description = [{
    The `dxsa.eval_snapped` operation samples the pixel shader input
    attribute `$lhs` at a fractional pixel offset from the pixel center
    given by the int4 immediate operand `$rhs` (interpreted on a 16x16
    grid using the lowest 4 bits of its first two components) and writes
    the result to `$dst`.

    Example:

    ```mlir
    dxsa.eval_snapped r<0>, r<1>, l(0x2, 0x3, 0x0, 0x0)
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSARESOURCEOPS
