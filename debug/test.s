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
