	.section	__TEXT,__text,regular,pure_instructions
	.globl	"_Class#==<Class, Class>"
	.align	4, 0x90
"_Class#==<Class, Class>":              ## @"Class#==<Class, Class>"
Leh_func_begin0:
## BB#0:                                ## %entry
	pushq	%r14
Ltmp0:
	pushq	%rbx
Ltmp1:
	pushq	%rax
Ltmp2:
	movq	%rsi, %rbx
	callq	"_Class#object_id<Class>"
	movq	%rax, %r14
	movq	%rbx, %rdi
	callq	"_Class#object_id<Class>"
	movq	%r14, %rdi
	movq	%rax, %rsi
	callq	"_Long#==<Long, Long>"
	addq	$8, %rsp
	popq	%rbx
	popq	%r14
	ret
Leh_func_end0:

	.globl	"_Long#==<Long, Long>"
	.align	4, 0x90
"_Long#==<Long, Long>":                 ## @"Long#==<Long, Long>"
Leh_func_begin1:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp3:
	callq	_crystal_eq_long_long
	popq	%rdx
	ret
Leh_func_end1:

	.globl	"_Class#object_id<Class>"
	.align	4, 0x90
"_Class#object_id<Class>":              ## @"Class#object_id<Class>"
Leh_func_begin2:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp4:
	callq	_crystal_class_object_id
	popq	%rdx
	ret
Leh_func_end2:

	.globl	"_&anon"
	.align	4, 0x90
"_&anon":                               ## @"&anon"
Leh_func_begin3:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp5:
	movl	$2153067680, %edi       ## imm = 0x805534A0
	movl	$2153067680, %esi       ## imm = 0x805534A0
	callq	"_Class#==<Class, Class>"
	popq	%rdx
	ret
Leh_func_end3:

	.align	4, 0x90
"L_&main1":                             ## @"&main1"
Leh_func_begin4:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp6:
	movl	$20, %edi
	leaq	(%rsp), %rsi
	leaq	"_&block1"(%rip), %rdx
	callq	"_Int#times<Int>&Nil"
	popq	%rdx
	ret
Leh_func_end4:

	.globl	"_Int#times<Int>&Nil"
	.align	4, 0x90
"_Int#times<Int>&Nil":                  ## @"Int#times<Int>&Nil"
Leh_func_begin5:
## BB#0:                                ## %entry
	pushq	%r15
Ltmp7:
	pushq	%r14
Ltmp8:
	pushq	%r12
Ltmp9:
	pushq	%rbx
Ltmp10:
	pushq	%rax
Ltmp11:
	movq	%rdx, %rbx
	movq	%rsi, %r14
	movl	%edi, %r15d
	xorl	%r12d, %r12d
	movl	%r15d, %edi
	xorl	%esi, %esi
	callq	"_Int#><Int, Int>"
	testb	$1, %al
	jne	LBB5_3
LBB5_1:
	movl	%r15d, %eax
LBB5_2:                                 ## %break
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	ret
	.align	4, 0x90
LBB5_3:                                 ## %while
                                        ## =>This Inner Loop Header: Depth=1
	movl	%r12d, %edi
	movl	%r15d, %esi
	callq	"_Int#<<Int, Int>"
	testb	$1, %al
	je	LBB5_1
## BB#4:                                ## %while_body
                                        ##   in Loop: Header=BB5_3 Depth=1
	movl	$0, (%r14)
	movl	%r12d, %edi
	movq	%r14, %rsi
	callq	*%rbx
	xorl	%eax, %eax
	cmpl	$0, (%r14)
	jne	LBB5_2
## BB#5:                                ## %normal
                                        ##   in Loop: Header=BB5_3 Depth=1
	movl	%r12d, %edi
	movl	$1, %esi
	callq	"_Int#+<Int, Int>"
	movl	%eax, %r12d
	jmp	LBB5_3
Leh_func_end5:

	.globl	"_Int#><Int, Int>"
	.align	4, 0x90
"_Int#><Int, Int>":                     ## @"Int#><Int, Int>"
Leh_func_begin6:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp12:
	movl	%edi, %eax
	movl	%esi, %edi
	movl	%eax, %esi
	callq	_crystal_lt_int_int
	popq	%rdx
	ret
Leh_func_end6:

	.globl	"_Int#<<Int, Int>"
	.align	4, 0x90
"_Int#<<Int, Int>":                     ## @"Int#<<Int, Int>"
Leh_func_begin7:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp13:
	callq	_crystal_lt_int_int
	popq	%rdx
	ret
Leh_func_end7:

	.globl	"_Int#+<Int, Int>"
	.align	4, 0x90
"_Int#+<Int, Int>":                     ## @"Int#+<Int, Int>"
Leh_func_begin8:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp14:
	callq	_crystal_add_int_int
	popq	%rdx
	ret
Leh_func_end8:

	.section	__TEXT,__literal4,4byte_literals
	.align	2
LCPI9_0:
	.long	3222483763              ## float -2.300000e+00
LCPI9_1:
	.long	3215353446              ## float -1.300000e+00
LCPI9_2:
	.long	1028443341              ## float 5.000000e-02
LCPI9_3:
	.long	1032805417              ## float 7.000000e-02
	.section	__TEXT,__text,regular,pure_instructions
	.globl	"_&block1"
	.align	4, 0x90
"_&block1":                             ## @"&block1"
Leh_func_begin9:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp15:
	movss	LCPI9_0(%rip), %xmm0
	movss	LCPI9_1(%rip), %xmm1
	movss	LCPI9_2(%rip), %xmm2
	movss	LCPI9_3(%rip), %xmm3
	callq	"_mandel<Float, Float, Float, Float>"
	popq	%rax
	ret
Leh_func_end9:

	.globl	"_mandel<Float, Float, Float, Float>"
	.align	4, 0x90
"_mandel<Float, Float, Float, Float>":  ## @"mandel<Float, Float, Float, Float>"
Leh_func_begin10:
## BB#0:                                ## %entry
	subq	$24, %rsp
Ltmp16:
	movss	%xmm3, 20(%rsp)         ## 4-byte Spill
	movss	%xmm2, 8(%rsp)          ## 4-byte Spill
	movss	%xmm1, 16(%rsp)         ## 4-byte Spill
	movss	%xmm0, 12(%rsp)         ## 4-byte Spill
	movl	$78, %edi
	movaps	%xmm2, %xmm0
	callq	"_Float#*<Float, Int>"
	movaps	%xmm0, %xmm1
	movss	12(%rsp), %xmm0         ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movl	$40, %edi
	movss	20(%rsp), %xmm0         ## 4-byte Reload
	callq	"_Float#*<Float, Int>"
	movaps	%xmm0, %xmm1
	movss	16(%rsp), %xmm0         ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movaps	%xmm0, %xmm4
	movss	12(%rsp), %xmm0         ## 4-byte Reload
	movss	4(%rsp), %xmm1          ## 4-byte Reload
	movss	8(%rsp), %xmm2          ## 4-byte Reload
	movss	16(%rsp), %xmm3         ## 4-byte Reload
	movss	20(%rsp), %xmm5         ## 4-byte Reload
	callq	"_mandel_help<Float, Float, Float, Float, Float, Float>"
	addq	$24, %rsp
	ret
Leh_func_end10:

	.globl	"_mandel_help<Float, Float, Float, Float, Float, Float>"
	.align	4, 0x90
"_mandel_help<Float, Float, Float, Float, Float, Float>": ## @"mandel_help<Float, Float, Float, Float, Float, Float>"
Leh_func_begin11:
## BB#0:                                ## %entry
	subq	$40, %rsp
Ltmp17:
	movss	%xmm5, 20(%rsp)         ## 4-byte Spill
	movss	%xmm4, 16(%rsp)         ## 4-byte Spill
	movss	%xmm2, 28(%rsp)         ## 4-byte Spill
	movss	%xmm1, 24(%rsp)         ## 4-byte Spill
	movss	%xmm0, 12(%rsp)         ## 4-byte Spill
	movss	%xmm3, 32(%rsp)         ## 4-byte Spill
	jmp	LBB11_1
	.align	4, 0x90
LBB11_3:                                ## %while_body12
                                        ##   in Loop: Header=BB11_2 Depth=2
	movss	36(%rsp), %xmm0         ## 4-byte Reload
	movss	32(%rsp), %xmm1         ## 4-byte Reload
	callq	"_mandel_converge<Float, Float>"
	movl	%eax, %edi
	callq	"_print_density<Int>"
	movss	36(%rsp), %xmm0         ## 4-byte Reload
	movss	28(%rsp), %xmm1         ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movss	%xmm0, 36(%rsp)         ## 4-byte Spill
LBB11_2:                                ## %while11
                                        ##   Parent Loop BB11_1 Depth=1
                                        ## =>  This Inner Loop Header: Depth=2
	movss	36(%rsp), %xmm0         ## 4-byte Reload
	movss	24(%rsp), %xmm1         ## 4-byte Reload
	callq	"_Float#<<Float, Float>"
	testb	$1, %al
	jne	LBB11_3
## BB#4:                                ## %while_exit13
                                        ##   in Loop: Header=BB11_1 Depth=1
	movl	$10, %edi
	callq	"_print<Char>"
	movss	32(%rsp), %xmm0         ## 4-byte Reload
	movss	20(%rsp), %xmm1         ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movss	%xmm0, 32(%rsp)         ## 4-byte Spill
LBB11_1:                                ## %while
                                        ## =>This Loop Header: Depth=1
                                        ##     Child Loop BB11_2 Depth 2
	movss	32(%rsp), %xmm0         ## 4-byte Reload
	movss	16(%rsp), %xmm1         ## 4-byte Reload
	callq	"_Float#<<Float, Float>"
	testb	$1, %al
	movss	12(%rsp), %xmm0         ## 4-byte Reload
	movss	%xmm0, 36(%rsp)         ## 4-byte Spill
	jne	LBB11_2
## BB#5:                                ## %while_exit
	addq	$40, %rsp
	ret
Leh_func_end11:

	.globl	"_Float#<<Float, Float>"
	.align	4, 0x90
"_Float#<<Float, Float>":               ## @"Float#<<Float, Float>"
Leh_func_begin12:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp18:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movaps	%xmm1, %xmm0
	callq	"_Float#to_f<Float>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	_crystal_lt_float_float
	popq	%rdx
	ret
Leh_func_end12:

	.globl	"_Float#to_f<Float>"
	.align	4, 0x90
"_Float#to_f<Float>":                   ## @"Float#to_f<Float>"
Leh_func_begin13:
## BB#0:                                ## %entry
	ret
Leh_func_end13:

	.globl	"_print_density<Int>"
	.align	4, 0x90
"_print_density<Int>":                  ## @"print_density<Int>"
Leh_func_begin14:
## BB#0:                                ## %entry
	pushq	%rbx
Ltmp19:
Ltmp20:
	movl	%edi, %ebx
	movl	$8, %esi
	movl	%ebx, %edi
	callq	"_Int#><Int, Int>"
	testb	$1, %al
	je	LBB14_2
## BB#1:                                ## %then
	movl	$32, %edi
	jmp	LBB14_7
LBB14_2:                                ## %else
	movl	$4, %esi
	movl	%ebx, %edi
	callq	"_Int#><Int, Int>"
	testb	$1, %al
	je	LBB14_4
## BB#3:                                ## %then6
	movl	$46, %edi
	jmp	LBB14_7
LBB14_4:                                ## %else7
	movl	$2, %esi
	movl	%ebx, %edi
	callq	"_Int#><Int, Int>"
	testb	$1, %al
	je	LBB14_6
## BB#5:                                ## %then11
	movl	$43, %edi
	jmp	LBB14_7
LBB14_6:                                ## %else12
	movl	$42, %edi
LBB14_7:                                ## %else12
	callq	"_print<Char>"
	popq	%rbx
	ret
Leh_func_end14:

	.globl	"_print<Char>"
	.align	4, 0x90
"_print<Char>":                         ## @"print<Char>"
Leh_func_begin15:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp21:
	callq	_print_char
	popq	%rax
	ret
Leh_func_end15:

	.globl	"_mandel_converge<Float, Float>"
	.align	4, 0x90
"_mandel_converge<Float, Float>":       ## @"mandel_converge<Float, Float>"
Leh_func_begin16:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp22:
	xorl	%edi, %edi
	movaps	%xmm0, %xmm2
	movaps	%xmm1, %xmm3
	callq	"_mandel_converger<Float, Float, Int, Float, Float>"
	popq	%rdx
	ret
Leh_func_end16:

	.globl	"_mandel_converger<Float, Float, Int, Float, Float>"
	.align	4, 0x90
"_mandel_converger<Float, Float, Int, Float, Float>": ## @"mandel_converger<Float, Float, Int, Float, Float>"
Leh_func_begin17:
## BB#0:                                ## %entry
	pushq	%r14
Ltmp23:
	pushq	%rbx
Ltmp24:
	subq	$24, %rsp
Ltmp25:
	movss	%xmm3, 12(%rsp)         ## 4-byte Spill
	movss	%xmm2, 8(%rsp)          ## 4-byte Spill
	movl	%edi, %ebx
	movss	%xmm1, 20(%rsp)         ## 4-byte Spill
	movss	%xmm0, 16(%rsp)         ## 4-byte Spill
	movl	$255, %esi
	movl	%ebx, %edi
	callq	"_Int#><Int, Int>"
	movb	%al, %r14b
	movss	16(%rsp), %xmm0         ## 4-byte Reload
	movaps	%xmm0, %xmm1
	callq	"_Float#*<Float, Float>"
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movss	20(%rsp), %xmm0         ## 4-byte Reload
	movaps	%xmm0, %xmm1
	callq	"_Float#*<Float, Float>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movl	$4, %edi
	callq	"_Float#>=<Float, Int>"
	testb	$1, %r14b
	jne	LBB17_3
## BB#1:                                ## %entry
	testb	$1, %al
	jne	LBB17_3
## BB#2:                                ## %else
	movss	16(%rsp), %xmm0         ## 4-byte Reload
	movaps	%xmm0, %xmm1
	callq	"_Float#*<Float, Float>"
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movss	20(%rsp), %xmm0         ## 4-byte Reload
	movaps	%xmm0, %xmm1
	callq	"_Float#*<Float, Float>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	"_Float#-<Float, Float>"
	movss	8(%rsp), %xmm1          ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movl	$2, %edi
	movss	16(%rsp), %xmm0         ## 4-byte Reload
	callq	"_Int#*<Int, Float>"
	movss	20(%rsp), %xmm1         ## 4-byte Reload
	callq	"_Float#*<Float, Float>"
	movss	12(%rsp), %xmm1         ## 4-byte Reload
	callq	"_Float#+<Float, Float>"
	movss	%xmm0, 20(%rsp)         ## 4-byte Spill
	movl	$1, %esi
	movl	%ebx, %edi
	callq	"_Int#+<Int, Int>"
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	movss	20(%rsp), %xmm1         ## 4-byte Reload
	movl	%eax, %edi
	movss	8(%rsp), %xmm2          ## 4-byte Reload
	movss	12(%rsp), %xmm3         ## 4-byte Reload
	callq	"_mandel_converger<Float, Float, Int, Float, Float>"
	movl	%eax, %ebx
LBB17_3:                                ## %merge
	movl	%ebx, %eax
	addq	$24, %rsp
	popq	%rbx
	popq	%r14
	ret
Leh_func_end17:

	.globl	"_Float#>=<Float, Int>"
	.align	4, 0x90
"_Float#>=<Float, Int>":                ## @"Float#>=<Float, Int>"
Leh_func_begin18:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp26:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	callq	"_Int#to_f<Int>"
	movss	4(%rsp), %xmm1          ## 4-byte Reload
	callq	_crystal_let_float_float
	popq	%rdx
	ret
Leh_func_end18:

	.globl	"_Int#to_f<Int>"
	.align	4, 0x90
"_Int#to_f<Int>":                       ## @"Int#to_f<Int>"
Leh_func_begin19:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp27:
	callq	_crystal_to_f_int
	popq	%rax
	ret
Leh_func_end19:

	.globl	"_Float#+<Float, Float>"
	.align	4, 0x90
"_Float#+<Float, Float>":               ## @"Float#+<Float, Float>"
Leh_func_begin20:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp28:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movaps	%xmm1, %xmm0
	callq	"_Float#to_f<Float>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	_crystal_add_float_float
	popq	%rax
	ret
Leh_func_end20:

	.globl	"_Float#*<Float, Float>"
	.align	4, 0x90
"_Float#*<Float, Float>":               ## @"Float#*<Float, Float>"
Leh_func_begin21:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp29:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movaps	%xmm1, %xmm0
	callq	"_Float#to_f<Float>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	_crystal_mul_float_float
	popq	%rax
	ret
Leh_func_end21:

	.globl	"_Float#-<Float, Float>"
	.align	4, 0x90
"_Float#-<Float, Float>":               ## @"Float#-<Float, Float>"
Leh_func_begin22:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp30:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	movaps	%xmm1, %xmm0
	callq	"_Float#to_f<Float>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	_crystal_sub_float_float
	popq	%rax
	ret
Leh_func_end22:

	.globl	"_Int#*<Int, Float>"
	.align	4, 0x90
"_Int#*<Int, Float>":                   ## @"Int#*<Int, Float>"
Leh_func_begin23:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp31:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	callq	"_Int#to_f<Int>"
	movss	4(%rsp), %xmm1          ## 4-byte Reload
	callq	"_Float#*<Float, Float>"
	popq	%rax
	ret
Leh_func_end23:

	.globl	"_Float#*<Float, Int>"
	.align	4, 0x90
"_Float#*<Float, Int>":                 ## @"Float#*<Float, Int>"
Leh_func_begin24:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp32:
	movss	%xmm0, 4(%rsp)          ## 4-byte Spill
	callq	"_Int#to_f<Int>"
	movaps	%xmm0, %xmm1
	movss	4(%rsp), %xmm0          ## 4-byte Reload
	callq	_crystal_mul_float_float
	popq	%rax
	ret
Leh_func_end24:

	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
Leh_func_begin25:
## BB#0:                                ## %entry
	pushq	%rax
Ltmp33:
	callq	"L_&main1"
	xorl	%eax, %eax
	popq	%rdx
	ret
Leh_func_end25:

	.section	__TEXT,__eh_frame,coalesced,no_toc+strip_static_syms+live_support
EH_frame0:
Lsection_eh_frame0:
Leh_frame_common0:
Lset0 = Leh_frame_common_end0-Leh_frame_common_begin0 ## Length of Common Information Entry
	.long	Lset0
Leh_frame_common_begin0:
	.long	0                       ## CIE Identifier Tag
	.byte	1                       ## DW_CIE_VERSION
	.asciz	 "zR"                   ## CIE Augmentation
	.byte	1                       ## CIE Code Alignment Factor
	.byte	120                     ## CIE Data Alignment Factor
	.byte	16                      ## CIE Return Address Column
	.byte	1                       ## Augmentation Size
	.byte	16                      ## FDE Encoding = pcrel
	.byte	12                      ## DW_CFA_def_cfa
	.byte	7                       ## Register
	.byte	8                       ## Offset
	.byte	144                     ## DW_CFA_offset + Reg (16)
	.byte	1                       ## Offset
	.align	3
Leh_frame_common_end0:
	.globl	"_Class#==<Class, Class>.eh"
"_Class#==<Class, Class>.eh":
Lset1 = Leh_frame_end0-Leh_frame_begin0 ## Length of Frame Information Entry
	.long	Lset1
Leh_frame_begin0:
Lset2 = Leh_frame_begin0-Leh_frame_common0 ## FDE CIE offset
	.long	Lset2
Ltmp34:                                 ## FDE initial location
Ltmp35 = Leh_func_begin0-Ltmp34
	.quad	Ltmp35
Lset3 = Leh_func_end0-Leh_func_begin0   ## FDE address range
	.quad	Lset3
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset4 = Ltmp0-Leh_func_begin0
	.long	Lset4
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset5 = Ltmp1-Ltmp0
	.long	Lset5
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	24                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset6 = Ltmp2-Ltmp1
	.long	Lset6
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	32                      ## Offset
	.byte	131                     ## DW_CFA_offset + Reg (3)
	.byte	3                       ## Offset
	.byte	142                     ## DW_CFA_offset + Reg (14)
	.byte	2                       ## Offset
	.align	3
Leh_frame_end0:

	.globl	"_Long#==<Long, Long>.eh"
"_Long#==<Long, Long>.eh":
Lset7 = Leh_frame_end1-Leh_frame_begin1 ## Length of Frame Information Entry
	.long	Lset7
Leh_frame_begin1:
Lset8 = Leh_frame_begin1-Leh_frame_common0 ## FDE CIE offset
	.long	Lset8
Ltmp36:                                 ## FDE initial location
Ltmp37 = Leh_func_begin1-Ltmp36
	.quad	Ltmp37
Lset9 = Leh_func_end1-Leh_func_begin1   ## FDE address range
	.quad	Lset9
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset10 = Ltmp3-Leh_func_begin1
	.long	Lset10
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end1:

	.globl	"_Class#object_id<Class>.eh"
"_Class#object_id<Class>.eh":
Lset11 = Leh_frame_end2-Leh_frame_begin2 ## Length of Frame Information Entry
	.long	Lset11
Leh_frame_begin2:
Lset12 = Leh_frame_begin2-Leh_frame_common0 ## FDE CIE offset
	.long	Lset12
Ltmp38:                                 ## FDE initial location
Ltmp39 = Leh_func_begin2-Ltmp38
	.quad	Ltmp39
Lset13 = Leh_func_end2-Leh_func_begin2  ## FDE address range
	.quad	Lset13
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset14 = Ltmp4-Leh_func_begin2
	.long	Lset14
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end2:

	.globl	"_&anon.eh"
"_&anon.eh":
Lset15 = Leh_frame_end3-Leh_frame_begin3 ## Length of Frame Information Entry
	.long	Lset15
Leh_frame_begin3:
Lset16 = Leh_frame_begin3-Leh_frame_common0 ## FDE CIE offset
	.long	Lset16
Ltmp40:                                 ## FDE initial location
Ltmp41 = Leh_func_begin3-Ltmp40
	.quad	Ltmp41
Lset17 = Leh_func_end3-Leh_func_begin3  ## FDE address range
	.quad	Lset17
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset18 = Ltmp5-Leh_func_begin3
	.long	Lset18
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end3:

"L_&main1.eh":
Lset19 = Leh_frame_end4-Leh_frame_begin4 ## Length of Frame Information Entry
	.long	Lset19
Leh_frame_begin4:
Lset20 = Leh_frame_begin4-Leh_frame_common0 ## FDE CIE offset
	.long	Lset20
Ltmp42:                                 ## FDE initial location
Ltmp43 = Leh_func_begin4-Ltmp42
	.quad	Ltmp43
Lset21 = Leh_func_end4-Leh_func_begin4  ## FDE address range
	.quad	Lset21
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset22 = Ltmp6-Leh_func_begin4
	.long	Lset22
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end4:

	.globl	"_Int#times<Int>&Nil.eh"
"_Int#times<Int>&Nil.eh":
Lset23 = Leh_frame_end5-Leh_frame_begin5 ## Length of Frame Information Entry
	.long	Lset23
Leh_frame_begin5:
Lset24 = Leh_frame_begin5-Leh_frame_common0 ## FDE CIE offset
	.long	Lset24
Ltmp44:                                 ## FDE initial location
Ltmp45 = Leh_func_begin5-Ltmp44
	.quad	Ltmp45
Lset25 = Leh_func_end5-Leh_func_begin5  ## FDE address range
	.quad	Lset25
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset26 = Ltmp7-Leh_func_begin5
	.long	Lset26
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset27 = Ltmp8-Ltmp7
	.long	Lset27
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	24                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset28 = Ltmp9-Ltmp8
	.long	Lset28
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	32                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset29 = Ltmp10-Ltmp9
	.long	Lset29
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	40                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset30 = Ltmp11-Ltmp10
	.long	Lset30
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	48                      ## Offset
	.byte	131                     ## DW_CFA_offset + Reg (3)
	.byte	5                       ## Offset
	.byte	140                     ## DW_CFA_offset + Reg (12)
	.byte	4                       ## Offset
	.byte	142                     ## DW_CFA_offset + Reg (14)
	.byte	3                       ## Offset
	.byte	143                     ## DW_CFA_offset + Reg (15)
	.byte	2                       ## Offset
	.align	3
Leh_frame_end5:

	.globl	"_Int#><Int, Int>.eh"
"_Int#><Int, Int>.eh":
Lset31 = Leh_frame_end6-Leh_frame_begin6 ## Length of Frame Information Entry
	.long	Lset31
Leh_frame_begin6:
Lset32 = Leh_frame_begin6-Leh_frame_common0 ## FDE CIE offset
	.long	Lset32
Ltmp46:                                 ## FDE initial location
Ltmp47 = Leh_func_begin6-Ltmp46
	.quad	Ltmp47
Lset33 = Leh_func_end6-Leh_func_begin6  ## FDE address range
	.quad	Lset33
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset34 = Ltmp12-Leh_func_begin6
	.long	Lset34
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end6:

	.globl	"_Int#<<Int, Int>.eh"
"_Int#<<Int, Int>.eh":
Lset35 = Leh_frame_end7-Leh_frame_begin7 ## Length of Frame Information Entry
	.long	Lset35
Leh_frame_begin7:
Lset36 = Leh_frame_begin7-Leh_frame_common0 ## FDE CIE offset
	.long	Lset36
Ltmp48:                                 ## FDE initial location
Ltmp49 = Leh_func_begin7-Ltmp48
	.quad	Ltmp49
Lset37 = Leh_func_end7-Leh_func_begin7  ## FDE address range
	.quad	Lset37
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset38 = Ltmp13-Leh_func_begin7
	.long	Lset38
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end7:

	.globl	"_Int#+<Int, Int>.eh"
"_Int#+<Int, Int>.eh":
Lset39 = Leh_frame_end8-Leh_frame_begin8 ## Length of Frame Information Entry
	.long	Lset39
Leh_frame_begin8:
Lset40 = Leh_frame_begin8-Leh_frame_common0 ## FDE CIE offset
	.long	Lset40
Ltmp50:                                 ## FDE initial location
Ltmp51 = Leh_func_begin8-Ltmp50
	.quad	Ltmp51
Lset41 = Leh_func_end8-Leh_func_begin8  ## FDE address range
	.quad	Lset41
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset42 = Ltmp14-Leh_func_begin8
	.long	Lset42
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end8:

	.globl	"_&block1.eh"
"_&block1.eh":
Lset43 = Leh_frame_end9-Leh_frame_begin9 ## Length of Frame Information Entry
	.long	Lset43
Leh_frame_begin9:
Lset44 = Leh_frame_begin9-Leh_frame_common0 ## FDE CIE offset
	.long	Lset44
Ltmp52:                                 ## FDE initial location
Ltmp53 = Leh_func_begin9-Ltmp52
	.quad	Ltmp53
Lset45 = Leh_func_end9-Leh_func_begin9  ## FDE address range
	.quad	Lset45
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset46 = Ltmp15-Leh_func_begin9
	.long	Lset46
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end9:

	.globl	"_mandel<Float, Float, Float, Float>.eh"
"_mandel<Float, Float, Float, Float>.eh":
Lset47 = Leh_frame_end10-Leh_frame_begin10 ## Length of Frame Information Entry
	.long	Lset47
Leh_frame_begin10:
Lset48 = Leh_frame_begin10-Leh_frame_common0 ## FDE CIE offset
	.long	Lset48
Ltmp54:                                 ## FDE initial location
Ltmp55 = Leh_func_begin10-Ltmp54
	.quad	Ltmp55
Lset49 = Leh_func_end10-Leh_func_begin10 ## FDE address range
	.quad	Lset49
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset50 = Ltmp16-Leh_func_begin10
	.long	Lset50
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	32                      ## Offset
	.align	3
Leh_frame_end10:

	.globl	"_mandel_help<Float, Float, Float, Float, Float, Float>.eh"
"_mandel_help<Float, Float, Float, Float, Float, Float>.eh":
Lset51 = Leh_frame_end11-Leh_frame_begin11 ## Length of Frame Information Entry
	.long	Lset51
Leh_frame_begin11:
Lset52 = Leh_frame_begin11-Leh_frame_common0 ## FDE CIE offset
	.long	Lset52
Ltmp56:                                 ## FDE initial location
Ltmp57 = Leh_func_begin11-Ltmp56
	.quad	Ltmp57
Lset53 = Leh_func_end11-Leh_func_begin11 ## FDE address range
	.quad	Lset53
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset54 = Ltmp17-Leh_func_begin11
	.long	Lset54
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	48                      ## Offset
	.align	3
Leh_frame_end11:

	.globl	"_Float#<<Float, Float>.eh"
"_Float#<<Float, Float>.eh":
Lset55 = Leh_frame_end12-Leh_frame_begin12 ## Length of Frame Information Entry
	.long	Lset55
Leh_frame_begin12:
Lset56 = Leh_frame_begin12-Leh_frame_common0 ## FDE CIE offset
	.long	Lset56
Ltmp58:                                 ## FDE initial location
Ltmp59 = Leh_func_begin12-Ltmp58
	.quad	Ltmp59
Lset57 = Leh_func_end12-Leh_func_begin12 ## FDE address range
	.quad	Lset57
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset58 = Ltmp18-Leh_func_begin12
	.long	Lset58
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end12:

	.globl	"_Float#to_f<Float>.eh"
"_Float#to_f<Float>.eh" = 0
	.no_dead_strip	"_Float#to_f<Float>.eh"

	.globl	"_print_density<Int>.eh"
"_print_density<Int>.eh":
Lset59 = Leh_frame_end14-Leh_frame_begin14 ## Length of Frame Information Entry
	.long	Lset59
Leh_frame_begin14:
Lset60 = Leh_frame_begin14-Leh_frame_common0 ## FDE CIE offset
	.long	Lset60
Ltmp60:                                 ## FDE initial location
Ltmp61 = Leh_func_begin14-Ltmp60
	.quad	Ltmp61
Lset61 = Leh_func_end14-Leh_func_begin14 ## FDE address range
	.quad	Lset61
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset62 = Ltmp19-Leh_func_begin14
	.long	Lset62
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset63 = Ltmp20-Ltmp19
	.long	Lset63
	.byte	131                     ## DW_CFA_offset + Reg (3)
	.byte	2                       ## Offset
	.align	3
Leh_frame_end14:

	.globl	"_print<Char>.eh"
"_print<Char>.eh":
Lset64 = Leh_frame_end15-Leh_frame_begin15 ## Length of Frame Information Entry
	.long	Lset64
Leh_frame_begin15:
Lset65 = Leh_frame_begin15-Leh_frame_common0 ## FDE CIE offset
	.long	Lset65
Ltmp62:                                 ## FDE initial location
Ltmp63 = Leh_func_begin15-Ltmp62
	.quad	Ltmp63
Lset66 = Leh_func_end15-Leh_func_begin15 ## FDE address range
	.quad	Lset66
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset67 = Ltmp21-Leh_func_begin15
	.long	Lset67
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end15:

	.globl	"_mandel_converge<Float, Float>.eh"
"_mandel_converge<Float, Float>.eh":
Lset68 = Leh_frame_end16-Leh_frame_begin16 ## Length of Frame Information Entry
	.long	Lset68
Leh_frame_begin16:
Lset69 = Leh_frame_begin16-Leh_frame_common0 ## FDE CIE offset
	.long	Lset69
Ltmp64:                                 ## FDE initial location
Ltmp65 = Leh_func_begin16-Ltmp64
	.quad	Ltmp65
Lset70 = Leh_func_end16-Leh_func_begin16 ## FDE address range
	.quad	Lset70
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset71 = Ltmp22-Leh_func_begin16
	.long	Lset71
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end16:

	.globl	"_mandel_converger<Float, Float, Int, Float, Float>.eh"
"_mandel_converger<Float, Float, Int, Float, Float>.eh":
Lset72 = Leh_frame_end17-Leh_frame_begin17 ## Length of Frame Information Entry
	.long	Lset72
Leh_frame_begin17:
Lset73 = Leh_frame_begin17-Leh_frame_common0 ## FDE CIE offset
	.long	Lset73
Ltmp66:                                 ## FDE initial location
Ltmp67 = Leh_func_begin17-Ltmp66
	.quad	Ltmp67
Lset74 = Leh_func_end17-Leh_func_begin17 ## FDE address range
	.quad	Lset74
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset75 = Ltmp23-Leh_func_begin17
	.long	Lset75
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset76 = Ltmp24-Ltmp23
	.long	Lset76
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	24                      ## Offset
	.byte	4                       ## DW_CFA_advance_loc4
Lset77 = Ltmp25-Ltmp24
	.long	Lset77
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	48                      ## Offset
	.byte	131                     ## DW_CFA_offset + Reg (3)
	.byte	3                       ## Offset
	.byte	142                     ## DW_CFA_offset + Reg (14)
	.byte	2                       ## Offset
	.align	3
Leh_frame_end17:

	.globl	"_Float#>=<Float, Int>.eh"
"_Float#>=<Float, Int>.eh":
Lset78 = Leh_frame_end18-Leh_frame_begin18 ## Length of Frame Information Entry
	.long	Lset78
Leh_frame_begin18:
Lset79 = Leh_frame_begin18-Leh_frame_common0 ## FDE CIE offset
	.long	Lset79
Ltmp68:                                 ## FDE initial location
Ltmp69 = Leh_func_begin18-Ltmp68
	.quad	Ltmp69
Lset80 = Leh_func_end18-Leh_func_begin18 ## FDE address range
	.quad	Lset80
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset81 = Ltmp26-Leh_func_begin18
	.long	Lset81
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end18:

	.globl	"_Int#to_f<Int>.eh"
"_Int#to_f<Int>.eh":
Lset82 = Leh_frame_end19-Leh_frame_begin19 ## Length of Frame Information Entry
	.long	Lset82
Leh_frame_begin19:
Lset83 = Leh_frame_begin19-Leh_frame_common0 ## FDE CIE offset
	.long	Lset83
Ltmp70:                                 ## FDE initial location
Ltmp71 = Leh_func_begin19-Ltmp70
	.quad	Ltmp71
Lset84 = Leh_func_end19-Leh_func_begin19 ## FDE address range
	.quad	Lset84
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset85 = Ltmp27-Leh_func_begin19
	.long	Lset85
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end19:

	.globl	"_Float#+<Float, Float>.eh"
"_Float#+<Float, Float>.eh":
Lset86 = Leh_frame_end20-Leh_frame_begin20 ## Length of Frame Information Entry
	.long	Lset86
Leh_frame_begin20:
Lset87 = Leh_frame_begin20-Leh_frame_common0 ## FDE CIE offset
	.long	Lset87
Ltmp72:                                 ## FDE initial location
Ltmp73 = Leh_func_begin20-Ltmp72
	.quad	Ltmp73
Lset88 = Leh_func_end20-Leh_func_begin20 ## FDE address range
	.quad	Lset88
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset89 = Ltmp28-Leh_func_begin20
	.long	Lset89
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end20:

	.globl	"_Float#*<Float, Float>.eh"
"_Float#*<Float, Float>.eh":
Lset90 = Leh_frame_end21-Leh_frame_begin21 ## Length of Frame Information Entry
	.long	Lset90
Leh_frame_begin21:
Lset91 = Leh_frame_begin21-Leh_frame_common0 ## FDE CIE offset
	.long	Lset91
Ltmp74:                                 ## FDE initial location
Ltmp75 = Leh_func_begin21-Ltmp74
	.quad	Ltmp75
Lset92 = Leh_func_end21-Leh_func_begin21 ## FDE address range
	.quad	Lset92
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset93 = Ltmp29-Leh_func_begin21
	.long	Lset93
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end21:

	.globl	"_Float#-<Float, Float>.eh"
"_Float#-<Float, Float>.eh":
Lset94 = Leh_frame_end22-Leh_frame_begin22 ## Length of Frame Information Entry
	.long	Lset94
Leh_frame_begin22:
Lset95 = Leh_frame_begin22-Leh_frame_common0 ## FDE CIE offset
	.long	Lset95
Ltmp76:                                 ## FDE initial location
Ltmp77 = Leh_func_begin22-Ltmp76
	.quad	Ltmp77
Lset96 = Leh_func_end22-Leh_func_begin22 ## FDE address range
	.quad	Lset96
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset97 = Ltmp30-Leh_func_begin22
	.long	Lset97
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end22:

	.globl	"_Int#*<Int, Float>.eh"
"_Int#*<Int, Float>.eh":
Lset98 = Leh_frame_end23-Leh_frame_begin23 ## Length of Frame Information Entry
	.long	Lset98
Leh_frame_begin23:
Lset99 = Leh_frame_begin23-Leh_frame_common0 ## FDE CIE offset
	.long	Lset99
Ltmp78:                                 ## FDE initial location
Ltmp79 = Leh_func_begin23-Ltmp78
	.quad	Ltmp79
Lset100 = Leh_func_end23-Leh_func_begin23 ## FDE address range
	.quad	Lset100
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset101 = Ltmp31-Leh_func_begin23
	.long	Lset101
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end23:

	.globl	"_Float#*<Float, Int>.eh"
"_Float#*<Float, Int>.eh":
Lset102 = Leh_frame_end24-Leh_frame_begin24 ## Length of Frame Information Entry
	.long	Lset102
Leh_frame_begin24:
Lset103 = Leh_frame_begin24-Leh_frame_common0 ## FDE CIE offset
	.long	Lset103
Ltmp80:                                 ## FDE initial location
Ltmp81 = Leh_func_begin24-Ltmp80
	.quad	Ltmp81
Lset104 = Leh_func_end24-Leh_func_begin24 ## FDE address range
	.quad	Lset104
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset105 = Ltmp32-Leh_func_begin24
	.long	Lset105
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end24:

	.globl	_main.eh
_main.eh:
Lset106 = Leh_frame_end25-Leh_frame_begin25 ## Length of Frame Information Entry
	.long	Lset106
Leh_frame_begin25:
Lset107 = Leh_frame_begin25-Leh_frame_common0 ## FDE CIE offset
	.long	Lset107
Ltmp82:                                 ## FDE initial location
Ltmp83 = Leh_func_begin25-Ltmp82
	.quad	Ltmp83
Lset108 = Leh_func_end25-Leh_func_begin25 ## FDE address range
	.quad	Lset108
	.byte	0                       ## Augmentation size
	.byte	4                       ## DW_CFA_advance_loc4
Lset109 = Ltmp33-Leh_func_begin25
	.long	Lset109
	.byte	14                      ## DW_CFA_def_cfa_offset
	.byte	16                      ## Offset
	.align	3
Leh_frame_end25:


.subsections_via_symbols
