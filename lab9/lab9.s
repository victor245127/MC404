.data
linked_list: .asciz "data.s"
buffer: .space 7
buffer_out: .space 5

.text
.globl _start

parsing:
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

return:
    ret


percorrendo_lista:
    



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
    call parsing
    mv s1, a0 # soma em s1


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
