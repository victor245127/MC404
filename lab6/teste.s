.data
input1: .space 12
input2: .space 20
output: .space 12

.text
.globl _start

conversao_int:
    mv t0, a1 # copia buffer para t0
    li a3, 10
    li a0, 0 # numero
    li t4, 4 # numero de iteracoes
    lb t1, 0(t0) # carrega +/-/0-9 
    li t3, 1
    li t2, 45
    blt t2, t1, loop1 # se t1 for numero, salta direto pro loop
    addi t0, t0, 1 # anda 1 posicao pra pular o sinal
    blt t1, t2, loop1 # se t1 for '+', salta pro loop
    addi t3, x0, -1 # numero eh negativo
loop1:
    lb t1, 0(t0)
    addi t1, t1, -48 # ascii
    mul a0, a0, a3 # multiplica por 10 o valor anterior
    add a0, a0, t1 # adiciona o valor ao numero
    addi t0, t0, 1 # anda uma posicao
    addi t4, t4, -1 # i--
    bnez t4, loop1 # t4 > 0
    mul a0, a0, t3 #  multiplica por +/-1
    ret

raiz:
    mv t0, a0 # parametro y
    srai t1, t0, 1 # k = y/2
    li t2, 21 # quantidade de iteracoes
loop2:
    beqz t1, div_por_zero # evita divisao por 0
    div t3, t0, t1 # y/k
    add t1, t1, t3 # k + y/k
    srai t1, t1, 1 # k' = (k+y/k)/2
    addi t2, t2, -1 # i--
    bnez t2, loop2 # t2 > 0
div_por_zero:
    mv a0, t1
    ret

conversao_ascii:
    mv t0, a1 # copia buffer de saida em t0
    li t1, 1000 # divisor maximo
    li t2, 10
    li t5, 4 # quantidade de iteracoes
    mv t3, a0 # numero
    blt t3, x0, negativo # pula direto pro loop se numero > 0
    li t4, 43 # '+'
    sb t4, 0(t0)
    addi t0, t0, 1 # anda 1 posicao
    j loop3 # salta para loop
negativo:
    neg t3, t3 # t3 = -t3
    li t4, 45 # '-'
    sb t4, 0(t0) 
    addi t0, t0, 1 # anda 1 posicao
loop3:
    div t4, t3, t1 # t4 = a0 / t0 
    rem t3, t3, t1 # t3 %= t1
    addi t4, t4, 48 # converte para ASCII
    sb t4, 0(t0) # escreve o digito no buffer
    addi t0, t0, 1 # avanca no buffer
    div t1, t1, a3 # t1 /= 1
    addi t5, t5, -1 # i--
    bnez t5, loop3 # t5 > 0
    ret

distancia:
    mv t0, s5 # Tr eh padrao em todas as distancias
    mv t1, a1 # Ta/b/c em t1
    li t2, 3 # vel da onda * nanosec * 10
    li t3, 10
    sub a0, t0, t1 # Tr - Tx
    mul a0, a0, t2
    div a0, a0, t3 
    ret # retorna Da/b/c em a0


_start:
    li a0, 0 # fd = 0 (stdin)
    la a1, input1 # aloca inbuf1
    li a2, 12 # le 12 bytes
    li a7, 63 # syscall read
    ecall

    li a0, 0 # fd = 0 (stdin)
    la a1, input2 # aloca inbuf1
    li a2, 20 # le 20 bytes
    li a7, 63 # syscall read
    ecall 

    la a1, input1
    call conversao_int
    mv s0, a0 # Yb

    addi a1, a1, 6
    call conversao_int
    mv s1, a0 # Xc

    la a1, input2
    call conversao_int
    mv s2, a0 # Ta

    addi a1, a1, 5
    call conversao_int
    mv s3, a0 # Tb

    addi a1, a1, 5
    call conversao_int
    mv s4, a0 # Tc

    addi a1, a1, 5
    call conversao_int
    mv s5, a0 # Tr

calcula_distancias:
    mv a1, s2
    call distancia
    mv s6, a0 # Da

    mv a1, s3
    call distancia
    mv s7, a0 # Db

    mv a1, s4
    call distancia
    mv s8, a0 # Dc

calcula_Y:
    mul t0, s6, s6 # Da²
    mul t1, s0, s0 # Yb²
    mul t2, s7, s7 # Db²
    add a1, t0, t1 # Da² + Yb²
    sub a1, a1, t2 # - Db²
    div a1, a1, s0 # / Yb
    srai a1, a1, 1 # divide por 2
    mv s9, a1 # salva Y em s9 

calcula_X:
    mv t0, s6 # Da
    mv t1, s9 # Y
    mul t0, t0, t0 # Da²
    mul t2, t1, t1 # Y²
    sub a0, t0, t2 # Da² - Y² = a0
    call raiz # calcula raiz em a0
    neg t4, a0 # raiz negativa
    sub a1, a0, s1 # X - Xc
    mul a1, a1, a1 
    add a1, a1, t2 # (X-Xc)² + Y²
    mv t3, s8
    mul t3, t3, t3 # Dc²
    sub a1, a1, t3
raiz_negativa:
    neg t4, a0
    sub a2, t4, s1 # X - Xc
    mul a2, a2, a2 
    add a2, a2, t2 # (X-Xc)² + Y²
    sub a2, a2, t3
modulo1:
    blt x0, a1, modulo2
    neg a1, a1 # a1 = -a1 para a1 < 0
modulo2:
    blt x0, a2, comparar
    neg a2, a2 # a2 = -a2 para a2 < 0
comparar:
    blt a1, a2, salva_X # caso o modulo de a1 esteja mais proximo de 0 do que a2, salva X como raiz positiva
    neg a0, a0 # raiz negativa eh a utilizada
salva_X:
    mv s10, a0 # salva X em a0

posicionando_outbuffer:
    mv a0, s10 # primeiro X
    la a1, output
    call conversao_ascii
    la t0, output
    li t1, 32 # ' '
    sb t1, 5(t0)
    addi t0, t0, 6

    mv a0, s9 # depois Y
    mv a1, t0 # move estado atual do buffer de saida
    call conversao_ascii
    la t0, output
    li t1, 10 # '\n'
    sb t1, 11(t0)

write:
    li a0, 1 # fd = 1 (stdout)
    la a1, output # aloca outbuf
    li a2, 12 # escreve 12 bytes
    li a7, 64 # syscall write
    ecall

end:
    li a7, 93 # syscall exit
    li a0, 0
    ecall