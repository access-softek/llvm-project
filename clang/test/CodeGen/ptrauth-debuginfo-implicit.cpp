// RUN: split-file %s %t && cd %t

//--- vtptr.cpp

// RUN: %clang -g -target aarch64-elf -mbranch-protection=pauthabi \
// RUN:   -S -emit-llvm vtptr.cpp -o - | FileCheck vtptr.cpp

// CHECK:      !DIDerivedType(tag: DW_TAG_member
// CHECK-SAME: name: "_vptr$A"
// CHECK-SAME: baseType: [[BASE1:![0-9]+]]

// CHECK:      [[BASE1]] = !DIDerivedType(tag: DW_TAG_LLVM_ptrauth_type
// CHECK-SAME: baseType: [[BASE2:![0-9]+]]
// CHECK-SAME: ptrAuthKey: 2
// CHECK-SAME: ptrAuthIsAddressDiscriminated: true
// CHECK-SAME: ptrAuthExtraDiscriminator: 62866
// CHECK-SAME: ptrAuthIsaPointer: false
// CHECK-SAME: ptrAuthAuthenticatesNullValues: false

// CHECK:      [[BASE2]] = !DIDerivedType(tag: DW_TAG_pointer_type
// CHECK-SAME: baseType: [[BASE3:![0-9]+]]

// CHECK:      [[BASE3]] = !DIDerivedType(tag: DW_TAG_pointer_type
// CHECK-SAME: name: "__vtbl_ptr_type"
// CHECK-SAME: baseType: [[BASE4:![0-9]+]]

// CHECK:      [[BASE4]] = !DISubroutineType

struct A {
  virtual void foo() {};
};

void bar(A& a) {
  a.foo();
}

void test() {
  A a;
  bar(a);
}

//--- fptr.c

// RUN: %clang -g -target aarch64-elf -mbranch-protection=pauthabi \
// RUN:   -S -emit-llvm fptr.c -o - | FileCheck fptr.c

// CHECK:      !DIGlobalVariable(name: "y"
// CHECK-SAME: type: [[TYPE:![0-9]+]]

/* IA key and zero extra discriminator are not emitted in IR metadata nodes
 * but are still present in Dwarf output generated. */

// CHECK:      [[TYPE]] = !DIDerivedType(tag: DW_TAG_LLVM_ptrauth_type
// CHECK-SAME: baseType: [[BASE1:![0-9]+]]
// CHECK-SAME: ptrAuthIsAddressDiscriminated: false
// CHECK-SAME: ptrAuthIsaPointer: false
// CHECK-SAME: ptrAuthAuthenticatesNullValues: false

// CHECK:      [[BASE1]] = !DIDerivedType(tag: DW_TAG_pointer_type
// CHECK-SAME: baseType: [[BASE2:![0-9]+]]

// CHECK:      [[BASE2]] = !DIDerivedType(tag: DW_TAG_typedef
// CHECK-SAME: name: "fptr"

typedef void fptr();

fptr x;

fptr *y = &x;

//--- member-fptr.cpp

// RUN: %clang -g -target aarch64-elf -mbranch-protection=pauthabi \
// RUN:   -S -emit-llvm member-fptr.cpp -o - | FileCheck member-fptr.cpp

// CHECK:      !DIGlobalVariable(name: "x"
// CHECK-SAME: type: [[TYPEDEF:![0-9]+]]

// CHECK:      [[TYPEDEF]] = !DIDerivedType(tag: DW_TAG_typedef
// CHECK-SAME: name: "fptr",
// CHECK-SAME: baseType: [[TYPE:![0-9]+]]

/* IA key is not emitted in IR metadata nodes but is still present
 * in Dwarf output generated. */

// CHECK:      [[TYPE]] = !DIDerivedType(tag: DW_TAG_LLVM_ptrauth_type
// CHECK-SAME: baseType: [[BASE1:![0-9]+]]
// CHECK-SAME: ptrAuthIsAddressDiscriminated: false
// CHECK-SAME: ptrAuthExtraDiscriminator: 15253
// CHECK-SAME: ptrAuthIsaPointer: false
// CHECK-SAME: ptrAuthAuthenticatesNullValues: false

// CHECK:      [[BASE1]] = !DIDerivedType(tag: DW_TAG_ptr_to_member_type
// CHECK-SAME: baseType: [[BASE2:![0-9]+]]

// CHECK:      [[BASE2]] = !DISubroutineType

struct A {
  void foo() {};
};

typedef void (A::*fptr)();

fptr x = &A::foo;
