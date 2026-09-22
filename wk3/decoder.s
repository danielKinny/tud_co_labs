.text
str: .asciz "%c"

.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
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

decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq %rdi, %rbx # move the address of $message to the first callee-saved register
	movq %rdi, %r12 # save the address for compares later

process_char:
	
	movq $0, %r15 #lets clean %r15 before we access it's lowest byte, using %r15 instead of %rsi initially because %r15 is callee-saved
	movb (%rbx), %r15b #move the first 8 bytes from the address within %rbx to %r15b, which is the least-significant byte of %r15

	movq $0, %r14 #clean %rcx before we use it
	movb 1(%rbx), %r14b #move the number of times the letter is to be repeated to the least-significant byte of %rcx

out_loop:

	movq $0, %rax #scrub %rax for printf
	movq $str, %rdi #move string literal as first param
	movq %r15, %rsi #move char val as second param
	call printf

	cmp $1, %r14 #checks if print count is 1
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
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

