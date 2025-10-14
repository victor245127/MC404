.text 
.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

middle_value_int:
    srai t0, a1, 1 # n/2
    slli t1, t0, 2 # offset*4 (tamanho do int)
    add t1, a0, t1 # array[0+n/2]
    lw a0, 0(t1)
    ret

middle_value_short:
    srai t0, a1, 1 # n/2
    slli t1, t0, 1 # offset*2 (tamanho do short)
    add t1, a0, t1 # array[0+n/2]
    lh a0, 0(t1)
    ret

middle_value_char:
    srai t0, a1, 1 # n/2
    add t0, a0, t0 # array[0+n/2]
    lb a0, 0(t0)
    ret

value_matrix:
    li t0, 42
    mul t1, a1, t0 # indice r
    add t1, t1, a2 # c
    slli t1, t1, 2 # offset*4 (tamanho do int)
    add t2, a0, t1 # matrix[r][c]
    lw a0, 0(t2)
    ret