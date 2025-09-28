.data
input_file: .asciz "image.pgm"
buffer: .space 262200    # espaço para todo o conteúdo da imagem

.text
.globl _start

_start:
    # === Abrir arquivo ===
    la a0, input_file     # caminho do arquivo
    li a1, 0              # flags: read-only
    li a2, 0              # mode (não usado)
    li a7, 1024           # syscall open
    ecall
    mv s0, a0             # s0 = file descriptor

    # === Ler arquivo ===
    la a1, buffer         # destino
    li a2, 262200         # bytes máximos a ler
    li a7, 63             # syscall read
    ecall
    mv s1, a0             # s1 = número de bytes lidos

    # === Fechar arquivo ===
    mv a0, s0
    li a7, 57             # syscall close
    ecall

    # === Parse do cabeçalho PGM ===
    la t0, buffer         # ponteiro para buffer
    call skip_header      # sai com t0 apontando para pixel[0]
    mv s2, a0             # s2 = largura
    mv s3, a1             # s3 = altura
    mv s4, t0             # s4 = ponteiro para início dos pixels

    # === Definir tamanho do canvas ===
    mv a0, s2             # largura
    mv a1, s3             # altura
    li a7, 2201           # syscall setCanvasSize
    ecall

    # === Pintar pixels ===
    li t1, 0              # y = 0
y_loop:
    li t0, 0              # x = 0
x_loop:
    # calcular offset = y * largura + x
    mul t2, t1, s2
    add t2, t2, t0
    add t3, s4, t2        # endereço do pixel (t3)
    lbu t4, 0(t3)         # carregar valor do pixel

    # montar cor RGBA (grayscale)
    slli t5, t4, 24       # R
    slli t6, t4, 16       # G
    slli t7, t4, 8        # B
    li t8, 255            # A
    or a2, t5, t6
    or a2, a2, t7
    or a2, a2, t8         # a2 = RGBA

    mv a0, t0             # x
    mv a1, t1             # y
    li a7, 2200           # syscall setPixel
    ecall

    addi t0, t0, 1        # x++
    blt t0, s2, x_loop

    addi t1, t1, 1        # y++
    blt t1, s3, y_loop

exit:
    li a0, 0
    li a7, 93             # syscall exit
    ecall


# ---------------------------------------------------
# Função: skip_header
# Saída:
#   a0 = largura
#   a1 = altura
#   t0 = ponteiro para início dos pixels
# ---------------------------------------------------
skip_header:
    # t0 já aponta para buffer
    # pular "P5\n"
    addi t0, t0, 3

    # Pular qualquer caractere de comentário (#...) e whitespace
    call skip_non_digit

    # === Largura ===
    li a0, 0
parse_width:
    lbu t1, 0(t0)
    blt t1, 48, end_width    # se < '0', fim
    bgt t1, 57, end_width    # se > '9', fim
    addi t1, t1, -48
    li t2, 10
    mul a0, a0, t2
    add a0, a0, t1
    addi t0, t0, 1
    j parse_width
end_width:

    call skip_non_digit     # pula espaço

    # === Altura ===
    li a1, 0
parse_height:
    lbu t1, 0(t0)
    blt t1, 48, end_height
    bgt t1, 57, end_height
    addi t1, t1, -48
    li t2, 10
    mul a1, a1, t2
    add a1, a1, t1
    addi t0, t0, 1
    j parse_height
end_height:

    call skip_non_digit     # pula espaço

    # === Pular "255\n" ===
skip_255:
    lbu t1, 0(t0)
    addi t0, t0, 1
    li t2, 10       # '\n'
    bne t1, t2, skip_255

    ret

# ---------------------------------------------------
# Função auxiliar: skip_non_digit
# Incrementa t0 até encontrar dígito ASCII ('0' a '9')
# ---------------------------------------------------
skip_non_digit:
    lbu t1, 0(t0)
    li t2, 48       # '0'
    li t3, 57       # '9'
    blt t1, t2, skip_advance
    bgt t1, t3, skip_advance
    ret             # se está entre '0' e '9', retorna
skip_advance:
    addi t0, t0, 1
    j skip_non_digit
