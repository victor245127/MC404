.data
input_file: .asciz "image.pgm"
buffer: .space 262400 # tamanho maximo das imagens em bytes

.text
.globl _start


_start:
    la a0, input_file 
    li a1, 0
    li a2, 0
    li a7, 1024 # syscall de open pra abrir o arquivo
    ecall
    mv s0, a0 # fd do arquivo

    mv a0, s0
    la a1, buffer
    li a2, 262400 # max de bytes a serem lidos
    li a7, 63
    ecall # syscall read
    mv s1, a0 # numero de bytes lidos salvo

close:
    li a0, 3
    li a7, 57
    ecall # syscall close pra fechar o arquivo

setCanvasSize:
    la a1, buffer
    call parse_int

    mv s4, a1 # posicao inicial da leitura dos bits
    mv a0, s2 # largura
    mv a1, s3 # altura

    li a7, 2201 # syscall para definir tamanho do canvas
    ecall

montar_imagem:
    call pixel_by_pixel

end:
    li a0, 0
    li a1, 93
    ecall # syscall exit



parse_int:
    addi a1, a1, 3 # pula o 'P5\n'
    li a0, 0
    li t3, 10
    li t5, 20 # ' '

1:
    lbu t0, 0(a1) # caractere
    addi t0, t0, -48 # numero
    mul a0, a0, t3 # multiplica valor anterior por 10
    add a0, a0, t0 # adiciona digito
    addi a1, a1, 1 # anda no buffer

    lbu t4, 0(a1) # carrega caractere seguinte
    beq t4, t5, 2f # se for ' ' salva largura e comeca a calcular altura
    beq t4, t3, 3f # se for '\n' fim
    j 1b

2:
    mv s2, a0 # salva largura
    addi a1, a1, 1
    j 1b

3:
    mv s3, a0 # salva altura
    addi a1, a1, 5 # pula '255\n'
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

