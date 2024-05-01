	.text
	.section	.note.gnu.property,"a",@note
	.p2align	3, 0x0
	.word	4
	.word	24
	.word	5
	.asciz	"GNU"
	.word	3221225473
	.word	16
	.xword	268435458
	.xword	128
.Lsec_end0:
	.text
	.file	"arm64-tls-dynamics-auth.ll"
	.globl	test_generaldynamic             // -- Begin function test_generaldynamic
	.p2align	2
	.type	test_generaldynamic,@function
test_generaldynamic:                    // @test_generaldynamic
	.cfi_startproc
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.cfi_def_cfa_offset 16
	.cfi_offset w30, -16
	adrp	x0, :tlsdesc_auth:general_dynamic_var
	ldr	x16, [x0, :tlsdesc_auth_lo12:general_dynamic_var]
	add	x0, x0, :tlsdesc_auth_lo12:general_dynamic_var
	autia	x16, x0
	.tlsdesccall general_dynamic_var
	blr	x16
	mrs	x8, TPIDR_EL0
	ldr	w0, [x8, x0]
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	ret
.Lfunc_end0:
	.size	test_generaldynamic, .Lfunc_end0-test_generaldynamic
	.cfi_endproc
                                        // -- End function
	.globl	test_generaldynamic_addr        // -- Begin function test_generaldynamic_addr
	.p2align	2
	.type	test_generaldynamic_addr,@function
test_generaldynamic_addr:               // @test_generaldynamic_addr
	.cfi_startproc
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.cfi_def_cfa_offset 16
	.cfi_offset w30, -16
	adrp	x0, :tlsdesc_auth:general_dynamic_var
	ldr	x16, [x0, :tlsdesc_auth_lo12:general_dynamic_var]
	add	x0, x0, :tlsdesc_auth_lo12:general_dynamic_var
	autia	x16, x0
	.tlsdesccall general_dynamic_var
	blr	x16
	mrs	x8, TPIDR_EL0
	add	x0, x8, x0
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	ret
.Lfunc_end1:
	.size	test_generaldynamic_addr, .Lfunc_end1-test_generaldynamic_addr
	.cfi_endproc
                                        // -- End function
	.globl	test_localdynamic               // -- Begin function test_localdynamic
	.p2align	2
	.type	test_localdynamic,@function
test_localdynamic:                      // @test_localdynamic
	.cfi_startproc
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.cfi_def_cfa_offset 16
	.cfi_offset w30, -16
	adrp	x0, :tlsdesc_auth:local_dynamic_var
	ldr	x16, [x0, :tlsdesc_auth_lo12:local_dynamic_var]
	add	x0, x0, :tlsdesc_auth_lo12:local_dynamic_var
	autia	x16, x0
	.tlsdesccall local_dynamic_var
	blr	x16
	mrs	x8, TPIDR_EL0
	ldr	w0, [x8, x0]
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	ret
.Lfunc_end2:
	.size	test_localdynamic, .Lfunc_end2-test_localdynamic
	.cfi_endproc
                                        // -- End function
	.globl	test_localdynamic_addr          // -- Begin function test_localdynamic_addr
	.p2align	2
	.type	test_localdynamic_addr,@function
test_localdynamic_addr:                 // @test_localdynamic_addr
	.cfi_startproc
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.cfi_def_cfa_offset 16
	.cfi_offset w30, -16
	adrp	x0, :tlsdesc_auth:local_dynamic_var
	ldr	x16, [x0, :tlsdesc_auth_lo12:local_dynamic_var]
	add	x0, x0, :tlsdesc_auth_lo12:local_dynamic_var
	autia	x16, x0
	.tlsdesccall local_dynamic_var
	blr	x16
	mrs	x8, TPIDR_EL0
	add	x0, x8, x0
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	ret
.Lfunc_end3:
	.size	test_localdynamic_addr, .Lfunc_end3-test_localdynamic_addr
	.cfi_endproc
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
