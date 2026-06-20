//===- DXSAAtomicOps.td - DXSA atomic ops ---------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Atomic instructions of the DXSA dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSAATOMICOPS
#define MLIR_DIALECT_DXSA_IR_DXSAATOMICOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// DXSA shared base for atomic memory ops
//===----------------------------------------------------------------------===//

class DXSA_AtomicOp<string mnemonic> : DXSA_Op<mnemonic> {
  let arguments = (ins
      DXSA_DstOperandAttr:$dst,
      DXSA_SrcOperandAttr:$dst_address,
      DXSA_SrcOperandAttr:$src0);
  let results = (outs);
  let assemblyFormat = "$dst `,` $dst_address `,` $src0 attr-dict";
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_and
//===----------------------------------------------------------------------===//

def DXSA_AtomicAnd : DXSA_AtomicOp<"atomic_and"> {
  let summary = "atomic bitwise AND to memory";
  let description = [{
    Single component 32-bit bitwise AND of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_and u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_or
//===----------------------------------------------------------------------===//

def DXSA_AtomicOr : DXSA_AtomicOp<"atomic_or"> {
  let summary = "atomic bitwise OR to memory";
  let description = [{
    Single component 32-bit bitwise OR of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_or u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_xor
//===----------------------------------------------------------------------===//

def DXSA_AtomicXor : DXSA_AtomicOp<"atomic_xor"> {
  let summary = "atomic bitwise XOR to memory";
  let description = [{
    Single component 32-bit bitwise XOR of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_xor u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_iadd
//===----------------------------------------------------------------------===//

def DXSA_AtomicIAdd : DXSA_AtomicOp<"atomic_iadd"> {
  let summary = "atomic integer add to memory";
  let description = [{
    Single component 32-bit integer add of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.
    Insensitive to sign.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_iadd u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_imax
//===----------------------------------------------------------------------===//

def DXSA_AtomicIMax : DXSA_AtomicOp<"atomic_imax"> {
  let summary = "atomic signed integer max to memory";
  let description = [{
    Single component 32-bit signed max of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_imax u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_imin
//===----------------------------------------------------------------------===//

def DXSA_AtomicIMin : DXSA_AtomicOp<"atomic_imin"> {
  let summary = "atomic signed integer min to memory";
  let description = [{
    Single component 32-bit signed min of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_imin u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_umax
//===----------------------------------------------------------------------===//

def DXSA_AtomicUMax : DXSA_AtomicOp<"atomic_umax"> {
  let summary = "atomic unsigned integer max to memory";
  let description = [{
    Single component 32-bit unsigned max of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_umax u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.atomic_umin
//===----------------------------------------------------------------------===//

def DXSA_AtomicUMin : DXSA_AtomicOp<"atomic_umin"> {
  let summary = "atomic unsigned integer min to memory";
  let description = [{
    Single component 32-bit unsigned min of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxsa.atomic_umin u<0>, r<0>, r<1, <x>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSAATOMICOPS
