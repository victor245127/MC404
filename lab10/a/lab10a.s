.text
.globl linked_list_search
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit



linked_list_search:
    addi sp, sp, -16
    sw ra, 0(sp)

    mv t0, a0 # nó em t0
    li t1, -1 # output inicial de -1 (caso nao ache a soma)
    li a0, 0 # indice inicial

1:
    lw t3, 0(t0) # val1
    lw t4, 4(t0) # val2
    lw t5, 8(t0) # *prox no
    add t6, t3, t4 # soma
    beq a1, t6, 3f # se input = soma, retorna o indice

    addi t0, t0, 8 # anda para proximo no
    addi a0, a0, 1 # prox indice

    beq t0, x0, 2f # caso proximo no seja 0 e nao tiver achado a soma, retorna -1
    j 1b

2:
    mv a0, t1 # output -1

3:
    lw ra, 0(sp)
    addi sp, sp, 16
    ret



atoi:
    mv t6, a0 # str em t6
    li a0, 0
    li t4, 10 

    li t1, 45 # '-'
    li t3, 1 
    lb t2, 0(t6)
    beq t1, t2, 1f # se primeiro digito for '-'
    j 2f

1:
    li t3, -1 # multiplicara o numero por -1 no final
    addi t6, t6, 1 # pula o '-'

2:
    lb t2, 0(t6) 
    beq x0, t2, 3f # se caractere = '\0', acaba loop
    addi t2, t2, -48
    mul a0, a0, t4 
    add a0, a0, t2

    addi t6, t6, 1 # anda no buffer
    j 2b

3:
    mul a0, a0, t3 # multiplica por +/-1 dependendo do sinal
    ret


itoa:
    addi sp, sp, -16
    sw ra, 0(sp)

    mv t0, a0 # valor em t0
    mv t1, a1 # str em t1
    mv t2, a2 # base em t2

    li t3, 1 # divisor inicial
    li t4, 0 # contagem de digitos

1: # do-while
    mul t3, t3, t2 # se nao, divisor inicial aumenta
    addi t4, t4, 1

    blt t0, t3, 2f # se numero < base^x, pula pro loop
    j 1b

2:
    div t3, t3, t2 # pega a casa decimal certa
    div a0, t0, t3 # num / div inicial
    rem t0, t0, t3 # resto da divisao
    jal adicao
    addi a0, a0, 48 # ascii
    sb a0, 0(t1) # armazena digito no buffer

    addi t1, t1, 1 # anda no buffer
    addi t4, t4, -1 # i--
    blt x0, t4, 2b # t4 > 0
    sb x0, 0(t0) # '\0' no final
    j 4f

adicao:
    li t6, 9
    blt t6, a0, 3f # verifica se digito for maior que 9
    jalr x0, ra, 0 # se nao, volta pra adicionar 48

3:
    addi a0, a0, 55 # adiciona 55 (pra letras maiusculas)
    jalr x0, ra, 4 # retorna pra instrucao seguinte a adicionar 48

4:
    mv a0, a1 # retorna a string
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


gets:
    mv a1, a0 # str em a1
    li a0, 0 # fd = 0
    li a2, 100 # numero maximo de bytes
    li a7, 63 # syscall read 
    ecall 

    add t0, a1, a0 # chega na ultima posicao da string
    beq x0, a0, 1f # se bytes lidos = 0, pula

    li t1, 10 # '\n'
    addi t0, t0, -1
    lb t2, 0(t0) # caractere final
    beq t1, t2, 1f # caso caractere final seja \n, pula
    addi t0, t0, 1

1:
    sb x0, 0(t0) # '\0' no final da string

    mv a0, a1

    ret


puts:
    li t0, 1
    mv t1, a0 # str em t1

contagem:
    lb t2, 0(t1)
    beq t2, x0, 1f # se byte atual for = '\0', acaba contagem
    addi t0, t0, 1
    addi t1, t1, 1
    j contagem

1:

    li t2, 10 # '\n'
    sb t2, 0(t1) # salva \n no final da string
    mv a1, a0 # str em a1
    li a0, 1 # fd = 1
    mv a2, t0 # qntd de bytes escritos
    li a7, 64 # syscall write
    ecall

    ret


exit:
    li a7, 93
    ecall # syscall exit
