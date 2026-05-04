// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -fms-kernel -triple x86_64-windows-msvc -O2 -emit-llvm %s -o - | FileCheck %s
// CHECK:      define {{.*}} i32 @add2(i32 noundef %a, i32 noundef %b)
// CHECK-NEXT: entry:
// CHECK-NEXT:  %add = add i32 %b, %a
// CHECK-NEXT:  ret i32 %add

// CHECK:      define {{.*}} i32 @mul2(i32 noundef %a)
// CHECK-NEXT: entry:
// CHECK-NEXT:  %mul = shl i32 %a, 1
// CHECK-NEXT:  ret i32 %mul

// CHECK:      define {{.*}} ptr @add_ptr(ptr noundef {{.*}} %base, i64 noundef %off)
// CHECK-NEXT: entry:
// CHECK-NEXT:  %add.ptr = getelementptr i8, ptr %base, i64 %off
// CHECK-NEXT:  ret ptr %add.ptr

int add2(int a, int b) {
  return a + b;
}

int mul2(int a) {
  return a*=2;
}

char* add_ptr(char* base, long long off) {
  return base + off;
}
