	li x1,0b0010101010101010101010101010101010101010101010101010101010101010
	csrrw x0,mepc,x0 # Should set mepc to all zeroes
	csrrs x0,mepc,x1 # Should turn on most bits of mepc. Final two are always 0, though.
	csrrs x2,mepc,x0 # Should copy mepc to x2

	li x3,0b0010000010101010101010101010101010101010100000001010000010101010
	csrrc x0,mepc,x3
	csrrs x4,mepc,x0
# Expects:
# x0 = 0x0
# x1 = 0x2aaaaaaaaaaaaaaa
# x2 = 0x2aaaaaaaaaaaaaa8
# x3 = 0x20aaaaaaaa80a0aa
# x4 = 0xa000000002a0a00
# x5 = 0x0
# x6 = 0x0
# x7 = 0x0
# x8 = 0x0
# x9 = 0x0
# x10 = 0x0
# x11 = 0x0
# x12 = 0x0
# x13 = 0x0
# x14 = 0x0
# x15 = 0x0
# x16 = 0x0
# x17 = 0x0
# x18 = 0x0
# x19 = 0x0
# x20 = 0x0
# x21 = 0x0
# x22 = 0x0
# x23 = 0x0
# x24 = 0x0
# x25 = 0x0
# x26 = 0x0
# x27 = 0x0
# x28 = 0x0
# x29 = 0x0
# x30 = 0x0
# x31 = 0x0
