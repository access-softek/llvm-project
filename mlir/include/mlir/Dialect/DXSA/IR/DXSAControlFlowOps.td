//===- DXSAControlFlowOps.td - DXSA control flow ops ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Control flow instructions of the DXSA dialect. Each op takes no operands
// and marks a boundary of a loop, switch or conditional construct, or
// returns from the program.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXSA_IR_DXSACONTROLFLOWOPS
#define MLIR_DIALECT_DXSA_IR_DXSACONTROLFLOWOPS

include "mlir/Dialect/DXSA/IR/DXSAOpBase.td"

//===----------------------------------------------------------------------===//
// dxsa.break
//===----------------------------------------------------------------------===//

def DXSA_Break : DXSA_NullaryOp<"break", 0> {
  let summary = "exits the enclosing loop or switch";
  let description = [{
    The `dxsa.break` operation transfers execution to the instruction that
    follows the innermost enclosing loop or switch construct. It is valid
    only inside a loop or inside a case of a switch.

    Example:

    ```mlir
    dxsa.break
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.continue
//===----------------------------------------------------------------------===//

def DXSA_Continue : DXSA_NullaryOp<"continue", 0> {
  let summary = "restarts the enclosing loop";
  let description = [{
    The `dxsa.continue` operation transfers execution back to the start of
    the innermost enclosing loop, beginning its next iteration. It is valid
    only inside a loop.

    Example:

    ```mlir
    dxsa.continue
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.default
//===----------------------------------------------------------------------===//

def DXSA_Default : DXSA_NullaryOp<"default", 0> {
  let summary = "begins the default block of a switch";
  let description = [{
    The `dxsa.default` operation begins the block of the enclosing switch
    construct that runs when no case matches, behaving like `default` in C.
    A switch construct may contain at most one default block.

    Example:

    ```mlir
    dxsa.default
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.else
//===----------------------------------------------------------------------===//

def DXSA_Else : DXSA_NullaryOp<"else", 0> {
  let summary = "begins the else block of an if construct";
  let description = [{
    The `dxsa.else` operation begins the optional block of the enclosing if
    construct that runs when its condition is false. It is closed by the
    matching `dxsa.endif`.

    Example:

    ```mlir
    dxsa.else
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.endif
//===----------------------------------------------------------------------===//

def DXSA_Endif : DXSA_NullaryOp<"endif", 0> {
  let summary = "closes an if construct";
  let description = [{
    The `dxsa.endif` operation closes the innermost enclosing if construct,
    including its optional `dxsa.else` block.

    Example:

    ```mlir
    dxsa.endif
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.endloop
//===----------------------------------------------------------------------===//

def DXSA_Endloop : DXSA_NullaryOp<"endloop", 0> {
  let summary = "closes a loop construct";
  let description = [{
    The `dxsa.endloop` operation closes the innermost enclosing loop
    construct; reaching it transfers execution back to the matching
    `dxsa.loop` to begin the next iteration.

    Example:

    ```mlir
    dxsa.endloop
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.endswitch
//===----------------------------------------------------------------------===//

def DXSA_Endswitch : DXSA_NullaryOp<"endswitch", 0> {
  let summary = "closes a switch construct";
  let description = [{
    The `dxsa.endswitch` operation closes the innermost enclosing switch
    construct.

    Example:

    ```mlir
    dxsa.endswitch
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.loop
//===----------------------------------------------------------------------===//

def DXSA_Loop : DXSA_NullaryOp<"loop", 0> {
  let summary = "begins a loop construct";
  let description = [{
    The `dxsa.loop` operation begins a loop construct whose body repeats
    until a `dxsa.break` transfers execution past the matching
    `dxsa.endloop`.

    Example:

    ```mlir
    dxsa.loop
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxsa.ret
//===----------------------------------------------------------------------===//

def DXSA_Ret : DXSA_NullaryOp<"ret", 0> {
  let summary = "returns from a subroutine or terminates the shader";
  let description = [{
    The `dxsa.ret` operation returns to the instruction after the call when
    executed inside a subroutine, or terminates program execution otherwise.

    Example:

    ```mlir
    dxsa.ret
    ```
  }];
}

#endif // MLIR_DIALECT_DXSA_IR_DXSACONTROLFLOWOPS
