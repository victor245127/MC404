.data
buffer: .skip 0x14 # tamanho 20 array
buffer_out: .skip 0x14  

.text
.globl _start

conversao_int:
    li a3, 10
    li a0, 0 # valor do numero
    li t0, 4 # quantidade de iteracoes

loop1:
    lb t1, 0(a1) # carrega byte em t1
    addi t1, t1, -48 # transforma de ASCII para int
    mul a0, a0, a3 # multiplica por 10 o  resultado anterior (posicao do numero)
    add a0, a0, t1 # adiciona o valor ao numero
    addi a1, a1, 1 # anda um byte
    addi t0, t0, -1 # i--
    bnez t0, loop1 # t0 > 0
    ret # retorna 



raiz:
    mv t0, a0 # parametro y
    srai t1, t0, 1 # k = y/2
    li t2, 10 # quantidade de iteracoes

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
    li t0, 1000 # divisor maximo do numero para trocar base decimal para binaria comecando pelo MSD
    li a3, 10
    li t1, 4 # quantidade de iteracoes
loop3:
    div t2, a0, t0 # num // t0
    rem a0, a0, t0 # num %= t0
    addi t2, t2, 48  # pega o digito em ascii
    sb t2, 0(a1) # passa o digito para o buffer
    addi a1, a1, 1 # anda 1 posicao no buffer
    div t0, t0, a3 # divide o divisor por 10(anda uma casa p tras)
    addi t1, t1, -1 # i--
    bnez t1, loop3 # t1 > 0
    ret


_start:
    la t0, buffer
    li t1, 10 # t1 = '\n'
    sb t1, 19(t0) # aloca \n no final do buffer

    li a0, 0 # file descriptor = 0 (stdin)
    la a1, buffer # buffer de entrada
    li a2, 20 # le 20 bytes 
    li a7, 63 # syscall read (63)
    ecall

    la t4, buffer # copiando entrada inicial
    la t5, buffer_out # alocando buffer de saida

    li t6, 4 # quantidade de iteracoes

loop_final:
    mv a1, t4 # carrega estado atual do buffer em a1
    call conversao_int # chama funcao de conversao de string para inteiro
    call raiz # funcao de raiz quadrada no inteiro
    mv a1, t5 # carrega buffer de saida em a1
    call conversao_ascii # chama funcao de conversao do resultado da raiz em ascii para string
    addi t4, t4, 4 # anda 4 posicoes do buffer de entrada e depois o de saida
    addi t5, t5, 4
    lb t0, 0(t4) # carrega o ' ' em t0
    sb t0, 0(t5) # passa esse caractere para o buffer de saida
    addi t4, t4, 1 # anda +1 posicao nos buffers
    addi t5, t5, 1 
    addi t6, t6, -1 # i--
    bnez t6, loop_final # t6 > 0

    la t0, buffer_out # carrega o buffer_out em t0
    li t1, 10 # t1 = '\n'
    sb t1, 19(t0) # passa '\n' para ultima posicao do buffer de saida

    li a0, 1 # file descriptor = 1 (stdout)
    la a1, buffer_out # buffer
    li a2, 20 # tamanho
    li a7, 64 # syscall write (64)
    ecall

end:
    li a7, 93 # syscall exit
    li a0, 0
    ecall

