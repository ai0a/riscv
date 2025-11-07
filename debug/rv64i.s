#
#  rv64i.s
#  riscv
#
#  Created by z on 4/13/24.
#
    addiw x1, x0, 0x100 # 0x100
    slliw x2, x1, 4     # 0x1000
    srliw x3, x2, 8     # 0x10
    sraiw x4, x2, 4     # 0x100
    addw x5, x2, x3     # 0x1010
    subw x6, x5, x3     # 0x1000
    sllw x7, x6, x3     # 0x10000000
    srlw x8, x7, x3     # 0x1000
    sraw x9, x7, x3     # 0x1000

# Expects:
# x0 = 0x0
# x1 = 0x100
# x2 = 0x1000
# x3 = 0x10
# x4 = 0x100
# x5 = 0x1010
# x6 = 0x1000
# x7 = 0x10000000
# x8 = 0x1000
# x9 = 0x1000
# x10 = 0x0
# ...
# x31 = 0x0