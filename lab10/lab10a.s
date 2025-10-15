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

    mv t0, t5 # anda para proximo no
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
    mv t6, a0
    li a0, 0
    li t4, 10 

    addi t0, s0, -1 # quantidade de digitos lidos sem o \n
    li t1, 45 # '-'
    li t3, 1 
    lb t2, 0(t6)
    beq t1, t2, 1f # se primeiro digito for '-'
    j 2f

1:
    li t3, -1 # multiplicara o numero por -1 no final
    addi t0, t0, -1 # pula o '-' na quantidade de digitos lidos
    addi t6, t6, 1 # pula o '-'

2:
    lb t2, 0(t6)
    addi t2, t2, -48
    mul a0, a0, t4 
    add a0, a0, t2

    addi t6, t6, 1 # anda no buffer
    addi t0, t0, -1 # i--
    blt x0, t0, 2b
    mul a0, a0, t3 # multiplica por +/-1 dependendo do sinal

3:
    ret


itoa:
    addi sp, sp, -16
    sw ra, 0(sp)

    mv t0, a1 # str em t0
    mv t1, a2 # base em t1

    mul t2, t1, t1 # base²

    mv t5, a0 # val em t5
    blt t5, x0, 1f # se nao houver indice, sera -1
    blt t5, t1, 2f # se indice for menor que 10/16, sera apenas 1 digito
    blt t5, t2, 3f # se indice for menor que 100/256, sera apenas 2 digitos
    li t4, 3 # se indice > 100, nao pode ser >= 1000
    mv t3, t2
    j 4f
    
1: 
    li t1, 45 # '-'
    li t3, 49 # '1'
    sb t1, 0(t0) # '-1\0'
    sb t3, 1(t0)
    sb x0, 2(t0)
    j 5f

2:
    li t3, 1 # divisor inicial sendo 1
    li t4, 1
    j 4f

3:
    mv t3, t1 # divisor inicial sendo 10
    li t4, 2

4:
    div a0, t5, t3 # num / div inicial
    rem t5, t5, t3 # resto da divisao
    jal a7, adicao
    addi a0, a0, 48 # ascii
    sb a0, 0(t0) # armazena digito no buffer
    div t3, t3, t1 # pega a proxima casa decimal
    addi t0, t0, 1 # anda no buffer
    addi t4, t4, -1 # i--
    blt x0, t4, 4b # t4 > 0
    sb x0, 0(t0) # '\0' no final

adicao:
    li t6, 9 
    blt t6, a0, 6f # verifica se digito for maior que 9
    jalr a7, x0, 0 # se nao, volta pra adicionar 48

6:
    addi a0, a0, 87 # adiciona 87 (pra letras minusculas)
    jalr a7, x0, 4 # retorna pra instrucao seguinte a adicionar 48

5:
    lw ra, 0(sp)
    addi sp, sp, 16
    mv a0, a1 # retorna a string
    ret


gets:
    addi sp, sp, -16
    sw ra, 0(sp)

    mv a1, a0 # str em a1
    li a0, 0 # fd = 0
    li a2, 100 # numero maximo de bytes
    li a7, 63 # syscall read 
    ecall 
    mv s0, a0 # salva numero de bytes escritos

    add t0, a1, s0 # chega na ultima posicao da string
    sb x0, 0(t0) # '\0' no final da string

    mv a0, a1

    lw ra, 0(sp)
    addi sp, sp, 16
    ret


puts:
    addi sp, sp, -16
    sw ra, 0(sp)

    li t0, 0
    mv t1, a0 # str em t1

contagem:
    lb t2, 0(t1)
    beq t2, x0, 1f # se byte atual for = '\0', acaba contagem
    addi t0, t0, 1
    addi t1, t1, 1
    j contagem

1:
    mv a1, a0 # str em a1
    li a0, 1 # fd = 1
    mv a2, t0 # qntd de bytes escritos
    li a7, 64 # syscall write
    ecall

    lw ra, 0(sp)
    addi sp, sp, 16
    ret


exit:
    li a7, 93
    ecall # syscall exit
