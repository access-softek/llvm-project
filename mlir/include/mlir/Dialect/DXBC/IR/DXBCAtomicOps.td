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

//===----------------------------------------------------------------------===//
// DXBC shared base for immediate atomic ops returning the prior value
//===----------------------------------------------------------------------===//

class DXBC_ImmAtomicBinaryOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst0,
      DXBC_DstOperandAttr:$dst1,
      DXBC_SrcOperandAttr:$dst_address,
      DXBC_SrcOperandAttr:$src0);
  let results = (outs);
  let assemblyFormat =
      "$dst0 `,` $dst1 `,` $dst_address `,` $src0 attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_iadd
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicIAdd : DXBC_ImmAtomicBinaryOp<"imm_atomic_iadd"> {
  let summary = "atomic integer add to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_iadd` operation atomically adds `$src0` to the single
    32-bit value in `$dst1` memory at the per-component address `$dst_address`
    and returns the value held there before the add into `$dst0`. The add is
    insensitive to sign.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_iadd r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_and
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicAnd : DXBC_ImmAtomicBinaryOp<"imm_atomic_and"> {
  let summary = "atomic bitwise AND to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_and` operation atomically computes the bitwise AND of
    `$src0` with the single 32-bit value in `$dst1` memory at the per-component
    address `$dst_address` and returns the value held there before the AND into
    `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_and r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_or
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicOr : DXBC_ImmAtomicBinaryOp<"imm_atomic_or"> {
  let summary = "atomic bitwise OR to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_or` operation atomically computes the bitwise OR of
    `$src0` with the single 32-bit value in `$dst1` memory at the per-component
    address `$dst_address` and returns the value held there before the OR into
    `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_or r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_xor
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicXor : DXBC_ImmAtomicBinaryOp<"imm_atomic_xor"> {
  let summary = "atomic bitwise XOR to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_xor` operation atomically computes the bitwise XOR of
    `$src0` with the single 32-bit value in `$dst1` memory at the per-component
    address `$dst_address` and returns the value held there before the XOR into
    `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_xor r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_imax
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicIMax : DXBC_ImmAtomicBinaryOp<"imm_atomic_imax"> {
  let summary = "atomic signed integer max to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_imax` operation atomically computes the signed integer
    maximum of `$src0` and the single 32-bit value in `$dst1` memory at the
    per-component address `$dst_address` and returns the value held there before
    the operation into `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_imax r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_imin
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicIMin : DXBC_ImmAtomicBinaryOp<"imm_atomic_imin"> {
  let summary = "atomic signed integer min to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_imin` operation atomically computes the signed integer
    minimum of `$src0` and the single 32-bit value in `$dst1` memory at the
    per-component address `$dst_address` and returns the value held there before
    the operation into `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_imin r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_umax
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicUMax : DXBC_ImmAtomicBinaryOp<"imm_atomic_umax"> {
  let summary =
      "atomic unsigned integer max to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_umax` operation atomically computes the unsigned
    integer maximum of `$src0` and the single 32-bit value in `$dst1` memory at
    the per-component address `$dst_address` and returns the value held there
    before the operation into `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_umax r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_umin
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicUMin : DXBC_ImmAtomicBinaryOp<"imm_atomic_umin"> {
  let summary =
      "atomic unsigned integer min to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_umin` operation atomically computes the unsigned
    integer minimum of `$src0` and the single 32-bit value in `$dst1` memory at
    the per-component address `$dst_address` and returns the value held there
    before the operation into `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_umin r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.atomic_cmp_store
//===----------------------------------------------------------------------===//

def DXBC_AtomicCmpStore : DXBC_Op<"atomic_cmp_store"> {
  let summary = "atomic compare and conditional write to memory";
  let description = [{
    The `dxbc.atomic_cmp_store` operation atomically compares `$src0` with the
    single 32-bit value in `$dst` memory at the per-component address
    `$dst_address`. If the values are equal, `$src1` is written to that
    location, otherwise the location is left unchanged. Nothing is returned to
    the shader.

    `$dst` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst`.

    Example:

    ```mlir
    dxbc.atomic_cmp_store u<0>, r<1>, r<2>, r<3>
    ```
  }];
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$dst_address,
      DXBC_SrcOperandAttr:$src0,
      DXBC_SrcOperandAttr:$src1);
  let results = (outs);
  let assemblyFormat =
      "$dst `,` $dst_address `,` $src0 `,` $src1 attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_exch
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicExch : DXBC_ImmAtomicBinaryOp<"imm_atomic_exch"> {
  let summary = "atomic exchange to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_exch` operation atomically writes `$src0` to the single
    32-bit value in `$dst1` memory at the per-component address `$dst_address`
    and returns the value held there before the write into `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_exch r<0, <x>>, u<0>, r<1>, r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_cmp_exch
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicCmpExch : DXBC_Op<"imm_atomic_cmp_exch"> {
  let summary =
      "atomic compare and exchange to memory, returning the prior value";
  let description = [{
    The `dxbc.imm_atomic_cmp_exch` operation atomically compares `$src0` with
    the single 32-bit value in `$dst1` memory at the per-component address
    `$dst_address`. If the values are equal, `$src1` is written to that
    location, otherwise the location is left unchanged. The value held there
    before the operation is always returned into `$dst0`.

    `$dst1` must be an UnorderedAccessView (UAV), or in a Compute Shader thread
    group shared memory. The number of components taken from `$dst_address` is
    determined by the dimensionality of `$dst1`.

    Example:

    ```mlir
    dxbc.imm_atomic_cmp_exch r<0, <x>>, u<0>, r<1>, r<2>, r<3>
    ```
  }];
  let arguments = (ins
      DXBC_DstOperandAttr:$dst0,
      DXBC_DstOperandAttr:$dst1,
      DXBC_SrcOperandAttr:$dst_address,
      DXBC_SrcOperandAttr:$src0,
      DXBC_SrcOperandAttr:$src1);
  let results = (outs);
  let assemblyFormat =
      "$dst0 `,` $dst1 `,` $dst_address `,` $src0 `,` $src1 attr-dict";
}

//===----------------------------------------------------------------------===//
// DXBC shared base for UnorderedAccessView (UAV) counter atomics
//===----------------------------------------------------------------------===//

class DXBC_ImmAtomicCounterOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_DstOperandAttr:$dst,
      DXBC_SrcOperandAttr:$uav);
  let results = (outs);
  let assemblyFormat = "$dst `,` $uav attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_alloc
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicAlloc : DXBC_ImmAtomicCounterOp<"imm_atomic_alloc"> {
  let summary =
      "atomic increment of an UnorderedAccessView (UAV) counter, returning the "
      "prior value";
  let description = [{
    The `dxbc.imm_atomic_alloc` operation atomically increments the hidden
    32-bit counter of the append or count UnorderedAccessView (UAV)
    `$uav` and writes the value the counter held before the increment
    into `$dst`.

    `$uav` must be a structured buffer UAV declared with a counter. The
    counter wraps on overflow.

    Example:

    ```mlir
    dxbc.imm_atomic_alloc r<0, <x>>, u<0>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.imm_atomic_consume
//===----------------------------------------------------------------------===//

def DXBC_ImmAtomicConsume : DXBC_ImmAtomicCounterOp<"imm_atomic_consume"> {
  let summary =
      "atomic decrement of an UnorderedAccessView (UAV) counter, returning the "
      "new value";
  let description = [{
    The `dxbc.imm_atomic_consume` operation atomically decrements the hidden
    32-bit counter of the append or count UnorderedAccessView (UAV)
    `$uav` and writes the new (post-decrement) value into `$dst`.

    `$uav` must be a structured buffer UAV declared with a counter. The
    counter wraps on underflow.

    Example:

    ```mlir
    dxbc.imm_atomic_consume r<0, <x>>, u<0>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCATOMICOPS
