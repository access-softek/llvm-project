//===- DXBCConditionOps.td - DXBC condition compute ops -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Condition computing instructions of the DXBC dialect. Each op compares
// two source operands component-wise and writes 0xFFFFFFFF to a component
// of the destination when the comparison is true, or 0 when it is false.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCCONDITIONOPS
#define MLIR_DIALECT_DXBC_IR_DXBCCONDITIONOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.eq
//===----------------------------------------------------------------------===//

def DXBC_Eq : DXBC_BinaryOp<"eq"> {
  let summary = "component-wise floating-point equality comparison";
  let description = [{
    The `dxbc.eq` operation compares `$lhs` and `$rhs` for floating-point
    equality component-wise, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.eq r<0>, r<1>, r<2>
    dxbc.eq r<0>, -r<1>, |r<2>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ge
//===----------------------------------------------------------------------===//

def DXBC_Ge : DXBC_BinaryOp<"ge"> {
  let summary = "component-wise floating-point greater-equal comparison";
  let description = [{
    The `dxbc.ge` operation computes the component-wise floating-point
    comparison `$lhs >= $rhs`, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ge r<0>, r<1>, r<2>
    dxbc.ge r<0>, -r<1>, |r<2>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.lt
//===----------------------------------------------------------------------===//

def DXBC_Lt : DXBC_BinaryOp<"lt"> {
  let summary = "component-wise floating-point less-than comparison";
  let description = [{
    The `dxbc.lt` operation computes the component-wise floating-point
    comparison `$lhs < $rhs`, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.lt r<0>, r<1>, r<2>
    dxbc.lt r<0>, -r<1>, |r<2>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ne
//===----------------------------------------------------------------------===//

def DXBC_Ne : DXBC_BinaryOp<"ne"> {
  let summary = "component-wise floating-point not-equal comparison";
  let description = [{
    The `dxbc.ne` operation compares `$lhs` and `$rhs` for floating-point
    inequality component-wise, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ne r<0>, r<1>, r<2>
    dxbc.ne r<0>, -r<1>, |r<2>|
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ieq
//===----------------------------------------------------------------------===//

def DXBC_Ieq : DXBC_BinaryOp<"ieq"> {
  let summary = "component-wise integer equality comparison";
  let description = [{
    The `dxbc.ieq` operation compares `$lhs` and `$rhs` for integer
    equality component-wise, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ieq r<0>, r<1>, r<2>
    dxbc.ieq r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ige
//===----------------------------------------------------------------------===//

def DXBC_Ige : DXBC_BinaryOp<"ige"> {
  let summary = "component-wise signed integer greater-equal comparison";
  let description = [{
    The `dxbc.ige` operation computes the component-wise signed integer
    comparison `$lhs >= $rhs`, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ige r<0>, r<1>, r<2>
    dxbc.ige r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ilt
//===----------------------------------------------------------------------===//

def DXBC_Ilt : DXBC_BinaryOp<"ilt"> {
  let summary = "component-wise signed integer less-than comparison";
  let description = [{
    The `dxbc.ilt` operation computes the component-wise signed integer
    comparison `$lhs < $rhs`, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ilt r<0>, r<1>, r<2>
    dxbc.ilt r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ine
//===----------------------------------------------------------------------===//

def DXBC_Ine : DXBC_BinaryOp<"ine"> {
  let summary = "component-wise integer not-equal comparison";
  let description = [{
    The `dxbc.ine` operation compares `$lhs` and `$rhs` for integer
    inequality component-wise, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ine r<0>, r<1>, r<2>
    dxbc.ine r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.uge
//===----------------------------------------------------------------------===//

def DXBC_Uge : DXBC_BinaryOp<"uge"> {
  let summary = "component-wise unsigned integer greater-equal comparison";
  let description = [{
    The `dxbc.uge` operation computes the component-wise unsigned integer
    comparison `$lhs >= $rhs`, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.uge r<0>, r<1>, r<2>
    dxbc.uge r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ult
//===----------------------------------------------------------------------===//

def DXBC_Ult : DXBC_BinaryOp<"ult"> {
  let summary = "component-wise unsigned integer less-than comparison";
  let description = [{
    The `dxbc.ult` operation computes the component-wise unsigned integer
    comparison `$lhs < $rhs`, writing 0xFFFFFFFF to a component of `$dst`
    when the result is true and 0 when it is false.

    Example:

    ```mlir
    dxbc.ult r<0>, r<1>, r<2>
    dxbc.ult r<0, <x>>, r<1, <y, z, w, y>>, r<2, <x, x, x, x>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCCONDITIONOPS
