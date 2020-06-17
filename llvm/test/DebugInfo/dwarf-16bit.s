; Test that llvm-dwarfdump can handle DWARF32 v3 with addr_size = 0x02
; The listing was produced from file containing just "int x;" with
;   clang -target msp430 -gdwarf-3 dwarf-16bit.c -S

; REQUIRES: msp430-registered-target
; RUN: llvm-mc --arch=msp430 %s --filetype=obj -o %t
; RUN: llvm-dwarfdump --debug-info %t | FileCheck %s
; RUN: llvm-dwarfdump --verify %t

; CHECK: {{.*}}:  file format elf32-msp430

; CHECK: .debug_info contents:
; CHECK: 0x00000000: Compile Unit: length = 0x00000032, format = DWARF32, version = 0x0003, abbr_offset = 0x0000, addr_size = 0x02 (next unit at 0x00000036)

; CHECK: 0x0000000b: DW_TAG_compile_unit
; CHECK:               DW_AT_producer    ("clang version 11.0.0 (git@github.com:access-softek/llvm-project.git <some hash>)")
; CHECK:               DW_AT_language    (DW_LANG_C99)
; CHECK:               DW_AT_name        ("dwarf-16bit.c")
; CHECK:               DW_AT_stmt_list   (0x00000000)
; CHECK:               DW_AT_comp_dir    ("/tmp")

; CHECK: 0x0000001e:   DW_TAG_variable
; CHECK:                 DW_AT_name      ("x")
; CHECK:                 DW_AT_type      (0x0000002e "int")
; CHECK:                 DW_AT_external  (0x01)
; CHECK:                 DW_AT_decl_file ("/tmp/dwarf-16bit.c")
; CHECK:                 DW_AT_decl_line (1)
; CHECK:                 DW_AT_location  (DW_OP_addr 0x0)

; CHECK: 0x0000002e:   DW_TAG_base_type
; CHECK:                 DW_AT_name      ("int")
; CHECK:                 DW_AT_encoding  (DW_ATE_signed)
; CHECK:                 DW_AT_byte_size (0x02)

; CHECK: 0x00000035:   NULL

	.text
	.file	"dwarf-16bit.c"
	.file	1 "/tmp" "dwarf-16bit.c"
	.type	x,@object               ; @x
	.section	.bss,"aw",@nobits
	.globl	x
	.p2align	1
x:
	.short	0                       ; 0x0
	.size	x, 2

	.section	.debug_abbrev,"",@progbits
	.byte	1                       ; Abbreviation Code
	.byte	17                      ; DW_TAG_compile_unit
	.byte	1                       ; DW_CHILDREN_yes
	.byte	37                      ; DW_AT_producer
	.byte	14                      ; DW_FORM_strp
	.byte	19                      ; DW_AT_language
	.byte	5                       ; DW_FORM_data2
	.byte	3                       ; DW_AT_name
	.byte	14                      ; DW_FORM_strp
	.byte	16                      ; DW_AT_stmt_list
	.byte	6                       ; DW_FORM_data4
	.byte	27                      ; DW_AT_comp_dir
	.byte	14                      ; DW_FORM_strp
	.byte	0                       ; EOM(1)
	.byte	0                       ; EOM(2)
	.byte	2                       ; Abbreviation Code
	.byte	52                      ; DW_TAG_variable
	.byte	0                       ; DW_CHILDREN_no
	.byte	3                       ; DW_AT_name
	.byte	14                      ; DW_FORM_strp
	.byte	73                      ; DW_AT_type
	.byte	19                      ; DW_FORM_ref4
	.byte	63                      ; DW_AT_external
	.byte	12                      ; DW_FORM_flag
	.byte	58                      ; DW_AT_decl_file
	.byte	11                      ; DW_FORM_data1
	.byte	59                      ; DW_AT_decl_line
	.byte	11                      ; DW_FORM_data1
	.byte	2                       ; DW_AT_location
	.byte	10                      ; DW_FORM_block1
	.byte	0                       ; EOM(1)
	.byte	0                       ; EOM(2)
	.byte	3                       ; Abbreviation Code
	.byte	36                      ; DW_TAG_base_type
	.byte	0                       ; DW_CHILDREN_no
	.byte	3                       ; DW_AT_name
	.byte	14                      ; DW_FORM_strp
	.byte	62                      ; DW_AT_encoding
	.byte	11                      ; DW_FORM_data1
	.byte	11                      ; DW_AT_byte_size
	.byte	11                      ; DW_FORM_data1
	.byte	0                       ; EOM(1)
	.byte	0                       ; EOM(2)
	.byte	0                       ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	3                       ; DWARF version number
	.long	.debug_abbrev           ; Offset Into Abbrev. Section
	.byte	2                       ; Address Size (in bytes)
	.byte	1                       ; Abbrev [1] 0xb:0x2b DW_TAG_compile_unit
	.long	.Linfo_string0          ; DW_AT_producer
	.short	12                      ; DW_AT_language
	.long	.Linfo_string1          ; DW_AT_name
	.long	.Lline_table_start0     ; DW_AT_stmt_list
	.long	.Linfo_string2          ; DW_AT_comp_dir
	.byte	2                       ; Abbrev [2] 0x1e:0x10 DW_TAG_variable
	.long	.Linfo_string3          ; DW_AT_name
	.long	46                      ; DW_AT_type
	.byte	1                       ; DW_AT_external
	.byte	1                       ; DW_AT_decl_file
	.byte	1                       ; DW_AT_decl_line
	.byte	3                       ; DW_AT_location
	.byte	3
	.short	x
	.byte	3                       ; Abbrev [3] 0x2e:0x7 DW_TAG_base_type
	.long	.Linfo_string4          ; DW_AT_name
	.byte	5                       ; DW_AT_encoding
	.byte	2                       ; DW_AT_byte_size
	.byte	0                       ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"clang version 11.0.0 (git@github.com:access-softek/llvm-project.git <some hash>)" ; string offset=0
.Linfo_string1:
	.asciz	"dwarf-16bit.c"         ; string offset=110
.Linfo_string2:
	.asciz	"/tmp"                  ; string offset=124
.Linfo_string3:
	.asciz	"x"                     ; string offset=129
.Linfo_string4:
	.asciz	"int"                   ; string offset=131
	.ident	"clang version 11.0.0 (git@github.com:access-softek/llvm-project.git <some hash>)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.section	.debug_line,"",@progbits
.Lline_table_start0:
