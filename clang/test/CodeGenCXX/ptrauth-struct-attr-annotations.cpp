// RUN: %clang_cc1 -triple aarch64 -emit-llvm -debug-info-kind=limited -o - %s | FileCheck %s

#include <ptrauth.h>

struct __attribute__((ptrauth_struct(1, 42))) S0 {};

template <int k>
class [[clang::ptrauth_struct(k, 65534)]] S1 {};

union __attribute__((ptrauth_struct(__builtin_ptrauth_struct_key(S0) + 1, __builtin_ptrauth_struct_disc(S0) + 1))) S2 {};

S0 s0;
S1<3> s1;
S2 s2;

// CHECK:      !DICompositeType(tag: DW_TAG_class_type, name: "S1<3>",
// CHECK-SAME: annotations: ![[A1:.*]])
// CHECK:      ![[A1]] = !{![[A1K:.*]], ![[A1D:.*]]}
// CHECK:      ![[A1K]] = !{!"ptrauth_struct_key", i2 -1}
// CHECK:      ![[A1D]] = !{!"ptrauth_struct_disc", i16 -2}

// CHECK:      !DICompositeType(tag: DW_TAG_union_type, name: "S2",
// CHECK-SAME: annotations: ![[A2:.*]])
// CHECK:      ![[A2]] = !{![[A2K:.*]], ![[A2D:.*]]}
// CHECK:      ![[A2K]] = !{!"ptrauth_struct_key", i2 -2}
// CHECK:      ![[A2D]] = !{!"ptrauth_struct_disc", i16 43}

// CHECK:      !DICompositeType(tag: DW_TAG_structure_type, name: "S0",
// CHECK-SAME: annotations: ![[A0:.*]])
// CHECK:      ![[A0]] = !{![[A0K:.*]], ![[A0D:.*]]}
// CHECK:      ![[A0K]] = !{!"ptrauth_struct_key", i2 1}
// CHECK:      ![[A0D]] = !{!"ptrauth_struct_disc", i16 42}
