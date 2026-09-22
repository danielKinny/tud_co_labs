.text
information: .asciz "\n Our names are Daniel and Mark and our NetIDs are dkinny and mpledger and the name of this assignment is 'Powers' \n"
baseprompt: .asciz "\n Please enter a non-negative base: "
expprompt: .asciz "\n Please enter an exponent: "
input: .asciz "%ld"
output: .asciz "\n The result is: %ld \n"

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

    movq $baseprompt, %rdi #beginning of prompt to extract base
    call printf
    
    subq $16, %rsp #reserves 2 spaces on the stack for two inputs, also because the stack must be aligned in terms of 16 bytes

    movq $input, %rdi #move input format string into first argument register
    leaq -16(%rbp), %rsi #load the address of the first reserved space into %rsi, which is the second argument register
    call scanf #scanf takes %rdi as format string, and %rsi as the return address for user input

    movq $expprompt, %rdi #beginning of prompt to extract exponent
    call printf #prints prompt specified in %rdi
    
    movq $input, %rdi #input string moved into first printf argument
    leaq -8(%rbp), %rsi #address of the second reserved space loaded into %rsi, prepared as return address for scanf
    call scanf

    movq -8(%rbp), %rsi #move the exponent into rsi to be used as the second param
    movq -16(%rbp), %rdi #move previously stored base into rdi to be used as the first parameter according to calling conventiions.
    call pow # -> line 60

    movq %rax, %rsi # %rax is a return value from pow, so we move it into %rsi to be used as a second paramter for string literal $output
    movq $output, %rdi #output string, string literal formatted to display the result
    movq $0, %rax #scrub value of %rax
    call printf

    #epilogue
    movq %rbp, %rsp #ensures stack pointer is restored to the value it was before function was called
    popq %rbp

end: 
    movq $0, %rdi #exit code 0, success!
    call exit

pow:

    #parameters passed into the program:
    #%rdi -> base
    #%rsi -> exp


    #prologue
    pushq %rbp
    movq %rsp, %rbp

    #boundary check, so if the exponent is 0 we return 1
    cmpq $0, %rsi #recall that the rsi register holds the value of the exponent
    movq $1, %rax #according to conventions, rax holds the first return value of the program, so set it to 1
    je endpow #jumps to the label dictating the return address since the exp is 0

    /*
    * the logic behind calculating the power of a number in this program will be as follows,
    * we will use a for/while (?) loop to multiply the base by the base N number of times where N is the exponent.
    */

    # %rax is a register that will hold a return value, as well as be the base value.

    movq %rdi, %rax # we move the value of the base into rax, which is used as both a paramter and return address for the multiplication

while:

    cmpq $1, %rsi #check if exp is 1
    je endpow #if so, jump to end of subroutine

    mulq %rdi #remember that %rax contains the base, so mulq %rdi is %rax/%rdx = %rax * %rdi
    decq %rsi #decrement the exponent 
    jmp while #loop

endpow:

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret

