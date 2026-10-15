.global predict_branch
.global actual_branch
.global init

# caller saved : %RAX, %RCX, %RDX, %RDI, %RSI, and %R8 through %R11
# callee saved : %RBX, %RSP, %RBP, and %R12 through %R15

.section .data
history:
	.byte 0

.section .bss
.align 8
past_branches:
	.skip 2048 #assignment hint lets us know there are 2048 possible brancheswehat,

.text

init:
	pushq	%rbp
	movq	%rsp, %rbp

	#since past_branches is a global variable, we should focus on also initialising it to a default value for each byte
	leaq past_branches(%rip), %rdi
	movq $20, %rcx #we put the value 20 so that the branch is more likely to be taken initially
	movq $0, %rax
ini_loop:
	movb %cl, (%rdi,%rax,1) #store the initial value in the table
	incq %rax #increment the index counter
	cmpq $2048, %rax #check if end of table has been reached
	jl ini_loop #if its lesser than 2048, we jump back into the loop

	movq	%rbp, %rsp
	popq	%rbp
	ret

predict_branch:
	pushq	%rbp
	movq	%rsp, %rbp

	movq %rdi, %rax
	andq $0x7FF, %rax #hash the address to its last 11 bits

	leaq history(%rip), %rdx #load address of history table in %rdx
	movzbl (%rdx), %ecx #fetches value of history
	andq $0X1F, %rcx #hash the history to its last 5 bits, 0x1f is 11111
	xorq %rcx, %rax #further hash it by xoring the masked history address, with the masked branch address

	leaq past_branches(%rip), %rdx
	movzbl (%rdx, %rax,1), %eax #fetches value of prediction from past_branches

	cmpq $15, %rax #check if the prediction is greater than 15, which is the mid point of 31 and 0
	jle not_taken #if its lesser than, dont take the branch
	movq $1, %rax #else, take the branch
	jmp epilogue

not_taken:
	movq $0, %rax
	jmp epilogue

epilogue:
	movq	%rbp, %rsp
	popq	%rbp
	ret


#remember that %rdi is the branch address
# %rsi is the real outcome
actual_branch:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq %r12
	pushq %r13

	movq %rdi, %r12
	andq $0x7FF, %r12 #hash the address to its last 11 bits

	leaq history(%rip), %rdx
	movzbl (%rdx), %r8d #fetches value of history
	andq $0X1F, %r8 #hash the history to its last 5 bits
	xorq %r8, %r12 #further hash it by xoring the masked history address, with the masked branch address

	leaq past_branches(%rip), %r13
	movq $0, %rcx #initialise

	cmpq $0, %rsi #see whether the actual outcome was that it was taken or not
	je was_not_taken

was_taken:
	movzbl (%r13, %r12, 1), %ecx #fetches the prediction value for the same branch
	cmpq $31, %rcx #check if the prediction value is maxed out
	je actual_epilogue #if so, then we dont need to update it
    incq %rcx #if not we increment it by one
	movb %cl, (%r13, %r12,1) #store the outcome into the real table
	jmp actual_epilogue

was_not_taken:
	movzbl (%r13, %r12, 1), %ecx #fetches the prediction value for the same branch
	cmpq $0, %rcx #check if the prediction value is minned out
	je actual_epilogue #if so, then we dont need to update it
	decq %rcx #if not we decrement it by one
	movb %cl, (%r13, %r12,1) #store the outcome into the real table

actual_epilogue:

	movzbl (%rdx), %r9d #fetches value of history
	shlq $1, %r9
	orq %rsi, %r9
	movb %r9b, (%rdx) #store the outcome into the history table

	popq %r13
	popq %r12  #restore callee-saved registers

	movq	%rbp, %rsp
	popq	%rbp
	ret
