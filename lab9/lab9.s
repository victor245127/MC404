.data
linked_list: .asciz "data.s"
buffer: .space 7
buffer_out: .space 5

.text
.globl _start

parsing_int:
    mv t6, a1
    li a0, 0
    li t4, 10 

    addi t0, s0, -1 # quantidade de digitos lidos sem o \n
    li t1, 45 # '-'
    li t3, 1 
    lb t2, 0(t6)
    beq t1, t2, 1f # se primeiro digito for '-'
    j 2f

1:
    addi t3, t3, -2 # multiplicara o numero por -1 no final
    addi t6, t6, 1 # pula o '-'

2:
    lb t2, 0(t6)
    addi t2, t2, -48
    mul a0, a0, t4 
    add a0, a0, t2

    addi t6, t6, 1
    addi t0, t0, -1
    blt x0, t0, 2b
    mul a0, a0, t3 # multiplica por +/-1 dependendo do sinal

3:
    ret



parsing_ascii:
    mv t0, a1 # buffer de saida em t0
    li t1, 100
    li t2, 10

    blt s3, x0, 1f # se nao houver indice, sera -1
    blt s3, t2, 2f # se indice for menor que 10, sera apenas 1 digito
    blt s3, t1, 3f # se indice for menor que 100, sera apenas 2 digitos
    li t4, 3 # se indice > 100, nao pode ser >= 1000
    j 4f
    
1: 
    li t1, 45 # '-'
    li t3, 49 # '1'
    sb t1, 0(t0) # '-1\n'
    sb t3, 1(t0)
    sb t2, 2(t0)
    j 5f

2:
    li t3, 1 # divisor inicial sendo 1
    li t4, 1
    j 4f

3:
    mv t3, t2 # divisor inicial sendo 10
    li t4, 2

4:
    div a0, s4, t3 # num / div inicial
    rem a2, s4, t3 # resto da divisao
    addi a2, a2, 48 # ascii
    sb t2, 0(t0) # armazena digito no buffer
    addi t0, t0, 1
    addi t4, t4, -1 # i--
    blt x0, t4, 4b # t4 > 0
    sb t2, 0(t0) # '\n' no final

5:
    ret


percorrendo_lista:
    la a0, head_node # carrega cabeca da lista em a0
    li s3, -1 # inicialmente output é -1 e continuara caso nao ache a soma
    li t1, 0 # indice inicial da lista

1:
    lw a1, 0(a0) # primeiro numero da soma
    lw a2, 4(a0) # segundo numero da soma
    lw t2, 8(a0) # ponteiro para o proximo no
    add a3, a1, a2 
    beq s1, a3, 2f # se o input for igual a soma, retorna o indice
    beq t2, x0, 3f # caso proximo nó seja 0 e nao tiver achado a soma, retorna -1

    addi a0, a0, 12 # pula para o primeiro numero do proximo no
    addi t1, t1, 1 # vai pra proximo indice
    j 1b

2:
    mv s3, t1 # armazena indice da soma em s3

3:
    ret



_start:
    la a0, linked_list # abre o arquivo da lista ligada
    li a1, 0
    li a2, 0
    li a7, 1024 # syscall open
    ecall
    mv s2, a0 # salva fd em s2

    li a0, 0
    la a1, buffer
    li a2, 7
    li a7, 63 # syscall read
    ecall
    mv s0, a0 # quantidade de bytes lidos

    mv a0, s0
    la a1, buffer
    call parsing_int
    mv s1, a0 # soma em s1

    call percorrendo_lista

    la a1, buffer_out
    call parsing_ascii


write:
    li a0, 1
    la a1, buffer_out
    li a2, 5 # tamanho vai variar
    li a7, 64 # syscall write
    ecall

exit:
    li a0, 3
    li a7, 53 # syscall close
    ecall


    li a7, 93
    li a0, 0
    ecall # syscall exit
