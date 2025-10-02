.data
input_file: .asciz "image.pgm"
w_matrix: .space 9
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
    li t2, 0 # sempre que x for 0, o pixel vai ser 0 (bordas)
    j 4f

2: # loop de x
    li t2, 0 # kernel inicial
    
    addi t0, s2, -1 # largura -1
    beq a0, t0, 4f # se x = largura-1, é borda

    addi t0, s3, -1 # altura -1
    beq a1, x0, 4f # se y = 0, é borda
    beq a1, t0, 4f # se y = altura-1, é borda  

    mv a3, s1 # copia inicio da matriz w para a3
    mul t0, a1, s2 # offset de (x,y), y * largura 
    add t0, t0, a0  # t0 + x
    add t1, s4, t0 # endereço do pixel em t1 (posição inicial + offset)

    sub t3, t1, s2 # posicoes acima do pixel atual
    li a7, 2
    li t4, -1
    jal s11, 3f

    mv t3, t1 # linha atual 
    li a7, -2
    li t4, -1
    jal s11, 3f

    add t3, t1, s2 # posicoes abaixo do pixel atual
    li a7, -2
    li t4, -1
    jal s11, 3f

    j 4f

3:
    add t5, t3, t4 # posicao atual da matriz
    lbu t6, 0(t5) # byte da matriz
    lb a5, 0(a3) # w[k]
    mul a6, t6, a5 # byte * w[k]
    add t2, t2, a6 # soma com numero anterior

    addi a3, a3, 1 # anda na matriz w
    addi t4, t4, 1 # anda na matriz Mout
    blt t4, a7, 3b # t4 < 2 volta no loop
    jalr x0, s11, 0

4:
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



set_w:
    la s1, w_matrix # matriz w ficara em s1
    mv t3, s1 # copia matriz para t3
    li t0, 9 # quantidade de iteracoes
    li t1, -1
    li t2, 8
    li t4, 5 # onde vai estar o 8

1:
    jal a0, 3f # salta pra condicional
2:

    sb t1, 0(t3) # salva -1 nas posicoes
    addi t3, t3, 1 # anda na matriz
    addi t0, t0, -1 # i--
    blt x0, t0, 1b # t0 > 0
    j 4f

3:
    bne t0, t4, 2b # verifica se posicao for central, se nao, volta pro loop
    sb t2, 0(t3) # salva 8 no centro
    jalr x0, a0, 0

4:
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
    call set_w

    call pixel_by_pixel

end:
    li a7, 93 # syscall exit
    li a0, 0
    ecall
