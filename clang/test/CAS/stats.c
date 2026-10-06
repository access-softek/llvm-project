// REQUIRES: ondisk_cas
// REQUIRES: llvm-cas

// RUN: rm -rf %t && mkdir -p %t

// RUN: %llvm-cas --show-stats -cas %t/cas | FileCheck %s -check-prefix=NO-CACHE

// RUN: env LLVM_CACHE_CAS_PATH=%t/cas %clang-cache %clang -c %s -o %t/test.o -Xclang -Rcompile-job-cache
// RUN: %llvm-cas --show-stats -cas %t/cas | FileCheck %s -check-prefix=CACHE-MISS

// RUN: env LLVM_CACHE_CAS_PATH=%t/cas %clang-cache %clang -c %s -o %t/test.o -Xclang -Rcompile-job-cache
// RUN: %llvm-cas --show-stats -cas %t/cas | FileCheck %s -check-prefix=CACHE-HIT

// RUN: %llvm-cas --zero-stats -cas %t/cas | FileCheck %s -check-prefix=ZERO

// RUN: %llvm-cas --show-stats -cas %t/cas | FileCheck %s -check-prefix=AFTER-ZERO

// NO-CACHE: Cache hits:                      0
// NO-CACHE: Cache misses:                    0

// CACHE-MISS: Cache hits:                      0
// CACHE-MISS: Cache misses:                    1

// CACHE-HIT: Cache hits:                      1
// CACHE-HIT: Cache misses:                    1

// ZERO: zero-stats: successfull

// AFTER-ZERO: Cache hits:                      0
// AFTER-ZERO: Cache misses:                    0

int main() { return 0; }