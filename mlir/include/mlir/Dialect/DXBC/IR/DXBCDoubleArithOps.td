//===- DXBCDoubleArithOps.td - DXBC double arithmetic ops -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Double-precision arithmetic instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCDOUBLEARITHOPS
#define MLIR_DIALECT_DXBC_IR_DXBCDOUBLEARITHOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.dadd
//===----------------------------------------------------------------------===//

def DXBC_DAdd : DXBC_BinaryOp<"dadd"> {
  let summary = "component-wise double-precision add";
  let description = [{
    The `dxbc.dadd` operation computes the component-wise double-precision
    sum `$dst = $lhs + $rhs`. Each operand holds a vector of doubles, one
    double per `xy` and `zw` component pair.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dadd r<0>, r<1>, r<2>
    dxbc.dadd r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dadd_sat
//===----------------------------------------------------------------------===//

def DXBC_DAddSat : DXBC_BinaryOp<"dadd_sat"> {
  let summary = "component-wise double-precision add, saturated to [0, 1]";
  let description = [{
    The `dxbc.dadd_sat` operation computes the component-wise double-precision
    sum of `$lhs` and `$rhs`, clamps each result component to `[0.0, 1.0]`,
    and writes it to `$dst`.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dadd_sat r<0>, r<1>, r<2>
    dxbc.dadd_sat r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ddiv
//===----------------------------------------------------------------------===//

def DXBC_DDiv : DXBC_BinaryOp<"ddiv"> {
  let summary = "component-wise double-precision divide";
  let description = [{
    The `dxbc.ddiv` operation computes the component-wise double-precision
    quotient `$dst = $lhs / $rhs`. Each operand holds a vector of doubles, one
    double per `xy` and `zw` component pair.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.ddiv r<0>, r<1>, r<2>
    dxbc.ddiv r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ddiv_sat
//===----------------------------------------------------------------------===//

def DXBC_DDivSat : DXBC_BinaryOp<"ddiv_sat"> {
  let summary = "component-wise double-precision divide, saturated to [0, 1]";
  let description = [{
    The `dxbc.ddiv_sat` operation computes the component-wise double-precision
    quotient of `$lhs` and `$rhs`, clamps each result component to
    `[0.0, 1.0]`, and writes it to `$dst`.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.ddiv_sat r<0>, r<1>, r<2>
    dxbc.ddiv_sat r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmax
//===----------------------------------------------------------------------===//

def DXBC_DMax : DXBC_BinaryOp<"dmax"> {
  let summary = "component-wise double-precision maximum";
  let description = [{
    The `dxbc.dmax` operation computes the component-wise double-precision
    maximum `$dst = $lhs >= $rhs ? $lhs : $rhs`. If one source component is
    NaN, the other source component is returned.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dmax r<0>, r<1>, r<2>
    dxbc.dmax r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmax_sat
//===----------------------------------------------------------------------===//

def DXBC_DMaxSat : DXBC_BinaryOp<"dmax_sat"> {
  let summary = "component-wise double-precision maximum, saturated to [0, 1]";
  let description = [{
    The `dxbc.dmax_sat` operation computes the component-wise double-precision
    maximum of `$lhs` and `$rhs`, clamps each result component to `[0.0, 1.0]`,
    and writes it to `$dst`. If one source component is NaN, the other source
    component is used.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dmax_sat r<0>, r<1>, r<2>
    dxbc.dmax_sat r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmin
//===----------------------------------------------------------------------===//

def DXBC_DMin : DXBC_BinaryOp<"dmin"> {
  let summary = "component-wise double-precision minimum";
  let description = [{
    The `dxbc.dmin` operation computes the component-wise double-precision
    minimum `$dst = $lhs < $rhs ? $lhs : $rhs`. If one source component is
    NaN, the other source component is returned.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dmin r<0>, r<1>, r<2>
    dxbc.dmin r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmin_sat
//===----------------------------------------------------------------------===//

def DXBC_DMinSat : DXBC_BinaryOp<"dmin_sat"> {
  let summary = "component-wise double-precision minimum, saturated to [0, 1]";
  let description = [{
    The `dxbc.dmin_sat` operation computes the component-wise double-precision
    minimum of `$lhs` and `$rhs`, clamps each result component to `[0.0, 1.0]`,
    and writes it to `$dst`. If one source component is NaN, the other source
    component is used.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dmin_sat r<0>, r<1>, r<2>
    dxbc.dmin_sat r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmul
//===----------------------------------------------------------------------===//

def DXBC_DMul : DXBC_BinaryOp<"dmul"> {
  let summary = "component-wise double-precision multiply";
  let description = [{
    The `dxbc.dmul` operation computes the component-wise double-precision
    product `$dst = $lhs * $rhs`. Each operand holds a vector of doubles, one
    double per `xy` and `zw` component pair.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dmul r<0>, r<1>, r<2>
    dxbc.dmul r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.dmul_sat
//===----------------------------------------------------------------------===//

def DXBC_DMulSat : DXBC_BinaryOp<"dmul_sat"> {
  let summary = "component-wise double-precision multiply, saturated to [0, 1]";
  let description = [{
    The `dxbc.dmul_sat` operation computes the component-wise double-precision
    product of `$lhs` and `$rhs`, clamps each result component to `[0.0, 1.0]`,
    and writes it to `$dst`.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and each source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.dmul_sat r<0>, r<1>, r<2>
    dxbc.dmul_sat r<0, <x, y>>, r<1, <z, w, x, y>>, -r<2>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.drcp
//===----------------------------------------------------------------------===//

def DXBC_DRcp : DXBC_UnaryOp<"drcp"> {
  let summary = "component-wise double-precision reciprocal";
  let description = [{
    The `dxbc.drcp` operation computes the component-wise double-precision
    reciprocal `$dst = 1.0 / $src`. Each operand holds a vector of doubles, one
    double per `xy` and `zw` component pair.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and the source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.drcp r<0>, r<1>
    dxbc.drcp r<0, <x, y>>, -r<1, <z, w, x, y>>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.drcp_sat
//===----------------------------------------------------------------------===//

def DXBC_DRcpSat : DXBC_UnaryOp<"drcp_sat"> {
  let summary = "component-wise double-precision reciprocal, saturated to [0, 1]";
  let description = [{
    The `dxbc.drcp_sat` operation computes the component-wise double-precision
    reciprocal of `$src`, clamps each result component to `[0.0, 1.0]`, and
    writes it to `$dst`.

    Because each double spans a component pair, the destination write mask must
    be `<x, y>`, `<z, w>`, or `<x, y, z, w>`, and the source swizzle must be
    one of `<x, y, z, w>`, `<x, y, x, y>`, `<z, w, x, y>`, or `<z, w, z, w>`.

    Example:

    ```mlir
    dxbc.drcp_sat r<0>, r<1>
    dxbc.drcp_sat r<0, <x, y>>, -r<1, <z, w, x, y>>
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCDOUBLEARITHOPS
