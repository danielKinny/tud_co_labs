.text
information: .asciz "\n Our names are Daniel and Mark and our NetIDs are dkinny and mpledger and the name of this assignment is 'Powers' \n"
baseprompt: .asciz "\n Please enter a number n: "
input: .asciz "%ld"
outstr: .asciz "\n The result of the factorial is %ld \n"

.global main

#parameter order
#%rdi
#%rsi
#%rcx
#%r8
#%r9

main:

    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax #since printf takes %rax as an input for a vector register, we ensure its 0
    movq $information, %rdi #rdi is the register that holds the first argument to a function
    call printf #printf takes the first paramter as the print string

    movq $0, %rax
    movq $baseprompt, %rdi #beginning of prompt to extract base
    call printf
    
    subq $16, %rsp #reserves 2 spaces on the stack for two inputs, also because the stack must be aligned in terms of 16 bytes

    movq $input, %rdi #move input format string into first argument register
    leaq -16(%rbp), %rsi #load the address of the first reserved space into %rsi, which is the second argument register
    call scanf #scanf takes %rdi as format string, and %rsi as the return address for user input

    movq -16(%rbp), %rdi #move previously stored base into rdi to be used as the first parameter according to calling conventiions.
    call factorial # -> line 52

    movq %rax, %rsi # %rax is a return value from pow, so we move it into %rsi to be used as a second paramter for string literal $output
    movq $outstr, %rdi #move output format string into first argument register
    movq $0, %rax #scrub value of %rax
    call printf

    #epilogue
    movq %rbp, %rsp #ensures stack pointer is restored to the value it was before function was called
    popq %rbp

end: 
    movq $0, %rdi #exit code 0, success!
    call exit

factorial:

    #prologue
    pushq %rbp
    movq %rsp, %rbp

    #parameter %rdi holds the value of n

    cmpq $1, %rdi #check if reached the base case
    jle endfactorial #if true, end func

    pushq %rdi #save value of n on the stack
    decq %rdi #decrement %rdi so that it can be passed into the next call
    call factorial
    popq %rdi #restores the value of n into rdi

    mulq %rdi #multiply value into %rax

    #epilogue
    movq %rbp, %rsp
    popq %rbp
    ret

endfactorial:

    movq $1, %rax

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret


