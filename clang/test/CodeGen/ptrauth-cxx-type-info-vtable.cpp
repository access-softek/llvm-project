// REQUIRES: aarch64-registered-target
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi -fptrauth-cxx-type-info-vtable-discrimination=zero   -S -emit-llvm -o - -c %s | FileCheck --check-prefix=ZERO %s
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi -fptrauth-cxx-type-info-vtable-discrimination=type   -S -emit-llvm -o - -c %s | FileCheck --check-prefix=TYPE %s
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi -fptrauth-cxx-type-info-vtable-discrimination=libcxx -S -emit-llvm -o - -c %s | FileCheck --check-prefix=LIBCXX %s
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi                                                      -S -emit-llvm -o - -c %s | FileCheck --check-prefix=LIBCXX %s

// ZERO: @_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global [0 x ptr]
// ZERO: @_ZTVN10__cxxabiv117__class_type_infoE.ptrauth = private constant { ptr, i32, i64, i64 } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), i32 2, i64 ptrtoint (ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i64), i64 0 }, section "llvm.ptrauth", align 8

// TYPE: @_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global [0 x ptr]
// TYPE: @_ZTVN10__cxxabiv117__class_type_infoE.ptrauth = private constant { ptr, i32, i64, i64 } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), i32 2, i64 ptrtoint (ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i64), i64 10314 }, section "llvm.ptrauth", align 8

// LIBCXX: @_ZTVN10__cxxabiv117__class_type_infoE = external dso_local global [0 x ptr]
// LIBCXX: @_ZTVN10__cxxabiv117__class_type_infoE.ptrauth = private constant { ptr, i32, i64, i64 } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), i32 2, i64 ptrtoint (ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i64), i64 45546 }, section "llvm.ptrauth", align 8

struct A {};

void foo() {
  throw A();
}

int main() {
  try {
    foo();
  } catch (const A&) {
    return 1;
  }
  return 0;
}
