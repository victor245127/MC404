.data
input1: .skip 0x5 # linha 1 entrada
input2: .skip 0x8 # linha 2 entrada
output1: .skip 0x8 # linha 1 saida
output2: .skip 0x5 # linha 2 saida
output3: .skip 0x2 # linha 3 saida
erro: .byte 0

.text
.globl _start    

verifica_erro:
    xor t4, a0, a1
    xor t4, t4, a2
    xor t4, t4, a3 # dx^dx^dx^px para verificar se ha erro
    la a4, erro
    sb t4, 0(a4) # salva se ha erro ou nao
    ret

_start:
encoding:
    li a0, 0 # fd = stdin
    la a1, input1 
    li a2, 5 # le 5 bytes
    li a7, 63 # syscall read
    ecall

    la t0, input1
    lb t1, 0(t0)
    addi s0, t1, -48

    lb t1, 1(t0)
    addi s1, t1, -48 # d2

    lb t1, 2(t0)
    addi s2, t1, -48 # d3

    lb t1, 3(t0)
    addi s3, t1, -48 # d4

    xor s4, s0, s1 
    xor s4, s4, s3 # d1^d2^d4 = p1 (salvo em s4)

    xor s5, s0, s2
    xor s5, s5, s3 # d1^d3^d4 = p2 (em s5)
    
    xor s6, s1, s2
    xor s6, s6, s3 # d2^d3^d4 = p3 (em s6)

    addi s0, s0, 48
    addi s1, s1, 48
    addi s2, s2, 48
    addi s3, s3, 48
    addi s4, s4, 48
    addi s5, s5, 48
    addi s6, s6, 48 # converte de volta para ascii

    la a0, output1
    sb s4, 0(a0)
    sb s5, 1(a0)
    sb s0, 2(a0)
    sb s6, 3(a0)
    sb s1, 4(a0)
    sb s2, 5(a0)
    sb s3, 6(a0)
    li t1, 10
    sb t1, 7(a0) # salva os bits nas posicoes certas no output 1 e adiciona '\n' no fim

decoding:
    li a0, 0 # fd = stdin
    la a1, input2
    li a2, 8 # le 8 bytes
    li a7, 63 # syscall read
    ecall

    lb t1, 2(a1)
    mv s0, t1 # d1

    lb t1, 4(a1)
    mv s1, t1 # d2

    lb t1, 5(a1)
    mv s2, t1 # d3

    lb t1, 6(a1)
    mv s3, t1 # d4

    lb t1, 0(a1)
    mv s4, t1 # p1

    lb t1, 1(a1)
    mv s5, t1 # p2

    lb t1, 3(a1)
    mv s6, t1 # p3

    la a0, output2
    sb s0, 0(a0)
    sb s1, 1(a0)
    sb s2, 2(a0)
    sb s3, 3(a0) # d1d2d3d4
    li t1, 10
    sb t1, 4(a0) # '\n' no fim

    addi a0, s0, -48 # d1
    addi a1, s1, -48 # d2
    addi a2, s3, -48 # d4
    addi a3, s4, -48 # p1

    call verifica_erro
    lb t0, 0(a4)
    bnez t0, write # se ja tem um erro, nao precisa verificar os outros

    addi a1, s2, -48 # d3 no lugar de d2
    addi a3, s5, -48 # p2 no lugar de p1

    call verifica_erro
    lb t0, 0(a4)
    bnez t0, write 

    addi a0, s1, -48 # d2 no lugar de d1
    addi a3, s6, -48 # p3 no lugar de p2

    call verifica_erro

write:
    la a0, output3
    lb t0, 0(a4)
    addi t0, t0, 48 # transforma erro em ascii
    sb t0, 0(a0)
    li t1, 10
    sb t1, 1(a0) # '\n' no final

    li a0, 1 # fd = stdout
    la a1, output1 
    li a2, 8 # imprime 8 bytes
    li a7, 64 # syscall write
    ecall

    li a0, 1 # fd = stdout
    la a1, output2
    li a2, 5 # imprime 5 bytes
    li a7, 64 # syscall write
    ecall

    li a0, 1 # fd = stdout
    la a1, output3
    li a2, 2 # imprime 2 bytes
    li a7, 64 # syscall write
    ecall

end:
    li a0, 0
    li a7, 93 # syscall exit
    ecall
    