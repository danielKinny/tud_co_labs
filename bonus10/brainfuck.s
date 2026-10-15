.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"

.section .bss
tape:
	.zero 30000

.text

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.

# caller saved : %RAX, %RCX, %RDX, %RDI, %RSI, and %R8 through %R11
# callee saved : %RBX, %RSP, %RBP, and %R12 through %R15

brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	#saving register values
	pushq %r14 #this can be the instruction pointer
	pushq %r15 #this can be the data pointer

	movq $tape, %r15 #data pointer
	movq %rdi, %r14
	jmp fetch

next_instruction:
	incq %r14 #incremebt the instruction pointer	

fetch:
	movzbl (%r14), %eax #zero-extend the instruction into %eax
	cmpb $0, %al #check if we are zero-terminated
	je epilogue

	cmpb $'>', %al #check if the instruction is >
	je handle_greater

	cmpb $'<', %al #check if the instruction is <
	je handle_less

	cmpb $'+', %al #check if the instruction is +
	je handle_plus

	cmpb $'-', %al #check if the instruction is -
	je handle_minus

	cmpb $'.', %al #check if the instruction is .
	je handle_dot

	cmpb $',', %al #check if the instruction is ,
	je handle_comma

	cmpb $'[', %al #check if the instruction is [
	je handle_open_bracket

	cmpb $']', %al #check if the instruction is ]
	je handle_close_bracket

	jmp next_instruction #if the character isn't a valid brainfuck instruction, we can just skip it

handle_greater: # > means move the data ptr to the right
	incq %r15 #increment the data pointer
	jmp next_instruction

handle_less: # < means move the data ptr to the left
	decq %r15 #decrement the data pointer
	jmp next_instruction

handle_plus: # + means increment the byte at the data pointer
	incb (%r15)
	jmp next_instruction

handle_minus: # - means decrement the byte at the data pointer
	decb (%r15) 
	jmp next_instruction

handle_dot: # . means output the byte at the data pointer
	movzbl (%r15), %edi #zero-extend the byte at the data pointer into %edi, since %rdi is the first argument
	call putchar #call putchar, simpler than printf
	jmp next_instruction

handle_comma: # , means input a byte and store it at the data pointer
	call getchar #call getchar, since its easier than scanf
	cmpb $-1, %al #EOF check
	jne usual_store #if not EOF, store the input -> line 92

	movb $0, (%r15) #if EOF, store 0 at the data pointer
	jmp next_instruction

usual_store: 
	movb %al, (%r15)
	jmp next_instruction

handle_open_bracket: # [ means start a loop
	cmpb $0, (%r15) #check if the byte at the data pointer is zero
	jne next_instruction #if not zero, continue to the next instruction
	movq $1, %rcx #use %rcx as a depth counter
	jmp forward_loop

handle_close_bracket: # ] means end a loop
	cmpb $0, (%r15) #check if the byte at the data pointer is zero
	je next_instruction #if zero, continue to the next instruction
	movq $1, %rcx #use %rcx as a depth counter
	jmp backward_loop

forward_loop: # loop forward until we find the matching ]
	incq %r14
	movzbl (%r14), %eax
	cmpb $'[', %al
	je forward_increase_depth
	cmpb $']', %al
	je forward_decrease_depth
	
	jmp forward_loop

forward_increase_depth: # increase depth if we find a [ while searching for the matching ]
	incq %rcx
	jmp forward_loop

forward_decrease_depth: # decrease depth if we find a ] while searching for the matching ]
	decq %rcx
	cmpq $0, %rcx
	jne forward_loop
	jmp next_instruction

backward_loop: # loop backward until we find the matching [
	decq %r14
	movzbl (%r14), %eax
	cmpb $']', %al
	je backward_increase_depth
	cmpb $'[', %al
	je backward_decrease_depth

	jmp backward_loop

backward_increase_depth: # increase depth if we find a ] while searching for the matching [
	incq %rcx
	jmp backward_loop

backward_decrease_depth: # decrease depth if we find a [ while searching for the matching [
	decq %rcx
	cmpq $0, %rcx
	jne backward_loop
	jmp next_instruction


epilogue: 	

	popq %r15 #return values of caller-saved registers
	popq %r14

	movq %rbp, %rsp
	popq %rbp
	ret
