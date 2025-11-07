#!/bin/sh

mkdir -p .build/asm

riscv64-unknown-elf-gcc -Wl,-Ttext=0x0 -nostdlib -o .build/asm/a.out $1     # Assemble
riscv64-unknown-elf-objcopy -O binary .build/asm/a.out .build/asm/built.bin # Extract just the relevant object code

swift run emulator .build/asm/built.bin