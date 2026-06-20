//===- DXBCAtomicOps.td - DXBC atomic ops ---------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Atomic instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCATOMICOPS
#define MLIR_DIALECT_DXBC_IR_DXBCATOMICOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// DXBC shared base for atomic memory ops
//===----------------------------------------------------------------------===//

class DXBC_AtomicOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$dst_address,
      DXBC_SrcOperandAttr:$src0);
  let results = (outs);
  let assemblyFormat = "$dst `,` $dst_address `,` $src0 attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_and
//===----------------------------------------------------------------------===//

def DXBC_AtomicAnd : DXBC_AtomicOp<"atomic_and"> {
  let summary = "atomic bitwise AND to memory";
  let description = [{
    Single component 32-bit bitwise AND of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_and u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_or
//===----------------------------------------------------------------------===//

def DXBC_AtomicOr : DXBC_AtomicOp<"atomic_or"> {
  let summary = "atomic bitwise OR to memory";
  let description = [{
    Single component 32-bit bitwise OR of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_or u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_xor
//===----------------------------------------------------------------------===//

def DXBC_AtomicXor : DXBC_AtomicOp<"atomic_xor"> {
  let summary = "atomic bitwise XOR to memory";
  let description = [{
    Single component 32-bit bitwise XOR of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_xor u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_iadd
//===----------------------------------------------------------------------===//

def DXBC_AtomicIAdd : DXBC_AtomicOp<"atomic_iadd"> {
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
    dxbc.atomic_iadd u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_imax
//===----------------------------------------------------------------------===//

def DXBC_AtomicIMax : DXBC_AtomicOp<"atomic_imax"> {
  let summary = "atomic signed integer max to memory";
  let description = [{
    Single component 32-bit signed max of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_imax u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_imin
//===----------------------------------------------------------------------===//

def DXBC_AtomicIMin : DXBC_AtomicOp<"atomic_imin"> {
  let summary = "atomic signed integer min to memory";
  let description = [{
    Single component 32-bit signed min of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_imin u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_umax
//===----------------------------------------------------------------------===//

def DXBC_AtomicUMax : DXBC_AtomicOp<"atomic_umax"> {
  let summary = "atomic unsigned integer max to memory";
  let description = [{
    Single component 32-bit unsigned max of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_umax u<0>, r<0>, r<1, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_umin
//===----------------------------------------------------------------------===//

def DXBC_AtomicUMin : DXBC_AtomicOp<"atomic_umin"> {
  let summary = "atomic unsigned integer min to memory";
  let description = [{
    Single component 32-bit unsigned min of `$src0` into `$dst` at the
    32-bit per-component address `$dst_address`, performed atomically.

    `$dst` must be a UAV, or in a Compute Shader it can also be
    thread group shared memory. The number of components taken from
    `$dst_address` is determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_umin u<0>, r<0>, r<1, <x>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCATOMICOPS
