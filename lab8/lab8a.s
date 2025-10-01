.data
input_file: .asciz "image.pgm"
buffer: .space 262160

.text
.globl _start

parse_int:
    mv t6, a1 # move buffer para t6
    addi t6, t6, 3 # pula P5 whitespace
    li t3, 10
    li t4, 48
    li t5, 58
    li a0, 0

1:
    lb t0, 0(t6) # numero em t0
    blt t0, t4, 2f # < '0', salva numero
    bge t0, t5, 2f # numero > '9', salva numero

    mul a0, a0, t3 # multiplica numero antigo por 10
    addi t0, t0, -48
    add a0, a0, t0 # adiciona digito
    addi t6, t6, 1 # anda no buffer
    j 1b

2:
    bne s2, x0, 3f # se s2 nao for 0, salva altura
    mv s2, a0 # salva largura em s2
    li a0, 0 # zera a0
    addi t6, t6, 1 # anda no buffer
    j 1b

3:
    mv s3, a0 # salva altura em s3
    addi t6, t6, 5 # pula maxval + whitespace
    mv s4, t6 # salva posicao inicial dos pixels em s4
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

    mv a0, s0
    li a7, 57 # syscall close
    ecall

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
    li a7, 93 # syscall exit
    li a0, 0
    ecall
