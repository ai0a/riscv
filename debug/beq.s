#
#  beq.s
#  riscv
#
#  Created by z on 4/7/24.
#

    addi x1, x0, -2
    mv x3, x0
beqloop:
    addi x1, x1, 1
    addi x3, x3, 1
    beq x1, x0, afterbeqloop
    j beqloop
afterbeqloop:
    mv x2, x3

    mv x1, x0
    mv x3, x0
bneloop:
    addi x1, x1, 1
    addi x3, x3, 1
    bne x1, x0, afterbneloop
    j bneloop
afterbneloop:
    mv x4, x3

    addi x1, x0, -2
    mv x3, x0
bgeloop:
    addi x1, x1, 1
    addi x3, x3, 1
    bge x1, x0, afterbgeloop
    j bgeloop
afterbgeloop:
    mv x5, x3

    addi x1, x0, 2
    mv x3, x0
bltloop:
    addi x1, x1, -1
    addi x3, x3, 1
    blt x1, x0, afterbltloop
    j bltloop
afterbltloop:
    mv x6, x3

    mv x1, x0
    mv x3, x0
bltuloop:
    addi x1, x1, 1
    addi x3, x3, 1
    bltu x0, x1, afterbltuloop
    j bltuloop
afterbltuloop:
    mv x7, x3

    mv x1, x0
    mv x3, x0
bgeuloop:
    addi x1, x1, 1
    addi x3, x3, 1
    bgeu x1, x0, afterbgeuloop
    j bltuloop
afterbgeuloop:
    mv x8, x3
