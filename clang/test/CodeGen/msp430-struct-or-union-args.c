// REQUIRES: msp430-registered-target
// RUN: %clang -target msp430 -fno-inline-functions -S -o- %s | FileCheck --check-prefixes=ASM %s
// RUN: %clang -target msp430 -fno-inline-functions -S -emit-llvm -o- %s | FileCheck --check-prefixes=IR %s

#include <limits.h>
#include <stdint.h>

// According to Section 3.5 of MSP430 EABI, structures and unions are passed
// by reference, even if an equally-sized integer argument could be passed
// in registers.

struct S {
  uint16_t a;
};
union U {
  uint16_t a;
};

// IR: %struct.S = type { i16 }
// IR: %union.U = type { i16 }

_Static_assert(sizeof(struct S) * CHAR_BIT == 16, "Unexpected size");
_Static_assert(sizeof(union U) * CHAR_BIT == 16, "Unexpected size");

extern struct S s;
extern union U u;

// Cannot know for sure whether they change the argument
extern void leaf_s(struct S *x);
extern void leaf_u(union U *);

// Callee is responsible for leaving the byref argument intact
void middle_s(struct S x) {
// IR: define {{(dso_local )?}}void @middle_s(%struct.S* byref(%struct.S) align 2 [[S_ARG:%.+]])
// IR: [[S_COPY:%.+]] = alloca %struct.S, align 2
// IR: [[S_CASTED_COPY:%.+]] = bitcast %struct.S* [[S_COPY]] to i8*
// IR: [[S_CASTED_ARG:%.+]] = bitcast %struct.S* [[S_ARG]] to i8*
// IR: call void @llvm.memcpy.p0i8.p0i8.i16(i8* align 2 [[S_CASTED_COPY]], i8* align 2 [[S_CASTED_ARG]], i16 2, i1 false)
// IR: call void @leaf_s(%struct.S* [[S_COPY]])
// IR: ret void

// ASM:      middle_s:
// ASM:      sub #2, r1
// ... here memcpy() occurs ...
// ASM:      mov r1, r12
// ASM-NEXT: call #leaf_s
// ASM-NEXT: add #2, r1
// ASM-NEXT: ret
  leaf_s(&x);
}
void middle_u(union U x) {
// IR: define {{(dso_local )?}}void @middle_u(%union.U* byref(%union.U) align 2 [[U_ARG:%.+]])
// IR: [[U_COPY:%.+]] = alloca %union.U, align 2
// IR: [[U_CASTED_COPY:%.+]] = bitcast %union.U* [[U_COPY]] to i8*
// IR: [[U_CASTED_ARG:%.+]] = bitcast %union.U* [[U_ARG]] to i8*
// IR: call void @llvm.memcpy.p0i8.p0i8.i16(i8* align 2 [[U_CASTED_COPY]], i8* align 2 [[U_CASTED_ARG]], i16 2, i1 false)
// IR: call void @leaf_u(%union.U* [[U_COPY]])
// IR: ret void

// ASM:      middle_u:
// ASM:      sub #2, r1
// ... here memcpy() occurs ...
// ASM:      mov r1, r12
// ASM-NEXT: call #leaf_u
// ASM-NEXT: add #2, r1
// ASM-NEXT: ret
  leaf_u(&x);
}

void caller_s(void) {
// IR: define {{(dso_local )?}}void @caller_s()
// IR: call void @middle_s(%struct.S* byref(%struct.S) align 2 @s)
// IR: ret void

// ASM:      caller_s:
// ASM:      mov #s, r12
// ASM-NEXT: call #middle_s
// ASM-NEXT: ret
  middle_s(s);
}
void caller_u(void) {
// IR: define dso_local void @caller_u()
// IR: call void @middle_u(%union.U* byref(%union.U) align 2 @u)
// IR: ret void

// ASM:      caller_u:
// ASM:      mov #u, r12
// ASM-NEXT: call #middle_u
// ASM-NEXT: ret
  middle_u(u);
}
