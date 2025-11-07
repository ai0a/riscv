#
#  memory.s
#  riscv
#
#  Created by z on 4/8/24.
#

    lb x1, byte
    lh x2, half
    lw x3, word
    ld x4, dword
    lbu x5, byte
    lhu x6, half
    lwu x7, word

    addi x8, x1, 0x10
    sb x8, 0(x0)
    lb x9, 0(x0)
    addi x8, x2, 0x10
    sh x8, 0(x0)
    lh x10, 0(x0)
    addi x8, x3, 0x10
    sw x8, 0(x0)
    lw x11, 0(x0)
    addi x8, x4, 0x10
    sd x8, 0(x0)
    ld x12, 0(x0)
    .word 0 # Illegal instruction

byte:
    .byte -0x01
half:
    .half -0x0102
word:
    .word -0x01020304
dword:
    .dword -0x0102030405060708


# Expects:
# x0 = 0x0
# x1 = 0x-1
# x2 = 0x-102
# x3 = 0x-1020304
# x4 = 0x-102030405060708
# x5 = 0xff
# x6 = 0xfefe
# x7 = 0xfefdfcfc
# x8 = 0x-1020304050606f8
# x9 = 0xf
# x10 = 0x-f2
# x11 = 0x-10202f4
# x12 = 0x-1020304050606f8
# x13 = 0x0
# ...
# x31 = 0x0