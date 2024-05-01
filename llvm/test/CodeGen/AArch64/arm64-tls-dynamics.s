	.text
	.file	"arm64-tls-dynamics.ll"
	.globl	test_generaldynamic             // -- Begin function test_generaldynamic
	.p2align	2
	.type	test_generaldynamic,@function
test_generaldynamic:                    // @test_generaldynamic
	.cfi_startproc
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.cfi_def_cfa_offset 16
	.cfi_offset w30, -16
	adrp	x0, :tlsdesc:general_dynamic_var
	ldr	x1, [x0, :tlsdesc_lo12:general_dynamic_var]
	add	x0, x0, :tlsdesc_lo12:general_dynamic_var
	.tlsdesccall general_dynamic_var
	blr	x1
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
	adrp	x0, :tlsdesc:general_dynamic_var
	ldr	x1, [x0, :tlsdesc_lo12:general_dynamic_var]
	add	x0, x0, :tlsdesc_lo12:general_dynamic_var
	.tlsdesccall general_dynamic_var
	blr	x1
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
	adrp	x0, :tlsdesc:local_dynamic_var
	ldr	x1, [x0, :tlsdesc_lo12:local_dynamic_var]
	add	x0, x0, :tlsdesc_lo12:local_dynamic_var
	.tlsdesccall local_dynamic_var
	blr	x1
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
	adrp	x0, :tlsdesc:local_dynamic_var
	ldr	x1, [x0, :tlsdesc_lo12:local_dynamic_var]
	add	x0, x0, :tlsdesc_lo12:local_dynamic_var
	.tlsdesccall local_dynamic_var
	blr	x1
	mrs	x8, TPIDR_EL0
	add	x0, x8, x0
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	ret
.Lfunc_end3:
	.size	test_localdynamic_addr, .Lfunc_end3-test_localdynamic_addr
	.cfi_endproc
                                        // -- End function
	.globl	test_localdynamic_deduplicate   // -- Begin function test_localdynamic_deduplicate
	.p2align	2
	.type	test_localdynamic_deduplicate,@function
test_localdynamic_deduplicate:          // @test_localdynamic_deduplicate
	.cfi_startproc
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.cfi_def_cfa_offset 16
	.cfi_offset w30, -16
	adrp	x0, :tlsdesc:local_dynamic_var
	ldr	x1, [x0, :tlsdesc_lo12:local_dynamic_var]
	add	x0, x0, :tlsdesc_lo12:local_dynamic_var
	.tlsdesccall local_dynamic_var
	blr	x1
	mrs	x8, TPIDR_EL0
	ldr	w9, [x8, x0]
	adrp	x0, :tlsdesc:local_dynamic_var2
	ldr	x1, [x0, :tlsdesc_lo12:local_dynamic_var2]
	add	x0, x0, :tlsdesc_lo12:local_dynamic_var2
	.tlsdesccall local_dynamic_var2
	blr	x1
	ldr	w8, [x8, x0]
	add	w0, w9, w8
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	ret
.Lfunc_end4:
	.size	test_localdynamic_deduplicate, .Lfunc_end4-test_localdynamic_deduplicate
	.cfi_endproc
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
