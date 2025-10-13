.text 
.globl operation

operation:
    addi sp, sp, -16
    sw ra, 40(sp)

    mv t0, a0 # salvando os 6 primeiros termos
    mv t1, a1
    mv t2, a2
    mv t3, a3
    mv t4, a4
    mv t5, a5

    lw a0, 36(sp) # n
    lw a1, 32(sp) # m
    lw a2, 28(sp) # l
    lw a3, 24(sp) # k
    lw a4, 20(sp) # j
    lw a5, 16(sp) # i

    sw t0, 20(sp) # a
    sw t1, 16(sp) # b
    sw t2, 12(sp) # c
    sw t3, 8(sp) # d
    sw t4, 4(sp) # e
    sw t5, 0(sp) # f

    mv t0, a6
    mv a6, a7 # h
    mv a7, t0  # g

    call mystery_function

    lw ra, 40(sp)
    addi sp, sp, 16
    ret    

