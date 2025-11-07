main:
  addi x29, x0, 5      # 5
  addi x30, x0, 37     # 37 (0x25)
  add x31, x30, x29    # 42 (0x2A)
  slti x28, x31, 0x2B  # 1
  slti x27, x31, 0x29  # 0
  sltiu x26, x31, 0x2B # 1
  sltiu x25, x31, 0x29 # 0
  xori x24, x31, 42    # 0
  xori x23, x31, 1     # 43 (0x2B)
  ori x22, x31, 1      # 43 (0x2B)
  ori x21, x31, 2      # 42 (0x2A)
  andi x20, x31, 1     # 0
  andi x19, x31, 2     # 2
  slli x18, x19, 2     # 8
  srli x17, x18, 2     # 2
  srai x16, x18, 1     # 4
  sub x15, x31, x30    # 5
  sll x14, x31, x29    # 1344 (0x540)
  slt x13, x29, x30    # 1
  sltu x12, x29, x30   # 1
  xor x11, x29, x28    # 4
  srl x10, x31, x29    # 1
  sra x9, x31, x29     # 1
  or x8, x31, x29      # 47 (0x2F)
  and x7, x31, x29     # 0
  lui x6, 1            # 0x1000
  auipc x5, 108        # 0x6C068
  j later
  mv x29, x31          # Shouldn't be executed
later:
  mv x4, x29           # 5
  jalr x0, x29, -5     # Should infinite loop back to 0

# Expects:
# x0 = 0x0
# x1 = 0x0
# x2 = 0x0
# x3 = 0x0
# x4 = 0x5
# x5 = 0x6c068
# x6 = 0x1000
# x7 = 0x0
# x8 = 0x2f
# x9 = 0x1
# x10 = 0x1
# x11 = 0x4
# x12 = 0x1
# x13 = 0x1
# x14 = 0x540
# x15 = 0x5
# x16 = 0x4
# x17 = 0x2
# x18 = 0x8
# x19 = 0x2
# x20 = 0x0
# x21 = 0x2a
# x22 = 0x2b
# x23 = 0x2b
# x24 = 0x0
# x25 = 0x0
# x26 = 0x1
# x27 = 0x0
# x28 = 0x1
# x29 = 0x5
# x30 = 0x25
# x31 = 0x2a