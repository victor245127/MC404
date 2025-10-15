.text
.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -416 # array + caber o ra
    sw ra, 400(sp) # salva ra
    
    li t0, 0 # i
    li t1, 100 # limite de i
1:
    slli t2, t0, 2 # offset
    add t3, sp, t2 # array[i]
    sw t0, 0(t3) # = i
    addi t0, t0, 1 # i++
    blt t0, t1, 1b # se i < 100 continua

    mv a0, sp # array[0]

    call mystery_function_int

    lw ra, 400(sp)
    addi sp, sp, 416
    ret

fill_array_short:
    addi sp, sp, -224 # array + ra
    sw ra, 208(sp)

    li t0, 0 # i
    li t1, 100 # limite de i
1:
    slli t2, t0, 1 # offset
    add t3, sp, t2 # array[i]
    sw t0, 0(t3)
    addi t0, t0, 1 # i++
    blt t0, t1, 1b # se i < 100 continua

    mv a0, sp # array[0]

    call mystery_function_short

    lw ra, 208(sp)
    addi sp, sp, 224
    ret

fill_array_char:
    addi sp, sp, -128
    sw ra, 112(sp)

    li t0, 0 # i
    li t1, 100 # limite de i
1:
    add t3, sp, t0 # array[i]
    sw t0, 0(t3) # = i
    addi t0, t0, 1 # i++
    blt t0, t1, 1b # se i < 100 continua

    mv a0, sp # array[0]

    call mystery_function_char

    lw ra, 112(sp)
    addi sp, sp, 128
    ret