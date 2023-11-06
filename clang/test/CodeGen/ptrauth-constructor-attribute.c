// REQUIRES: aarch64-registered-target
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi                        -S -emit-llvm -o - -c %s | FileCheck --check-prefix=SIGNED %s
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi -fptrauth-init-fini    -S -emit-llvm -o - -c %s | FileCheck --check-prefix=SIGNED %s
// RUN: %clang -target aarch64-elf -march=armv8.3-a+pauth -mbranch-protection=pauthabi -fno-ptrauth-init-fini -S -emit-llvm -o - -c %s | FileCheck --check-prefix=UNSIGNED %s

// SIGNED: @foo.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @foo, i32 0, i64 0, i64 55764 }, section "llvm.ptrauth", align 8
// SIGNED: @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @foo.ptrauth, ptr null }]
// SIGNED: @bar.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @bar, i32 0, i64 0, i64 55764 }, section "llvm.ptrauth", align 8
// SIGNED: @llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @bar.ptrauth, ptr null }]

// UNSIGNED-NOT: @foo.ptrauth
// UNSIGNED:     @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @foo, ptr null }]
// UNSIGNED-NOT: @bar.ptrauth
// UNSIGNED:     @llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @bar, ptr null }]


volatile int x = 0;

__attribute__((constructor)) void foo(void) {
  x = 42;
}

__attribute__((destructor)) void bar(void) {
  x = 24;
}

int main() {
  return x;
}
