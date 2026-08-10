// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -fms-kernel -fms-extensions -triple x86_64-windows-msvc -O2 -S %s -o - | FileCheck %s

// CHECK-LABEL: my_noreturn_func:
// CHECK:       callq bugcheck
// CHECK-NEXT:  ud2

// CHECK-LABEL: my_noreturn_func2:
// CHECK:       movl $0, (%rax)
// CHECK-NEXT:  ud2

void bugcheck(int code);

extern long volatile *gtrap;

__declspec(noreturn) void my_noreturn_func(void) {
    bugcheck(0x42);
}


__declspec(noreturn) void my_noreturn_func2(void) {
    *gtrap = 0;
}

