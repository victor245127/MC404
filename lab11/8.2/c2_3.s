.text
.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -16 
    sw ra, 0(sp) # salva ra
    
    li t0, 0 # i
    li t1, 100 # limite de i
    addi sp, sp, -400 # aloca array
1:
    sw t0, 0(sp) # array[i] = i
    addi sp, sp, 4 # array[i++]
    addi t0, t0, 1 # i++
    blt t0, t1, 1b # se i < 100 continua

    addi a0, sp, -400 # inicio do array

    call mystery_function_int

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

fill_array_short:
    addi sp, sp, -16
    sw ra, 0(sp)

    li t0, 0 # i
    li t1, 100 # limite de i
    addi sp, sp, -200 # aloca array
1:
    sw t0, 0(sp) # array[i] = i
    addi sp, sp, 2 # array[i++]
    addi t0, t0, 1 # i++
    blt t0, t1, 1b # se i < 100 continua

    addi a0, sp, -200 # inicio do array

    call mystery_function_short

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

fill_array_char:
    addi sp, sp, -16
    sw ra, 0(sp)

    li t0, 0 # i
    li t1, 100 # limite de i
    addi sp, sp, -100 # aloca array
1:
    sw t0, 0(sp) # array[i] = i
    addi sp, sp, 1 # array[i++]
    addi t0, t0, 1 # i++
    blt t0, t1, 1b # se i < 100 continua

    addi a0, sp, -100 # inicio do array

    call mystery_function_char

    lw ra, 0(sp)
    addi sp, sp, 16
    ret