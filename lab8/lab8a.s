.data
input_file: .asciz "image.pgm"
buffer: .space 262200 # tamanho maximo das imagens em bytes

.text
.globl _start


_start:
    la a0, input_file 
    li a1, 0
    li a2, 0
    li a7, 1024 # syscall de open pra abrir o arquivo
    ecall
    mv s0, a0 # fd do arquivo

    la a1, buffer
    li a2, 262200 # max de bytes a serem lidos
    li a7, 63
    ecall # syscall read
    mv s1, a0 # numero de bytes lidos salvo

close:
    mv a0, s0
    li a7, 57
    ecall # syscall close pra fechar o arquivo

setCanvasSize:
    la a1, buffer
    call parse_int
    mv a3, a1 # passa o buffer no estado atual (na posição do primeiro pixel) para a3
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
    li t2, 47 # / em ascii, caractere antes do 0
    li t4, 58 # : em ascii, caractere depois do 9
    addi a1, a1, 3 # pula o 'P5\n'
1: # loop 1 de parse_int
    lb t3, 0(a1) # carrega o byte em t3
    addi a1, a1, 1 # anda 1 posicao no buffer antes de verificar
    blt t2, t3, 2f # se t3 for >= 48, verificará se é menor que 58
    j 1b # retorna pro loop até achar o primeiro numero
2:
    blt t3, t4, largura # confirma que é digito numérico e salta pra salvar largura
    j 1b # volta pro loop caso t3 nao seja digito numérico
largura:
    li a0, 0 # largura
    li t2, 3 # numero de iterações
    li t4, 10
2: # loop 2 de parse_int
    lb t3, 0(a1)
    addi t3, t3, -48
    mul a0, a0, t4 # multiplica o valor anterior por 10
    add a0, a0, t3 # adiciona o novo digito ao numero
    addi a1, a1, 1 # anda no buffer
    addi t2, t2, -1 # i--
    blt x0, t2, 2b # volta pro loop se t2 > 0
    mv s2, a0 # salva largura em s2
altura:
    li a0, 0
    li t2, 3
    addi a1, a1, 1 # pula o espaco entre os numeros
3: # loop 3 de parse_int
    lb t3, 0(a1)
    addi t3, t3, -48
    mul a0, a0, t4
    add a0, a0, t3
    addi a1, a1, 1
    addi t2, t2, -1
    blt x0, t2, 3b # volta pro loop se t2 > 0
    mv s3, a0 # salva altura em s3
    addi a1, a1, 5 # pula o '\n' e o '255\n'
    ret

pixel_by_pixel:
    li a1, 0 # y
    li t0, 10 # '\n'
    mv a5, s2 # copia largura para a5
    mv a6, s3 # copia altura para a6
    li a4, 255 # alpha
1: # loop de y
    li a0, 0 # x
    jal t6, verifica_enter # pula pra verifica_enter
2: # loop de x
    lbu t2, 0(a3) # carrega byte de (x,y) 
    slli t3, t2, 24 # R
    slli t4, t2, 16 # G
    slli t5, t2, 8 # B
    or a2, t3, t4 # R | G
    or a2, a2, t5 # R | G | B
    or a2, a2, a4 # R | G | B | A
    li a7, 2200 # syscall setPixel
    ecall
    addi a0, a0, 1 # x++
    addi a3, a3, 1 # anda uma posicao no buffer
    blt a0, a5, 2b # x < largura volta pro loop x
    addi a1, a1, 1 # y++
    blt a1, a6, 1b # y < altura volta pro loop
verifica_enter:
    lbu t2, 0(a3) # carrega byte em t2
    bne t2, t0, 2b # caso byte != '\n', vai pro loop de x
    addi a3, a3, 1 # anda para pular o '\n'
    jalr x0, t6, 0 # retorna para loop de x
return:
    ret
    

    
    





