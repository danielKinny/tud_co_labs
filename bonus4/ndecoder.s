.text
color: .asciz "\x1b[48;5;%d;38;5;%dm%c"
animation: .asciz "\x1b[%dm%c"
reset: .asciz "\x1b[0m"
.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte animations and colors                           *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************

# beloved callee-saved registers
# %rbx
# %r12
# %r13
# %r14
# %r15

look_up_table:
	.byte 0, 26, 42, 66, 105, 153, 182

jump_table:
	.quad case_0 #0 maps to ansi code 0
	.quad case_26 #26 maps to ansi code 25
	.quad case_42 #42 maps to ansi code 1
	.quad case_66 #66 maps to ansi code 2
	.quad case_105 #105 maps to ansi code 8
	.quad case_153 #153 maps to ansi code 28
	.quad case_182 #182 maps to ansi code 5

case_0:
	movq $0, %rsi
	jmp print_ansi

case_26:
	movq $25, %rsi
	jmp print_ansi

case_42:
	movq $1, %rsi
	jmp print_ansi

case_66:
	movq $2, %rsi
	jmp print_ansi

case_105:
	movq $8, %rsi
	jmp print_ansi

case_153:
	movq $28, %rsi
	jmp print_ansi

case_182:
	movq $5, %rsi
	jmp print_ansi

decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	pushq $0 #dummy value
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	movq %rdi, %rbx # move the address of $message to the first callee-saved register
	movq %rdi, %r12 # save the address for compares later

process_char:
	
	movq $0, %r15 #lets clean %r15 before we access it's lowest byte, using %r15 instead of %rsi initially because %r15 is callee-saved
	movzbl (%rbx), %r15d #move the first 8 bytes from the address within %rbx to %r15b, which is the least-significant byte of %r15

	movq $0, %r14 #clean %r14 before we use it
	movb 1(%rbx), %r14b #move the number of times the letter is to be repeated to the least-significant byte of %r14

out_loop:

	movzbl 6(%rbx), %eax
	cmpb 7(%rbx), %al
	je print_animation

	movzbl 6(%rbx), %esi
	movzbl 7(%rbx), %edx
	movq %r15, %rcx
	movq $color, %rdi
	movq $0, %rax
	call printf

loop_check:
	cmpq $1, %r14 #checks if print count is 1
	je process_next_address #jumps if true
	decq %r14 # decrements and loops if not
	jmp out_loop

process_next_address:

	movl 2(%rbx), %r13d #since bytes 3,4,5 and 6 are the next address, we can use long (4 bytes) with an offset of 2
	leaq (%r12, %r13, 8), %rbx #the long represents the offset from the base address, which is stored in r12, so we use an index as such
	cmp %rbx, %r12 #check if the next address is equal to the base, if it is, it is a flag that the program has ended
	je end_decode

	jmp process_char

end_decode:
	# epilogue
	movq $reset, %rdi
	movq $0, %rax
	call printf

	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	addq $8, %rsp #remove the dummy value from the stack

	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

print_animation:
	movzbl 6(%rbx), %esi #move the animation value to the second parameter

	movq $0, %rcx
	movq $look_up_table, %rdx
	jmp ansi_loop

loop_increment:
	incq %rcx
ansi_loop:
	movzbl (%rdx, %rcx, 1), %eax 
	cmpq %rax, %rsi
	jne loop_increment

	movq $jump_table, %rdx
	movq (%rdx, %rcx, 8), %rax
	jmp *%rax 

print_ansi:

	movq %r15, %rdx
	movq $0, %rax
	movq $animation, %rdi
	call printf
	jmp loop_check

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
