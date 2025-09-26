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
    mv a2, a1 # passa o buffer no estado atual (na posição do primeiro pixel) para a2
    mv a0, s2 # largura
    mv a1, s3 # altura
    li a7, 2201 # syscall para definir tamanho do canvas
    ecall
montar_imagem:

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
    li t0, 0 # y
    mv t2, a2 # buffer em t2
    li t3, 255 # alpha
1: # loop y da função
    li t1, 0 # x
2: # loop x da função
    mul t4, t0, s2 # t4 = y * largura (linha atual)
    add t4, t4, t1





