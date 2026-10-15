.text

# .include "basic.s"
.include "basic.s"

format:	.asciz "Count of Invalid Sequences: %ld\n"

.global main

# *******************************************************************************************
# Subroutine: check_validity                                                                *
# Description: checks the validity of the parenthesization of multiple strings,             *
#              as defined in Assignment 5.                                                  *
# Parameters:                                                                               *
#   first: the first string that should be checked                                          *
#   return: the number of strings that were considered invalid                              *
# *******************************************************************************************

	

check_validity:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# your code goes here!
	pushq %r12
	subq $8, %rsp				# padding
	movq $0, %r12	

loop:
	movzbl (%rdi),%eax
	testb %al,%al
	je check_if_end

	cmpb $'(', %al
	je opening

	cmpb $'[', %al
	je opening

	cmpb $'{', %al
	je opening

	cmpb $'<', %al
	je opening
	
	cmpb $')', %al
	je close_round

	cmpb $']', %al
	je close_square

	cmpb $'}', %al
	je close_curly

	cmpb $'>', %al
	je close_angle

	jmp next_char

opening:
	pushq %rax
	jmp next_char

close_round:
	leaq -16(%rbp), %rax
	cmpq %rax, %rsp       # is stack empty?
    je invalid
	cmpb $'(', (%rsp)     # is the top stack item '('?
    jne invalid
	popq %rax			  # just remove him
	jmp next_char

close_square:
	leaq -16(%rbp), %rax
	cmpq %rax, %rsp      # is stack empty?
    je invalid
	cmpb $'[', (%rsp)     # is the top stack item '('?
    jne invalid
	popq %rax			  # just remove him
	jmp next_char

close_curly:
	leaq -16(%rbp), %rax
	cmpq %rax, %rsp   # is stack empty?
    je invalid
	cmpb $'{', (%rsp)     # is the top stack item '('?
    jne invalid
	popq %rax			  # just remove him
	jmp next_char

close_angle:
	leaq -16(%rbp), %rax
	cmpq %rax, %rsp       # is stack empty?
    je invalid
	cmpb $'<', (%rsp)     # is the top stack item '('?
    jne invalid
	popq %rax			  # just remove him
	jmp next_char

next_char:
	incq %rdi
	jmp loop

check_if_end:

	leaq -16(%rbp), %rax
	cmpq %rax, %rsp
	je valid
	incq %r12
    leaq -16(%rbp), %rsp
	jmp valid

invalid:             
    incq %r12               # invalidCount++
    leaq -16(%rbp), %rsp    # clear the stack

find_next_word:
	incq %rdi
	movzbl (%rdi),%eax
	testb %al,%al
	jne find_next_word

valid:
	cmpb $0, 1(%rdi)
	je end
	incq %rdi
	jmp loop
	
end:
	movq %r12, %rsi		# print out 
	movq $format, %rdi
	movq $0, %rax
	call printf			#
	movq %r12, %rax		# return
	addq $8, %rsp			# skip past padding
	popq %r12

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

