


.text
.globl _start

_start:











    # a0 = file descriptor, a1 = ponteiro para buffer, a2 = numero de bytes a serem lidos/escritos pela syscall
# retorna em a0 numero de bytes lidos/escritos
read: # função implementadora da syscall read
    addi sp, sp, -16
    sw ra, 0(sp)
    li a7, 63
    ecall
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

write:  # função implementadora da syscall write
    addi sp, sp, -16
    sw ra, 0(sp)
    li a7, 64
    ecall
    lw ra, 0(sp)
    addi sp, sp, 16
    ret
