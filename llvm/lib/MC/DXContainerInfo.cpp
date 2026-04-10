//===- llvm/MC/DXContainerInfo.cpp - DXContainer Info -----*- C++ -------*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/DXContainerSourceInfo.h"
#include "llvm/BinaryFormat/DXContainer.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"
#include <type_traits>

using namespace llvm;
using namespace llvm::mcdxbc;

void SourceInfo::finalize() {
  IsFinalized = true;

  if (!sys::IsBigEndianHost)
    return;

  BaseData.Parameters.swapBytes();
  BaseData.Names.GenericHeader.swapBytes();
  for (auto &E : BaseData.Names.Entries)
    E.Parameters.swapBytes();
  BaseData.Contents.GenericHeader.swapBytes();
  BaseData.Contents.Parameters.swapBytes();
  for (auto &E : BaseData.Contents.Entries)
    E.Parameters.swapBytes();
  BaseData.Args.GenericHeader.swapBytes();
  BaseData.Args.Parameters.swapBytes();
}

template <typename StructT>
static void writeStruct(raw_ostream &OS, const StructT &S) {
  static_assert(std::is_class<StructT>() && "This method must be used for writing structure types.");
  OS.write(reinterpret_cast<const char*>(&S), sizeof(StructT));
}

void SourceInfo::write(raw_ostream &OS) const {
  assert(IsFinalized && "SourceInfo::finalize must be called before SourceInfo::write");

  writeStruct(OS, BaseData.Parameters);

  auto &Names = BaseData.Names;
  writeStruct(OS, Names.GenericHeader);
  dxbc::HeaderOnDisk NamesHeader = { Names.Parameters.Flags, Names.Parameters.Count, Names.Parameters.EntriesSizeInBytes };
  // TODO swap bytes
  writeStruct(OS, NamesHeader);
  // OS.write(reinterpret_cast<const char *>(&Names.GenericHeader), sizeof
  // TODO
}
