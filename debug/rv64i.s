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
