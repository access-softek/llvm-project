// RUN: %clang_cc1 -fms-kernel -triple x86_64-windows-msvc -O2 -emit-llvm %s -o - | FileCheck %s
// CHECK:      define {{.*}} i64 @sub_ptrs(ptr noundef %p1, ptr noundef %p2)
// CHECK-NEXT: entry:
// CHECK-NEXT:  %sub.ptr.lhs.cast = ptrtoint ptr %p1 to i64
// CHECK-NEXT:  %sub.ptr.rhs.cast = ptrtoint ptr %p2 to i64
// CHECK-NEXT:  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
// CHECK-NEXT:  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 4
// CHECK-NEXT:  ret i64 %sub.ptr.div

long long sub_ptrs(int* p1, int* p2) {
  return p1 - p2;
}

