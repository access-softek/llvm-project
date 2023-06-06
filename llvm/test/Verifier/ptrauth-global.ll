; RUN: not opt -S -passes=verify < %s 2>&1 | FileCheck %s

; CHECK: invalid llvm.ptrauth global: global doesn't have an initializer
@no_init = external global { ptr, i32, i64, i64 }, section "llvm.ptrauth"

; CHECK: invalid llvm.ptrauth global: global isn't a struct
@not_struct = constant ptr null, section "llvm.ptrauth"

; CHECK: invalid llvm.ptrauth global: global doesn't have type '{ ptr, i32, i64, i64 }'
@bad_type = constant { ptr, i32, i32, i32 } zeroinitializer, section "llvm.ptrauth"

; CHECK: invalid llvm.ptrauth global: key isn't a constant integer
@bad_key = constant { ptr, i32, i64, i64 } { ptr null, i32 ptrtoint (ptr @g to i32), i64 0, i64 0}, section "llvm.ptrauth"

; CHECK: invalid llvm.ptrauth global: discriminator isn't a constant integer
@bad_disc = constant { ptr, i32, i64, i64 } { ptr null, i32 0, i64 0, i64 ptrtoint (ptr @g to i64)}, section "llvm.ptrauth"

; CHECK-NOT: invalid
@valid = private constant { ptr, i32, i64, i64 } { ptr getelementptr inbounds (i8, ptr @g, i64 2), i32 3, i64 0, i64 0 }, section "llvm.ptrauth"

@g = external global i32
