.text
.globl node_op

node_op:
    lw t0, 0(a0) # a
    lb t1, 4(a0) # b
    lb t2, 5(a0) # c
    lh t3, 6(a0) # d

    add a0, t0, t1 # a + b
    sub a0, a0, t2 # - c
    add a0, a0, t3 # + d

    ret