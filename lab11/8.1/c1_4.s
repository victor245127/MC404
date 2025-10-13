.text 
.globl operation

operation:
    addi sp, sp, -16
    sw ra, 0(sp)

    add a0, a1, a2 # b + c, soma 1
    sub a0, a0, a5 # diff 1
    add a0, a0, a7 # soma 2

    lw t0, 24(sp) # k
    add a0, a0, t0 # soma 3

    lw t0, 32(sp) # m
    sub a0, a0, t0 # diff 2

    lw ra, 0(sp)
    addi sp, sp, 16
    ret