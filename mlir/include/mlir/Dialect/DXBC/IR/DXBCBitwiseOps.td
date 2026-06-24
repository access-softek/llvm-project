//===- DXBCBitwiseOps.td - DXBC bitwise ops -------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Bitwise instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS
#define MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.and
//===----------------------------------------------------------------------===//

def DXBC_And : DXBC_BinaryOp<"and"> {
  let summary = "component-wise logical AND";
  let description = [{
    The `dxbc.and` operation computes the component-wise logical AND of
    each pair of 32-bit values, `$dst = $lhs & $rhs`.

    Example:

    ```mlir
    dxbc.and r<0>, r<1>, r<2>
    dxbc.and r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.bfrev
//===----------------------------------------------------------------------===//

def DXBC_BFRev : DXBC_UnaryOp<"bfrev"> {
  let summary = "reverse the bits in a number";
  let description = [{
    The `dxbc.bfrev` operation reverses the bits in each 32-bit value in
    $src, `$dst = bitreverse($src)`.

    Example:

    ```mlir
    dxbc.bfrev o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.countbits
//===----------------------------------------------------------------------===//

def DXBC_CountBits : DXBC_UnaryOp<"countbits"> {
  let summary = "count the number of bits set in a number";
  let description = [{
    The `dxbc.countbits` operation counts the number of bits set in
    each 32-bit value in $src, `$dst = ctpop($src)`.

    Example:

    ```mlir
    dxbc.countbits o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.firstbit_hi
//===----------------------------------------------------------------------===//

def DXBC_FirstBitHi : DXBC_UnaryOp<"firstbit_hi"> {
  let summary = "find the first bit set in a number from the MSB";
  let description = [{
    The `dxbc.firstbit_hi` operation finds the first bit set in each 32-bit
    value in $src from the MSB, `$dst = 31 - ctlz($src)`.

    Example:

    ```mlir
    dxbc.firstbit_hi o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.firstbit_lo
//===----------------------------------------------------------------------===//

def DXBC_FirstBitLo : DXBC_UnaryOp<"firstbit_lo"> {
  let summary = "find the first bit set in a number from the LSB";
  let description = [{
    The `dxbc.firstbit_lo` operation finds the first bit set in each 32-bit
    value in $src from the LSB, `$dst = $src ? cttz($src) : -1`.

    Example:

    ```mlir
    dxbc.firstbit_lo o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.firstbit_shi
//===----------------------------------------------------------------------===//

def DXBC_FirstBitSHi : DXBC_UnaryOp<"firstbit_shi"> {
  let summary = "find the first different bit in a number from the MSB";
  let description = [{
    The `dxbc.firstbit_shi` operation finds the first bit in each 32-bit
    value in $src from the MSB that differs from the MSB,
    `$dst = 31 - ctlz($src ^ ($src >> 31))`.

    Example:

    ```mlir
    dxbc.firstbit_shi o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ibfe
//===----------------------------------------------------------------------===//

def DXBC_IBFE : DXBC_TernaryOp<"ibfe"> {
  let summary = "signed bit field extract";
  let description = [{
    The `dxbc.ibfe` operation takes a range of bits of a number, shifts
    those bits to the LSB, and fills the remaining bits with the MSB of
    the range.

    Example:

    ```mlir
    dxbc.ibfe r<0, min16i, <x>>, l(0x1B), l(0x5), cb<[0, 0], vector, min16i, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ishl
//===----------------------------------------------------------------------===//

def DXBC_IShl : DXBC_BinaryOp<"ishl"> {
  let summary = "component-wise shift left";
  let description = [{
    The `dxbc.ishl` operation computes the component-wise shift of
    each 32-bit value in $lhs left by $rhs, `$dst = $lhs << $rhs`.

    Example:

    ```mlir
    dxbc.ishl r<0>, r<1>, r<2>
    dxbc.ishl r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ishr
//===----------------------------------------------------------------------===//

def DXBC_IShr : DXBC_BinaryOp<"ishr"> {
  let summary = "component-wise arithmetic shift right";
  let description = [{
    The `dxbc.ishr` operation computes the component-wise arithmetic
    shift of each 32-bit value in $lhs right by $rhs,
    `$dst = $lhs >> $rhs`.

    Example:

    ```mlir
    dxbc.ishr r<0>, r<1>, r<2>
    dxbc.ishr r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.not
//===----------------------------------------------------------------------===//

def DXBC_Not : DXBC_UnaryOp<"not"> {
  let summary = "component-wise one's complement";
  let description = [{
    The `dxbc.not` operation performs a component-wise one's complement of
    each 32-bit value in $src, `$dst = ~$src`.

    Example:

    ```mlir
    dxbc.not o<0>, v<0, <y, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.or
//===----------------------------------------------------------------------===//

def DXBC_Or : DXBC_BinaryOp<"or"> {
  let summary = "component-wise logical OR";
  let description = [{
    The `dxbc.or` operation computes the component-wise logical OR of
    each pair of 32-bit values, `$dst = $lhs | $rhs`.

    Example:

    ```mlir
    dxbc.or r<0>, r<1>, r<2>
    dxbc.or r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ubfe
//===----------------------------------------------------------------------===//

def DXBC_UBFE : DXBC_TernaryOp<"ubfe"> {
  let summary = "unsigned bit field extract";
  let description = [{
    The `dxbc.ubfe` operation takes a range of bits of a number, shifts
    those bits to the LSB, and sets the remaining bits to 0.

    Example:

    ```mlir
    dxbc.ubfe r<0, min16u, <x>>, l(0x1B), l(0x5), cb<[0, 0], vector, min16u, <x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ushr
//===----------------------------------------------------------------------===//

def DXBC_UShr : DXBC_BinaryOp<"ushr"> {
  let summary = "component-wise logical shift right";
  let description = [{
    The `dxbc.ushr` operation computes the component-wise logical shift
    of each 32-bit value in $lhs right by $rhs,
    `$dst = $lhs >> $rhs`.

    Example:

    ```mlir
    dxbc.ushr r<0>, r<1>, r<2>
    dxbc.ushr r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.xor
//===----------------------------------------------------------------------===//

def DXBC_Xor : DXBC_BinaryOp<"xor"> {
  let summary = "component-wise logical XOR";
  let description = [{
    The `dxbc.xor` operation computes the component-wise logical XOR of
    each pair of 32-bit values, `$dst = $lhs ^ $rhs`.

    Example:

    ```mlir
    dxbc.xor r<0>, r<1>, r<2>
    dxbc.xor r<0, <x, y>>, r<1, <y, z, x, w>>, r<2, <z, z, z, z>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCBITWISEOPS
