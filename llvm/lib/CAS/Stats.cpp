//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
///
/// 
//
//===----------------------------------------------------------------------===//

#include "llvm/CAS/Stats.h"
#include "llvm/Support/IOSandbox.h"
#include "llvm/Support/Path.h"

#if !defined(_MSC_VER) && !defined(__MINGW32__)
#include <unistd.h>
#else
#include <io.h>
// #define close(fd) _close(fd)
#endif

// std::atomic_ref and std::atomic<double>::fetch_add are available since C++20
#include <atomic> 

namespace llvm::cas {

static constexpr StringLiteral StatsName = "stats";

Error Stats::open(StringRef Path) {
  SmallString<256> FullPath(Path);
  sys::path::append(FullPath, StatsName);

  auto BypassSandbox = sys::sandbox::scopedDisable();

  if (auto EC = sys::fs::create_directory(Path))
    return createFileError(Path, EC);

  if (auto EC = sys::fs::openFileForReadWrite(
          FullPath, FD, sys::fs::CD_OpenAlways, sys::fs::OF_None))
    return createFileError(FullPath, EC);
    
  uint64_t Size = (uint64_t)(Key::last) * sizeof(uint64_t);

  if (auto EC = sys::fs::resize_file_before_mapping_readwrite(FD, Size))
    return createFileError(FullPath, EC);

  std::error_code EC;

  const char *Name = nullptr;
#ifdef _WIN32
  // Give the file mapping a name to ensure the same mappings are
  // shared across processes.
  std::replace(FullPath.begin(), FullPath.end(), '\\', '/');
  std::string MapName("Local\\");
  MapName += FullPath.c_str();
  Name = MapName.c_str();
#endif

  sys::fs::mapped_file_region M(sys::fs::convertFDToNativeFile(FD),
                                sys::fs::mapped_file_region::readwrite,
                                Size, 0, EC, Name);
  if (EC)
    return createFileError(FullPath, EC);

  Map = std::move(M);

  set(Key::version, Version);

  return Error::success();
}

void Stats::close() {
  if (Map) {
    Map.sync();
    Map.unmap();
  }
  if (FD != -1) {
    ::close(FD);
    FD = -1;
  }
}

// Assume the same endianness for reading and writing, as the stats file is only
// used on the same machine.

uint64_t Stats::get(Stats::Key K) {
  if (!key_valid(K))
    return 0;
  auto *AP = reinterpret_cast<std::atomic<uint64_t> *>(key2addr(K));
  return AP->load(std::memory_order_relaxed);
}

void Stats::set(Stats::Key K, uint64_t V) {
  if (!key_valid(K))
    return;
  auto *AP = reinterpret_cast<std::atomic<uint64_t> *>(key2addr(K));
  AP->store(V, std::memory_order_relaxed);
  Map.sync();
}

void Stats::inc(Stats::Key K, uint64_t V) {
  if (!key_valid(K))
    return;
  auto *AP = reinterpret_cast<std::atomic<uint64_t> *>(key2addr(K));
  AP->fetch_add(V, std::memory_order_relaxed);
  Map.sync();
}

double Stats::get_f(Key K) {
  if (!key_valid(K))
    return 0.0;
  auto *AP = reinterpret_cast<std::atomic<double> *>(key2addr(K));
  return AP->load(std::memory_order_relaxed);
}

void Stats::set_f(Key K, double V) {
  if (!key_valid(K))
    return;
  auto *AP = reinterpret_cast<std::atomic<double> *>(key2addr(K));
  AP->store(V, std::memory_order_relaxed);
  Map.sync();
}

// FIXME: Use std::atomic<double>::fetch_add for C++20 and later.

static double atomic_fetch_add_double(double *P, double V) {
  auto *AP = reinterpret_cast<std::atomic<uint64_t> *>(P);
  uint64_t OB;
  uint64_t NB;
  double OV;
  do {
    OB = AP->load(std::memory_order_relaxed);
    std::memcpy(&OV, &OB, sizeof(double));
    double NV = OV + V;
    std::memcpy(&NB, &NV, sizeof(uint64_t));
  } while (!AP->compare_exchange_weak(
      OB, NB, std::memory_order_seq_cst, std::memory_order_relaxed));
  return OV;
}

void Stats::inc_f(Key K, double V) {
  if (!key_valid(K))
    return;
  double *P = reinterpret_cast<double *>(key2addr(K));
  atomic_fetch_add_double(P, V);
  Map.sync();
}

} // namespace llvm::cas
