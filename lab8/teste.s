.data
input_file: .asciz "image.pgm"
buffer: .space 262160

.text
.globl _start

_start:
    la a0, input_file
    li a1, 0
    li a2, 0
    li a7, 1024 # syscall open
    ecall
    mv s0, a0

    mv a0, s0
    la a1, buffer
    li a2, 262160
    li a7, 63 # syscall read
    ecall
    mv s1, a0 # tamanho lido

setCanvasSize:
    la a1, buffer
    call parse_int

    mv a0, s2
    mv a1, s3 
    li a7, 2201 # syscall setCanvasSize
    ecall 

montar_imagem:
    call pixel_by_pixel

end:
    mv a0, s0
    li a7, 57 # syscall close
    ecall

    li a0, 0
    li a7, 93 # syscall exit
    ecall



parse_int:
    mv t6, a1
    addi t6, t6, 3 # pula 'P5\n'
    li a0, 0
    li s2, 0
    li t0, 35 # '#'
    li t1, 10
    li t3, 48 # '0'
    li t5, 58 # ':'
    lbu t2, 0(t6)
    beq t2, t0, 1f # se caractere for #, pula ate o fim dos comentarios
    j 2f

1:  
    addi t6, t6, 1
    lbu t2, 0(t6) 
    bne t2, t1, 1b # se caractere for diferente de \n, continua ate o fim do comentario
    addi t6, t6, 1 # pula o '\n'

2:
    lbu t2, 0(t6)
    mul a0, a0, t1 # multiplica por 10 valor anterior
    addi t2, t2, -48 # numero
    add a0, a0, t2 # soma
    addi t6, t6, 1

    lbu t4, 0(t6)
    blt t4, t3, 3f # se prox caractere < '0', salva numero
    bge t4, t5, 3f # se >= ':', salva numero
    j 2b

3:
    bne s2, x0, 4f # se s2 for != 0, salva altura
    mv s2, a0 # largura em s2
    li a0, 0
    j 2b

4:
    mv s3, a0 # altura em s3
    addi t6, t6, 5 # pula 255\n
    mv s4, t6 # salva estado atual do buffer em s4
    ret




pixel_by_pixel:
    li a1, 0 # y    
    li a4, 255 # alpha

1: # loop de y
    li a0, 0 # x

2: # loop de x
    mul t0, a1, s2 # offset de (x,y), y * largura 
    add t0, t0, a0  # t0 + x
    add t1, s4, t0 # endereço do pixel em t1 (posição inicial + offset)
    lbu t2, 0(t1) # carrega byte de (x,y) 

    slli t3, t2, 24 # R
    slli t4, t2, 16 # G
    slli t5, t2, 8 # B

    or a2, t3, t4 # R | G
    or a2, a2, t5 # R | G | B
    or a2, a2, a4 # R | G | B | A
    li a7, 2200 # syscall setPixel
    ecall

    addi a0, a0, 1 # x++
    blt a0, s2, 2b # x < largura volta pro loop x

    addi a1, a1, 1 # y++
    blt a1, s3, 1b # y < altura volta pro loop

return:
    ret


