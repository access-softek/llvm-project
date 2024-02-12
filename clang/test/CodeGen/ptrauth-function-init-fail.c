// RUN: %clang_cc1 -triple arm64e-apple-ios -target-feature +pauth -fptrauth-calls %s -verify -emit-llvm -S -o -

void f(void);

int *pf = (int *)&f + 1; // expected-error{{cannot compile this static initializer yet}}
