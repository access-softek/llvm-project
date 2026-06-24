//===- DXBCTopologyOps.td - DXBC topology ops --------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Topology instructions of the DXBC dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DXBC_IR_DXBCTOPOLOGYOPS
#define MLIR_DIALECT_DXBC_IR_DXBCTOPOLOGYOPS

include "mlir/Dialect/DXBC/IR/DXBCOpBase.td"

//===----------------------------------------------------------------------===//
// dxbc.emit
//===----------------------------------------------------------------------===//

def DXBC_Emit : DXBC_NoOperandOp<"emit"> {
  let summary = "outputs a geometry-shader vertex from declared output registers";
  let description = [{
    The `dxbc.emit` operation reads every declared `o#` output register and
    outputs a vertex from the geometry shader. Each `dxbc.emit` produces one
    vertex; successive emits assemble primitives according to the output
    topology declared by `dxbc.dcl_output_topology`.

    A geometry shader may issue `dxbc.emit` any number of times, including
    inside flow control. If output streams have been declared with
    `dxbc.dcl_stream`, `dxbc.emit_stream` must be used instead.

    Example:

    ```mlir
    dxbc.emit
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.cut
//===----------------------------------------------------------------------===//

def DXBC_Cut : DXBC_NoOperandOp<"cut"> {
  let summary = "ends the current geometry-shader output strip";
  let description = [{
    The `dxbc.cut` operation ends the current output strip at the last emitted
    vertex, so the next `dxbc.emit` begins a new strip. This only affects
    linestrip and trianglestrip output topologies; for pointlist output,
    `dxbc.cut` has no effect.

    A geometry shader may issue `dxbc.cut` any number of times, including
    inside flow control. If output streams have been declared with
    `dxbc.dcl_stream`, `dxbc.cut_stream` must be used instead.

    Example:

    ```mlir
    dxbc.cut
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.emit_then_cut
//===----------------------------------------------------------------------===//

def DXBC_EmitThenCut : DXBC_NoOperandOp<"emit_then_cut"> {
  let summary = "outputs a geometry-shader vertex and ends the current strip";
  let description = [{
    The `dxbc.emit_then_cut` operation has the same effect as `dxbc.emit`,
    immediately followed by `dxbc.cut`.

    A geometry shader may issue `dxbc.emit_then_cut` any number of times,
    including inside flow control. If output streams have been declared with
    `dxbc.dcl_stream`, `dxbc.emit_then_cut_stream` must be used instead.

    Example:

    ```mlir
    dxbc.emit_then_cut
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.emit_stream
//===----------------------------------------------------------------------===//

def DXBC_EmitStream : DXBC_GsStreamIndexOp<"emit_stream"> {
  let summary = "outputs a geometry-shader vertex on an output stream";
  let description = [{
    The `dxbc.emit_stream` operation reads every declared `o#` output register
    for stream `$index` and outputs a vertex on that geometry-shader output
    stream. Each `dxbc.emit_stream` produces one vertex; successive emits on
    the same stream assemble primitives according to the output topology
    declared for that stream.

    The `$index` must be in the range [0, 3].

    Example:

    ```mlir
    dxbc.emit_stream 0
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.cut_stream
//===----------------------------------------------------------------------===//

def DXBC_CutStream : DXBC_GsStreamIndexOp<"cut_stream"> {
  let summary = "ends the current strip on a geometry-shader output stream";
  let description = [{
    The `dxbc.cut_stream` operation ends the current output strip at the last
    emitted vertex on stream `$index`, so the next emit on that stream begins a
    new strip. This has the same semantics as `dxbc.cut`, scoped to the given
    output stream.

    The `$index` must be in the range [0, 3].

    Example:

    ```mlir
    dxbc.cut_stream 0
    ```
  }];
}

//===----------------------------------------------------------------------===//
// dxbc.emit_then_cut_stream
//===----------------------------------------------------------------------===//

def DXBC_EmitThenCutStream : DXBC_GsStreamIndexOp<"emit_then_cut_stream"> {
  let summary = "outputs a vertex on a stream and ends the current strip";
  let description = [{
    The `dxbc.emit_then_cut_stream` operation has the same effect as
    `dxbc.emit_stream`, immediately followed by `dxbc.cut_stream`, on stream
    `$index`.

    The `$index` must be in the range [0, 3].

    Example:

    ```mlir
    dxbc.emit_then_cut_stream 0
    ```
  }];
}

#endif // MLIR_DIALECT_DXBC_IR_DXBCTOPOLOGYOPS
