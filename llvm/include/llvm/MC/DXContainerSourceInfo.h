//===- llvm/MC/DXContainerSourceInfo.h - DXContainer SourceInfo -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_DXCONTAINERSOURCEINFO_H
#define LLVM_MC_DXCONTAINERSOURCEINFO_H

#include "llvm/Object/DXContainer.h"

namespace llvm {

class raw_ostream;

namespace mcdxbc {


/// This data structure is a helper for reading and writing SourceInfo data.
/// It is implemented in the BinaryFormat library so that it can be used by both
/// the MC layer and Object tools.
/// This structure is used to represent the extracted data in an inspectable and
/// modifiable format, and can be used to serialize the data back into valid SourceInfo.
struct SourceInfo {
  bool IsFinalized = false;
  object::DirectX::SourceInfo BaseData;

  void write(raw_ostream &OS) const;
  void finalize();
};

} // namespace mcdxbc
} // namespace llvm

#endif // LLVM_MC_DXCONTAINERSOURCEINFO_H
