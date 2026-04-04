//===- llvm/MC/DXContainerInfo.cpp - DXContainer Info -----*- C++ -------*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallString.h"
#include "llvm/BinaryFormat/DXContainer.h"
#include "llvm/MC/DXContainerSourceInfo.h"
#include "llvm/Support/Compression.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/SwapByteOrder.h"
#include <type_traits>

using namespace llvm;
using namespace llvm::mcdxbc;

constexpr static uint64_t DXCONTAINER_STRUCT_ALIGNMENT = 4;

template <typename StructT>
static void writeStruct(raw_ostream &OS, StructT S) {
  static_assert(std::is_class<StructT>() &&
                "This method must be used for writing structure types.");
  if (sys::IsBigEndianHost)
    S.swapBytes();
  OS.write(reinterpret_cast<const char *>(&S), sizeof(StructT));
}

static void writeString(raw_ostream &OS, StringRef S) {
  OS.write(S.data(), S.size());
  // Write null terminator.
  OS.write_zeros(1);
}

static void writePadding(raw_ostream &OS, uint64_t Prev) {
  uint64_t UnpaddedSize = OS.tell() - Prev;
  uint64_t Remainder = UnpaddedSize % DXCONTAINER_STRUCT_ALIGNMENT;
  if (Remainder)
    OS.write_zeros(DXCONTAINER_STRUCT_ALIGNMENT - Remainder);
}

void SourceInfo::finalize() {
  IsFinalized = true;

  // Compress Contents right now, to calculate compressed size.
  CompressedContents.clear();
  SmallString<256> Data;
  {
    raw_svector_ostream OS(Data);
    for (auto &E : BaseData.Contents.Entries) {
      uint64_t EntryOffset = OS.tell();
      writeStruct(OS, E.Parameters);
      writeString(OS, E.FileContent);
      writePadding(OS, EntryOffset);
    }
    writePadding(OS, 0);
  }
  switch (BaseData.Contents.Parameters.Type) {
  case dxbc::SourceInfo::Contents::CompressionType::Zlib: {
    if (!compression::zlib::isAvailable())
      reportFatalUsageError(Twine("DXContainer SRCI Contents should be "
                                  "compressed with Zlib, but ") +
                            Twine(compression::getReasonIfUnsupported(
                                compression::Format::Zlib)));

    SmallVector<uint8_t, 128> CompressedData;
    compression::zlib::compress(
        ArrayRef(reinterpret_cast<uint8_t *>(Data.data()), Data.size()),
        CompressedData, compression::zlib::BestSizeCompression);
    raw_svector_ostream OS(CompressedContents);
    OS.write(reinterpret_cast<char *>(CompressedData.data()),
             CompressedData.size());
    break;
  }
  case dxbc::SourceInfo::Contents::CompressionType::None: {
    CompressedContents = std::move(Data);
    break;
  }
  }
  if (BaseData.Contents.Parameters.EntriesSizeInBytes !=
      CompressedContents.size())
    reportFatalUsageError(
        formatv("DXContainer SRCI Contents compressed size in header ({0}) "
                "doesn't match the actual compressed size ({1})",
                BaseData.Contents.Parameters.EntriesSizeInBytes,
                CompressedContents.size()));
}

void SourceInfo::write(raw_ostream &OS) const {
  assert(IsFinalized &&
         "SourceInfo::finalize must be called before SourceInfo::write");

  writeStruct(OS, BaseData.Parameters);

  // Write Names section.
  {
    auto &Names = BaseData.Names;
    uint64_t NamesOffset = OS.tell();
    writeStruct(OS, Names.GenericHeader);
    support::endian::write(OS, Names.Parameters.Flags, endianness::little);
    support::endian::write(OS, Names.Parameters.Count, endianness::little);
    support::endian::write(OS, Names.Parameters.EntriesSizeInBytes,
                           endianness::little);
    for (auto &E : Names.Entries) {
      uint64_t EntryOffset = OS.tell();
      writeStruct(OS, E.Parameters);
      writeString(OS, E.FileName);
      writePadding(OS, EntryOffset);
    }
    writePadding(OS, NamesOffset);
  }

  // Write Contents section.
  {
    auto &Contents = BaseData.Contents;
    uint64_t ContentsOffset = OS.tell();
    writeStruct(OS, Contents.GenericHeader);
    writeStruct(OS, Contents.Parameters);
    OS.write(CompressedContents.data(), CompressedContents.size());
    writePadding(OS, ContentsOffset);
  }

  // Write Args section.
  {
    auto &Args = BaseData.Args;
    uint64_t ArgsOffset = OS.tell();
    writeStruct(OS, Args.GenericHeader);
    writeStruct(OS, Args.Parameters);
    for (auto &E : Args.Args) {
      writeString(OS, E.first);
      writeString(OS, E.second);
    }
    writePadding(OS, ArgsOffset);
  }
}
