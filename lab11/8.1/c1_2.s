.text
.globl my_function

my_function:
    addi sp, sp, -16
    sw ra, 0(sp)

    sw a0, 4(sp) # a 
    sw a1, 8(sp) # b
    sw a2, 12(sp) # c

    add a0, a0, a1 # a + b, sum 1
    lw a1, 4(sp) # a no segundo parametro
    call mystery_function # call 1

    lw t1, 8(sp) # b
    lw t2, 12(sp) # c
    sub t5, t1, a0 # diff 1
    add t5, t5, t2 # sum 2, aux
    
    mv a0, t5 # parametros da call 2
    mv a1, t1
    call mystery_function # call 2

    lw t2, 12(sp)
    sub a0, t2, a0 # diff 2
    add a0, a0, t5 # sum 3

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

