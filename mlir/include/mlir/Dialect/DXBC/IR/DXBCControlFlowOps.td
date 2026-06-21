//===- DXBCControlFlowOps.td - DXBC control flow ops ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Control flow instructions of the DXBC dialect. Each op takes no operands
// and marks a boundary of a loop, switch or conditional construct, or
// returns from the program.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCCONTROLFLOWOPS
#define MLIR_DIALECT_DXBC_IR_DXBCCONTROLFLOWOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.abort
//===----------------------------------------------------------------------===//

def DXBC_Abort : DXBC_NoOperandOp<"abort"> {
  let summary = "aborts shader execution";
  let description = [{
    The `dxbc.abort` operation terminates the current shader invocation
    unconditionally. No further instructions of the current invocation
    are executed and any side effects pending after this point are
    discarded.

    Example:

    ```mlir
    dxbc.abort
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.break
//===----------------------------------------------------------------------===//

def DXBC_Break : DXBC_NoOperandOp<"break"> {
  let summary = "exits the enclosing loop or switch";
  let description = [{
    The `dxbc.break` operation transfers execution to the instruction that
    follows the innermost enclosing loop or switch construct. It is valid
    only inside a loop or inside a case of a switch.

    Example:

    ```mlir
    dxbc.break
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.call
//===----------------------------------------------------------------------===//

def DXBC_Call : DXBC_Op<"call"> {
  let summary = "calls a subroutine identified by a label";
  let description = [{
    The `dxbc.call` operation transfers execution to the subroutine
    marked by `$operand`, a `label` reference. On `dxbc.ret` execution
    resumes at the instruction after this call.

    Example:

    ```mlir
    dxbc.call label<3>
    ```
  }];
  let arguments = (ins DXBC_SrcOperandAttr:$operand);
  let results = (outs);
  let assemblyFormat = "$operand attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.callc_z
//===----------------------------------------------------------------------===//

class DXBC_CallcOp<string mnemonic> : DXBC_Op<mnemonic> {
  let arguments = (ins
      DXBC_SrcOperandAttr:$cond,
      DXBC_SrcOperandAttr:$label);
  let results = (outs);
  let assemblyFormat = "$cond `,` $label attr-dict";
}

def DXBC_CallcZ : DXBC_CallcOp<"callc_z"> {
  let summary = "conditionally calls a subroutine when all condition bits are zero";
  let description = [{
    The `dxbc.callc_z` operation transfers execution to the subroutine
    marked by `$label` when every bit of the selected component of
    `$cond` is zero. Otherwise the call is skipped and execution falls
    through to the next instruction. On `dxbc.ret` execution resumes at
    the instruction after this call.

    Example:

    ```mlir
    dxbc.callc_z r<0, <x>>, label<3>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.callc_nz
//===----------------------------------------------------------------------===//

def DXBC_CallcNz : DXBC_CallcOp<"callc_nz"> {
  let summary = "conditionally calls a subroutine when any condition bit is nonzero";
  let description = [{
    The `dxbc.callc_nz` operation transfers execution to the subroutine
    marked by `$label` when any bit of the selected component of `$cond`
    is nonzero. Otherwise the call is skipped and execution falls
    through to the next instruction. On `dxbc.ret` execution resumes at
    the instruction after this call.

    Example:

    ```mlir
    dxbc.callc_nz r<0, <x>>, label<3>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.case
//===----------------------------------------------------------------------===//

def DXBC_Case : DXBC_Op<"case"> {
  let summary = "begins a case block of a switch";
  let description = [{
    The `dxbc.case` operation begins a case block of the enclosing
    switch construct whose label is the 32-bit immediate `$operand`.
    Multiple `dxbc.case` operations may precede the same block to make
    several values share one code path.

    Example:

    ```mlir
    dxbc.case l(0x2A)
    ```
  }];
  let arguments = (ins DXBC_SrcOperandAttr:$operand);
  let results = (outs);
  let assemblyFormat = "$operand attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.continue
//===----------------------------------------------------------------------===//

def DXBC_Continue : DXBC_NoOperandOp<"continue"> {
  let summary = "restarts the enclosing loop";
  let description = [{
    The `dxbc.continue` operation transfers execution back to the start of
    the innermost enclosing loop, beginning its next iteration. It is valid
    only inside a loop.

    Example:

    ```mlir
    dxbc.continue
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.debug_break
//===----------------------------------------------------------------------===//

def DXBC_DebugBreak : DXBC_NoOperandOp<"debug_break"> {
  let summary = "signals a breakpoint to an attached shader debugger";
  let description = [{
    The `dxbc.debug_break` operation signals a breakpoint to an attached
    shader debugger. With no debugger attached the operation has no
    observable effect on the shader.

    Example:

    ```mlir
    dxbc.debug_break
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.default
//===----------------------------------------------------------------------===//

def DXBC_Default : DXBC_NoOperandOp<"default"> {
  let summary = "begins the default block of a switch";
  let description = [{
    The `dxbc.default` operation begins the block of the enclosing switch
    construct that runs when no case matches, behaving like `default` in C.
    A switch construct may contain at most one default block.

    Example:

    ```mlir
    dxbc.default
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.else
//===----------------------------------------------------------------------===//

def DXBC_Else : DXBC_NoOperandOp<"else"> {
  let summary = "begins the else block of an if construct";
  let description = [{
    The `dxbc.else` operation begins the optional block of the enclosing if
    construct that runs when its condition is false. It is closed by the
    matching `dxbc.endif`.

    Example:

    ```mlir
    dxbc.else
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.endif
//===----------------------------------------------------------------------===//

def DXBC_Endif : DXBC_NoOperandOp<"endif"> {
  let summary = "closes an if construct";
  let description = [{
    The `dxbc.endif` operation closes the innermost enclosing if construct,
    including its optional `dxbc.else` block.

    Example:

    ```mlir
    dxbc.endif
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.endloop
//===----------------------------------------------------------------------===//

def DXBC_Endloop : DXBC_NoOperandOp<"endloop"> {
  let summary = "closes a loop construct";
  let description = [{
    The `dxbc.endloop` operation closes the innermost enclosing loop
    construct; reaching it transfers execution back to the matching
    `dxbc.loop` to begin the next iteration.

    Example:

    ```mlir
    dxbc.endloop
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.endswitch
//===----------------------------------------------------------------------===//

def DXBC_Endswitch : DXBC_NoOperandOp<"endswitch"> {
  let summary = "closes a switch construct";
  let description = [{
    The `dxbc.endswitch` operation closes the innermost enclosing switch
    construct.

    Example:

    ```mlir
    dxbc.endswitch
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.label
//===----------------------------------------------------------------------===//

def DXBC_Label : DXBC_Op<"label"> {
  let summary = "declares the entry point of a subroutine";
  let description = [{
    The `dxbc.label` operation declares the entry point of a subroutine
    identified by the `label` reference `$operand`. A matching
    `dxbc.call` or `dxbc.callc_z`/`dxbc.callc_nz` transfers execution to
    the instruction that follows.

    Example:

    ```mlir
    dxbc.label label<3>
    ```
  }];
  let arguments = (ins DXBC_DstOperandAttr:$operand);
  let results = (outs);
  let assemblyFormat = "$operand attr-dict";
}

//===----------------------------------------------------------------------===//
// dxbc.loop
//===----------------------------------------------------------------------===//

def DXBC_Loop : DXBC_NoOperandOp<"loop"> {
  let summary = "begins a loop construct";
  let description = [{
    The `dxbc.loop` operation begins a loop construct whose body repeats
    until a `dxbc.break` transfers execution past the matching
    `dxbc.endloop`.

    Example:

    ```mlir
    dxbc.loop
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.ret
//===----------------------------------------------------------------------===//

def DXBC_Ret : DXBC_NoOperandOp<"ret"> {
  let summary = "returns from a subroutine or terminates the shader";
  let description = [{
    The `dxbc.ret` operation returns to the instruction after the call when
    executed inside a subroutine, or terminates program execution otherwise.

    Example:

    ```mlir
    dxbc.ret
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCCONTROLFLOWOPS
