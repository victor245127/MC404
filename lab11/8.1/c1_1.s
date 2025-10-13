.data
.globl my_var
my_var: .word 10

.text
.globl increment_my_var

increment_my_var:
    addi sp, sp, -16
    sw ra, 0(sp) # salva ra

    la a0, my_var
    lw t1, 0(a0) # t1 = *myvar
    addi t1, t1, 1 # t1 = t1 + 1
    sw t1, 0(a0) # *myvar = t1

    lw ra, 0(sp) # recupera ra
    addi sp, sp, 16
    ret
