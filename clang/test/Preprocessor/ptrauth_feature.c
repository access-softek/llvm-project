// RUN: %clang_cc1 %s -E -triple=arm64-- | FileCheck %s --check-prefixes=NOCALLS,NOINTRIN,NORETS,NOQUAL
// RUN: %clang_cc1 %s -E -triple=arm64-- -target-feature +pauth -fptrauth-calls | FileCheck %s --check-prefixes=CALLS,NOINTRIN,NORETS,NOQUAL,NOFUNC
// RUN: %clang_cc1 %s -E -triple=arm64-- -target-feature +pauth -fptrauth-returns | FileCheck %s --check-prefixes=NOCALLS,NOINTRIN,RETS,NOQUAL,NOFUNC
// RUN: %clang_cc1 %s -E -triple=arm64-- -target-feature +pauth -fptrauth-intrinsics | FileCheck %s --check-prefixes=NOCALLS,INTRIN,NORETS,QUAL,NOFUNC
// RUN: %clang_cc1 %s -E -triple=arm64e-apple-ios6.0 -target-feature +pauth -fptrauth-intrinsics -fptrauth-function-pointer-type-discrimination -fptrauth-calls | FileCheck %s --check-prefixes=CALLS,INTRIN,NORETS,QUAL,FUNC
// RUN: %clang -E %s --target=aarch64-elf -mcpu=apple-a12 -mbranch-protection=pauthabi | FileCheck %s --check-prefixes=INITFINI,VPTR_ADDR_DISCR,VPTR_TYPE_DISCR
// RUN: %clang -E %s --target=aarch64-elf -mcpu=apple-a12 -mbranch-protection=pauthabi -fno-ptrauth-init-fini | FileCheck %s --check-prefixes=NOINITFINI
// RUN: %clang -E %s --target=aarch64-elf -mcpu=apple-a12 -mbranch-protection=pauthabi -fno-ptrauth-vtable-pointer-address-discrimination | FileCheck %s --check-prefixes=NOVPTR_ADDR_DISCR
// RUN: %clang -E %s --target=aarch64-elf -mcpu=apple-a12 -mbranch-protection=pauthabi -fno-ptrauth-vtable-pointer-type-discrimination | FileCheck %s --check-prefixes=NOVPTR_TYPE_DISCR

#if __has_feature(ptrauth_calls)
// CALLS: has_ptrauth_calls
void has_ptrauth_calls() {}
#else
// NOCALLS: no_ptrauth_calls
void no_ptrauth_calls() {}
#endif

#if __has_feature(ptrauth_intrinsics)
// INTRIN: has_ptrauth_intrinsics
void has_ptrauth_intrinsics() {}
#else
// NOINTRIN: no_ptrauth_intrinsics
void no_ptrauth_intrinsics() {}
#endif

#if __has_feature(ptrauth_returns)
// RETS: has_ptrauth_returns
void has_ptrauth_returns() {}
#else
// NORETS: no_ptrauth_returns
void no_ptrauth_returns() {}
#endif

#if __has_feature(ptrauth_qualifier)
// QUAL: has_ptrauth_qualifier
void has_ptrauth_qualifier() {}
#else
// NOQUAL: no_ptrauth_qualifier
void no_ptrauth_qualifier() {}
#endif

// This is always enabled when ptrauth_calls is enabled, on new enough clangs.
#if __has_feature(ptrauth_member_function_pointer_type_discrimination)
// CALLS: has_ptrauth_member_function_pointer_type_discrimination
void has_ptrauth_member_function_pointer_type_discrimination() {}
#else
// NOCALLS: no_ptrauth_member_function_pointer_type_discrimination
void no_ptrauth_member_function_pointer_type_discrimination() {}
#endif

#if __has_feature(ptrauth_vtable_pointer_address_discrimination)
// VPTR_ADDR_DISCR: has_ptrauth_vtable_pointer_address_discrimination
void has_ptrauth_vtable_pointer_address_discrimination() {}
#else
// NOVPTR_ADDR_DISCR: no_ptrauth_vtable_pointer_address_discrimination
void no_ptrauth_vtable_pointer_address_discrimination() {}
#endif

#if __has_feature(ptrauth_vtable_pointer_type_discrimination)
// VPTR_TYPE_DISCR: has_ptrauth_vtable_pointer_type_discrimination
void has_ptrauth_vtable_pointer_type_discrimination() {}
#else
// NOVPTR_TYPE_DISCR: no_ptrauth_vtable_pointer_type_discrimination
void no_ptrauth_vtable_pointer_type_discrimination() {}
#endif

#if __has_feature(ptrauth_init_fini)
// INITFINI: has_ptrauth_init_fini
void has_ptrauth_init_fini() {}
#else
// NOINITFINI: no_ptrauth_init_fini
void no_ptrauth_init_fini() {}
#endif

#include <ptrauth.h>

#if __has_feature(ptrauth_function_pointer_type_discrimination)
// FUNC: has_ptrauth_function_pointer_type_discrimination
int has_ptrauth_function_pointer_type_discrimination() {
// FUNC: return __builtin_ptrauth_type_discriminator(void (*)(void))
  return ptrauth_function_pointer_type_discriminator(void (*)(void));
}
#else
// NOFUNC: no_ptrauth_function_pointer_type_discrimination
int no_ptrauth_function_pointer_type_discrimination() {
// NOFUNC: return ((ptrauth_extra_data_t)0)
  return ptrauth_function_pointer_type_discriminator(void(*)(void));
}
#endif
