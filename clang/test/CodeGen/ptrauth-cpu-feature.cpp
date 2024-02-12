// REQUIRES: aarch64-registered-target

// Test that features requiring FEAT_PAuth fail early if the requirement is not met:
// Specifying the precise target triples here to prevent accidentally enabling unexpected
// -fptrauth-* options as target defaults (would violate NO-UNEXPECTED check lines).
//
// RUN: not %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -mbranch-protection=pauthabi 2>&1 \
// RUN:     | FileCheck %s --check-prefixes=FAIL-INTRINSICS,FAIL-CALLS,FAIL-RETURNS,NO-UNEXPECTED
// RUN: not %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-intrinsics         2>&1 \
// RUN:     | FileCheck %s --check-prefixes=FAIL-INTRINSICS,NO-UNEXPECTED
// RUN: not %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-calls              2>&1 \
// RUN:     | FileCheck %s --check-prefixes=FAIL-CALLS,NO-UNEXPECTED
// RUN: not %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-returns            2>&1 \
// RUN:     | FileCheck %s --check-prefixes=FAIL-RETURNS,NO-UNEXPECTED
// RUN: not %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-objc-isa           2>&1 \
// RUN:     | FileCheck %s --check-prefixes=FAIL-OBJC-ISA,NO-UNEXPECTED
//
// Test that no errors and warnings are generated if FEAT_PAUTH is supported:
// RUN: %clang %s -S -o - -target aarch64 -mcpu=apple-a12        -mbranch-protection=pauthabi 2>&1 \
// RUN:     | FileCheck %s --check-prefix=PAUTH --implicit-check-not=error --implicit-check-not=warning
// RUN: %clang %s -S -o - -target aarch64 -march=armv8.3-a       -mbranch-protection=pauthabi 2>&1 \
// RUN:     | FileCheck %s --check-prefix=PAUTH --implicit-check-not=error --implicit-check-not=warning
// RUN: %clang %s -S -o - -target aarch64 -march=armv9-a         -mbranch-protection=pauthabi 2>&1 \
// RUN:     | FileCheck %s --check-prefix=PAUTH --implicit-check-not=error --implicit-check-not=warning
// RUN: %clang %s -S -o - -target aarch64 -march=armv8.2-a+pauth -mbranch-protection=pauthabi 2>&1 \
// RUN:     | FileCheck %s --check-prefix=PAUTH --implicit-check-not=error --implicit-check-not=warning
//
// Test a few combinations of options that should not generate warnings:
// RUN: %clang %s -S -o - -target aarch64 -march=armv8.3-a -fptrauth-returns                                2>&1 \
// RUN:     | FileCheck %s --check-prefix=NO-UNEXPECTED
// RUN: %clang %s -S -o - -target aarch64 -march=armv8.3-a -fptrauth-objc-isa                               2>&1 \
// RUN:     | FileCheck %s --check-prefix=NO-UNEXPECTED
// RUN: %clang %s -S -o - -target aarch64 -march=armv8.3-a -fptrauth-init-fini -fptrauth-calls              2>&1 \
// RUN:     | FileCheck %s --check-prefix=NO-UNEXPECTED
// RUN: %clang %s -S -o - -target aarch64 -march=armv8.3-a -fptrauth-init-fini -mbranch-protection=pauthabi 2>&1 \
// RUN:     | FileCheck %s --check-prefix=NO-UNEXPECTED

// Test that the following options are still gated on -fptrauth-calls.
// If they are not, in assertion builds they would usually fail at asm printing time.
// These tests rely on -fptrauth-calls not being implicitly enabled, so
// specifying the precise target triple.
//
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-init-fini                                   2>&1 \
// RUN:     | FileCheck %s --check-prefixes=NO-PTRAUTH-CALLS,NO-UNEXPECTED -DOPTION=-fptrauth-init-fini
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-function-pointer-type-discrimination        2>&1 \
// RUN:     | FileCheck %s --check-prefixes=NO-PTRAUTH-CALLS,NO-UNEXPECTED -DOPTION=-fptrauth-function-pointer-type-discrimination
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-vtable-pointer-address-discrimination       2>&1 \
// RUN:     | FileCheck %s --check-prefixes=NO-PTRAUTH-CALLS,NO-UNEXPECTED -DOPTION=-fptrauth-vtable-pointer-address-discrimination
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-vtable-pointer-type-discrimination          2>&1 \
// RUN:     | FileCheck %s --check-prefixes=NO-PTRAUTH-CALLS,NO-UNEXPECTED -DOPTION=-fptrauth-vtable-pointer-type-discrimination
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -fptrauth-block-descriptor-pointers -fblocks -DBLOCKS 2>&1 \
// RUN:     | FileCheck %s --check-prefixes=NO-PTRAUTH-CALLS,NO-UNEXPECTED -DOPTION=-fptrauth-block-descriptor-pointers

// Test that v8.2-compatible code is generated, if possible:
//
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -msign-return-address=all         2>&1 \
// RUN:     | FileCheck %s --check-prefix=COMPAT
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -mbranch-protection=pac-ret       2>&1 \
// RUN:     | FileCheck %s --check-prefix=COMPAT
// RUN: %clang %s -S -o - -target aarch64-linux-gnu -mcpu=cortex-a72 -mbranch-protection=pac-ret+b-key 2>&1 \
// RUN:     | FileCheck %s --check-prefix=COMPAT

// arm64e has ptrauth enabled and assumes modern enough CPU by default:
//
// RUN:     %clang %s -S -o - -target arm64e-apple-ios                  2>&1 \
// RUN:     | FileCheck %s --check-prefix=PAUTH
// RUN: not %clang %s -S -o - -target arm64e-apple-ios -mcpu=cortex-a72 2>&1 \
// RUN:     | FileCheck %s --check-prefixes=FAIL-INTRINSICS,FAIL-CALLS,FAIL-RETURNS,FAIL-OBJC-ISA,NO-UNEXPECTED

volatile int counter;

void ext(void);

// Basically check the code generated for `caller`, other functions and classes
// are provided just to check that assertion-enabled builds do not crash when
// generating code for constructors, vtable, etc.

extern "C" int caller(void) {
  ext();
  return 0;
}

#ifdef BLOCKS
int g(int (^bptr)(int)) {
  return bptr(42);
}
#endif

class Base {
public:
  virtual void f() {}
  virtual ~Base() {}
};

class Derived : public Base {
  void f() override {
    counter += 1;
  }
};

__attribute__((constructor)) void constr(void) {
  counter = 42;
}

__attribute__((destructor)) void destr(void) {
  counter = 0;
}

// Make Base and Derived usable from outside of this compilation unit
// to prevent superfluous optimization.
extern "C" void call_virtual(Base *B) {
  B->f();
}
extern "C" void *create(bool f) {
  if (f)
    return new Base();
  else
    return new Derived();
}

// NO-PTRAUTH-CALLS: warning: [[OPTION]] is ignored because neither -fptrauth-calls nor -mbranch-protection=pauthabi is specified
// FAIL-INTRINSICS: error: -fptrauth-intrinsics or -mbranch-protection=pauthabi is passed that require either enabling PAuth CPU feature or passing -fptrauth-soft option
// FAIL-CALLS:      error: -fptrauth-calls or -mbranch-protection=pauthabi is passed that require either enabling PAuth CPU feature or passing -fptrauth-soft option
// FAIL-RETURNS:    error: -fptrauth-returns or -mbranch-protection=pauthabi is passed that require either enabling PAuth CPU feature or passing -fptrauth-soft option
// FAIL-OBJC-ISA:   error: -fptrauth-objc-isa=... or -mbranch-protection=pauthabi is passed that require either enabling PAuth CPU feature or passing -fptrauth-soft option
// NO-UNEXPECTED-NOT: error:
// NO-UNEXPECTED-NOT: warning:

// COMPAT: caller:
// COMPAT:   hint {{#25|#27}}
//
// COMPAT:   hint {{#29|#31}}
// COMPAT:   ret
// COMPAT:   -- End function

// PAUTH: caller:
// PAUTH:   paci{{[ab]}}sp
//
// PAUTH:   reta{{[ab]}}
// PAUTH:   -- End function

// Just check that some assembler output is printed and -fptrauth-init-fini
// is disabled.
//
// NO-PTRAUTH-CALLS-NOT: @AUTH
//
// NO-PTRAUTH-CALLS: caller:
//
// NO-PTRAUTH-CALLS-NOT: @AUTH
