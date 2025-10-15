.text
.globl node_creation

node_creation:
    addi sp, sp, -16
    sw ra, 0(sp)

    addi t0, sp, 4 # pula ra
    li t1, 30
    sw t1, 0(t0) # a

    li t1, 25
    sb t1, 4(t0) # b
    
    li t1, 64
    sb t1, 5(t0) # c

    li t1, -12 
    sh t1, 6(t0) # d

    mv a0, t0

    call mystery_function

    lw ra, 0(sp)
    addi sp, sp, 16
    ret