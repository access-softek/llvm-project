//===-- arm-libcall-overrides.h - LibCall overrides for ARM targets -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#define AEABI_RTABI __attribute__((__pcs__("aapcs")))

#define AUX_DECLS__ashldi3 COMPILER_RT_ALIAS(__ashldi3, __aeabi_llsl)
#define AUX_DECLS__ashrdi3 COMPILER_RT_ALIAS(__ashrdi3, __aeabi_lasr)
#define AUX_DECLS__lshrdi3 COMPILER_RT_ALIAS(__lshrdi3, __aeabi_llsr)
#define AUX_DECLS__divsi3 COMPILER_RT_ALIAS(__divsi3, __aeabi_idiv)
#define AUX_DECLS__muldi3 COMPILER_RT_ALIAS(__muldi3, __aeabi_lmul)
#define AUX_DECLS__udivsi3 COMPILER_RT_ALIAS(__udivsi3, __aeabi_uidiv)

#if defined(COMPILER_RT_ARMHF_TARGET)

#define COMPILER_RT_ABI

// grep -h 'AEABI_RTABI' *.c | sed -r 's/^(AEABI_RTABI [^ ]+ (__[^(]+).*)$/#define AUX_DECLS\2 \1/'
// update() { tr '\n' '\0' < $1 | sed 's/#if defined(__ARM_EABI__)\x00#if defined(COMPILER_RT_ARMHF_TARGET)\x00AEABI_RTABI[^\x00]\+\x00#else\x00COMPILER_RT_ALIAS(\([^,]\+\),[^\x00]\+)\x00#endif\x00#endif/AUX_DECLS(\1)/' | tr '\0' '\n' > $1.tmp ; mv $1.tmp $1 ; }
#define AUX_DECLS__aeabi_dadd AEABI_RTABI double __aeabi_dadd(double a, double b) { return __adddf3(a, b); }
#define AUX_DECLS__aeabi_fadd AEABI_RTABI float __aeabi_fadd(float a, float b) { return __addsf3(a, b); }
#define AUX_DECLS__aeabi_dcmpun AEABI_RTABI int __aeabi_dcmpun(fp_t a, fp_t b) { return __unorddf2(a, b); }
#define AUX_DECLS__aeabi_fcmpun AEABI_RTABI int __aeabi_fcmpun(fp_t a, fp_t b) { return __unordsf2(a, b); }
#define AUX_DECLS__aeabi_ddiv AEABI_RTABI fp_t __aeabi_ddiv(fp_t a, fp_t b) { return __divdf3(a, b); }
#define AUX_DECLS__aeabi_fdiv AEABI_RTABI fp_t __aeabi_fdiv(fp_t a, fp_t b) { return __divsf3(a, b); }
#define AUX_DECLS__aeabi_h2f AEABI_RTABI float __aeabi_h2f(uint16_t a) { return __extendhfsf2(a); }
#define AUX_DECLS__aeabi_f2d AEABI_RTABI double __aeabi_f2d(float a) { return __extendsfdf2(a); }
#define AUX_DECLS__aeabi_d2lz AEABI_RTABI di_int __aeabi_d2lz(fp_t a) { return __fixdfdi(a); }
#define AUX_DECLS__aeabi_d2iz AEABI_RTABI si_int __aeabi_d2iz(fp_t a) { return __fixdfsi(a); }
#define AUX_DECLS__aeabi_f2lz AEABI_RTABI di_int __aeabi_f2lz(fp_t a) { return __fixsfdi(a); }
#define AUX_DECLS__aeabi_f2iz AEABI_RTABI si_int __aeabi_f2iz(fp_t a) { return __fixsfsi(a); }
#define AUX_DECLS__aeabi_d2ulz AEABI_RTABI du_int __aeabi_d2ulz(fp_t a) { return __fixunsdfdi(a); }
#define AUX_DECLS__aeabi_d2uiz AEABI_RTABI su_int __aeabi_d2uiz(fp_t a) { return __fixunsdfsi(a); }
#define AUX_DECLS__aeabi_f2ulz AEABI_RTABI du_int __aeabi_f2ulz(fp_t a) { return __fixunssfdi(a); }
#define AUX_DECLS__aeabi_f2uiz AEABI_RTABI su_int __aeabi_f2uiz(fp_t a) { return __fixunssfsi(a); }
#define AUX_DECLS__aeabi_l2d AEABI_RTABI double __aeabi_l2d(di_int a) { return __floatdidf(a); }
#define AUX_DECLS__aeabi_l2f AEABI_RTABI float __aeabi_l2f(di_int a) { return __floatdisf(a); }
#define AUX_DECLS__aeabi_i2d AEABI_RTABI fp_t __aeabi_i2d(si_int a) { return __floatsidf(a); }
#define AUX_DECLS__aeabi_i2f AEABI_RTABI fp_t __aeabi_i2f(int a) { return __floatsisf(a); }
#define AUX_DECLS__aeabi_ul2d AEABI_RTABI double __aeabi_ul2d(du_int a) { return __floatundidf(a); }
#define AUX_DECLS__aeabi_ul2f AEABI_RTABI float __aeabi_ul2f(du_int a) { return __floatundisf(a); }
#define AUX_DECLS__aeabi_ui2d AEABI_RTABI fp_t __aeabi_ui2d(su_int a) { return __floatunsidf(a); }
#define AUX_DECLS__aeabi_ui2f AEABI_RTABI fp_t __aeabi_ui2f(unsigned int a) { return __floatunsisf(a); }
#define AUX_DECLS__aeabi_dmul AEABI_RTABI fp_t __aeabi_dmul(fp_t a, fp_t b) { return __muldf3(a, b); }
#define AUX_DECLS__aeabi_fmul AEABI_RTABI fp_t __aeabi_fmul(fp_t a, fp_t b) { return __mulsf3(a, b); }
#define AUX_DECLS__aeabi_dneg AEABI_RTABI fp_t __aeabi_dneg(fp_t a) { return __negdf2(a); }
#define AUX_DECLS__aeabi_fneg AEABI_RTABI fp_t __aeabi_fneg(fp_t a) { return __negsf2(a); }
#define AUX_DECLS__aeabi_dsub AEABI_RTABI fp_t __aeabi_dsub(fp_t a, fp_t b) { return __subdf3(a, b); }
#define AUX_DECLS__aeabi_fsub AEABI_RTABI fp_t __aeabi_fsub(fp_t a, fp_t b) { return __subsf3(a, b); }
#define AUX_DECLS__aeabi_d2h AEABI_RTABI uint16_t __aeabi_d2h(double a) { return __truncdfhf2(a); }
#define AUX_DECLS__aeabi_d2f AEABI_RTABI float __aeabi_d2f(double a) { return __truncdfsf2(a); }
#define AUX_DECLS__aeabi_f2h AEABI_RTABI uint16_t __aeabi_f2h(float a) { return __truncsfhf2(a); }

#else // !defined(COMPILER_RT_ARMHF_TARGET)

#define COMPILER_RT_ABI AEABI_RTABI

// grep -h 'COMPILER_RT_ALIAS.*eabi' *.c | sed -r 's/^(COMPILER_RT_ALIAS\((__[^,]+).*)$/#define AUX_DECLS\2 \1/'
#define AUX_DECLS__adddf3 COMPILER_RT_ALIAS(__adddf3, __aeabi_dadd)
#define AUX_DECLS__addsf3 COMPILER_RT_ALIAS(__addsf3, __aeabi_fadd)
#define AUX_DECLS__ashldi3 COMPILER_RT_ALIAS(__ashldi3, __aeabi_llsl)
#define AUX_DECLS__ashrdi3 COMPILER_RT_ALIAS(__ashrdi3, __aeabi_lasr)
#define AUX_DECLS__unorddf2 COMPILER_RT_ALIAS(__unorddf2, __aeabi_dcmpun)
#define AUX_DECLS__unordsf2 COMPILER_RT_ALIAS(__unordsf2, __aeabi_fcmpun)
#define AUX_DECLS__divdf3 COMPILER_RT_ALIAS(__divdf3, __aeabi_ddiv)
#define AUX_DECLS__divsf3 COMPILER_RT_ALIAS(__divsf3, __aeabi_fdiv)
#define AUX_DECLS__divsi3 COMPILER_RT_ALIAS(__divsi3, __aeabi_idiv)
#define AUX_DECLS__extendhfsf2 COMPILER_RT_ALIAS(__extendhfsf2, __aeabi_h2f)
#define AUX_DECLS__extendsfdf2 COMPILER_RT_ALIAS(__extendsfdf2, __aeabi_f2d)
#define AUX_DECLS__fixdfdi COMPILER_RT_ALIAS(__fixdfdi, __aeabi_d2lz)
#define AUX_DECLS__fixdfsi COMPILER_RT_ALIAS(__fixdfsi, __aeabi_d2iz)
#define AUX_DECLS__fixsfdi COMPILER_RT_ALIAS(__fixsfdi, __aeabi_f2lz)
#define AUX_DECLS__fixsfsi COMPILER_RT_ALIAS(__fixsfsi, __aeabi_f2iz)
#define AUX_DECLS__fixunsdfdi COMPILER_RT_ALIAS(__fixunsdfdi, __aeabi_d2ulz)
#define AUX_DECLS__fixunsdfsi COMPILER_RT_ALIAS(__fixunsdfsi, __aeabi_d2uiz)
#define AUX_DECLS__fixunssfdi COMPILER_RT_ALIAS(__fixunssfdi, __aeabi_f2ulz)
#define AUX_DECLS__fixunssfsi COMPILER_RT_ALIAS(__fixunssfsi, __aeabi_f2uiz)
#define AUX_DECLS__floatdidf COMPILER_RT_ALIAS(__floatdidf, __aeabi_l2d)
#define AUX_DECLS__floatdisf COMPILER_RT_ALIAS(__floatdisf, __aeabi_l2f)
#define AUX_DECLS__floatsidf COMPILER_RT_ALIAS(__floatsidf, __aeabi_i2d)
#define AUX_DECLS__floatsisf COMPILER_RT_ALIAS(__floatsisf, __aeabi_i2f)
#define AUX_DECLS__floatundidf COMPILER_RT_ALIAS(__floatundidf, __aeabi_ul2d)
#define AUX_DECLS__floatundisf COMPILER_RT_ALIAS(__floatundisf, __aeabi_ul2f)
#define AUX_DECLS__floatunsidf COMPILER_RT_ALIAS(__floatunsidf, __aeabi_ui2d)
#define AUX_DECLS__floatunsisf COMPILER_RT_ALIAS(__floatunsisf, __aeabi_ui2f)
#define AUX_DECLS__lshrdi3 COMPILER_RT_ALIAS(__lshrdi3, __aeabi_llsr)
#define AUX_DECLS__muldf3 COMPILER_RT_ALIAS(__muldf3, __aeabi_dmul)
#define AUX_DECLS__muldi3 COMPILER_RT_ALIAS(__muldi3, __aeabi_lmul)
#define AUX_DECLS__mulsf3 COMPILER_RT_ALIAS(__mulsf3, __aeabi_fmul)
#define AUX_DECLS__negdf2 COMPILER_RT_ALIAS(__negdf2, __aeabi_dneg)
#define AUX_DECLS__negsf2 COMPILER_RT_ALIAS(__negsf2, __aeabi_fneg)
#define AUX_DECLS__subdf3 COMPILER_RT_ALIAS(__subdf3, __aeabi_dsub)
#define AUX_DECLS__subsf3 COMPILER_RT_ALIAS(__subsf3, __aeabi_fsub)
#define AUX_DECLS__truncdfhf2 COMPILER_RT_ALIAS(__truncdfhf2, __aeabi_d2h)
#define AUX_DECLS__truncdfsf2 COMPILER_RT_ALIAS(__truncdfsf2, __aeabi_d2f)
#define AUX_DECLS__truncsfhf2 COMPILER_RT_ALIAS(__truncsfhf2, __aeabi_f2h)
#define AUX_DECLS__udivsi3 COMPILER_RT_ALIAS(__udivsi3, __aeabi_uidiv)

#endif // defined(COMPILER_RT_ARMHF_TARGET)
