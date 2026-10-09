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
//===----------------------------------------------------------------------===//

#ifndef LLVM_CAS_STATS_H
#define LLVM_CAS_STATS_H

#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/FileSystem.h"

namespace llvm::cas {

class Stats {
public:
  static const uint64_t Version = 1;

  enum class Key : uint16_t {
    version = 0,
    hit = 1,
    miss = 2,
    miss_result_not_found = 3,
    backend_output_not_found = 4,
    skipped = 5,
    depscan_time = 6,
    depscan_count = 7,
    backend_key_query_time = 8,
    backend_key_query_count = 9,
    backend_key_update_time = 10,
    backend_key_update_count = 11,
    backend_load_time = 12,
    backend_load_count = 13,
    backend_store_time = 14,
    backend_store_count = 15,
    last = 16,
  };

  Stats() : FD(-1) {};
  Stats(Stats &&Other) : Map(std::move(Other.Map)), FD(Other.FD) {
    Other.FD = -1;
  };
  ~Stats() { close(); }

  Error open(StringRef Path);
  void close();

  uint64_t get(Key K);
  void set(Key K, uint64_t V);
  void inc(Key K, uint64_t V = 1);
  
  double get_f(Key K);
  void set_f(Key K, double V);
  void inc_f(Key K, double V);

private:
  bool key_valid(Key K) { return (Map && K < Key::last); }
  void *key2addr(Key K) {
    return reinterpret_cast<void *>(Map.data() + (uint64_t)K * sizeof(uint64_t));
  }
  int FD;
  sys::fs::mapped_file_region Map;
};

} // namespace llvm::cas

#endif // LLVM_CAS_STATS_H
