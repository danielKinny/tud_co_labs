.text
information: .asciz "\n Our names are Daniel and Mark and our NetIDs are dkinny and mpledger and the name of this assignment is 'Powers' \n"

.global main

main:

    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax
    movq $information, %rdi
    call printf

    #epilogue
    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit
