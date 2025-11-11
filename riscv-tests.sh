#!/bin/bash

set -ue

mkdir -p .build

pushd riscv-tests

autoconf &&
./configure --prefix="$(realpath '../.build')" &&
make &&
make install

popd

mkdir -p .build/riscv-tests/relevant-cases

cp .build/share/riscv-tests/isa/rv64ui-p-* .build/riscv-tests/relevant-cases/
cp .build/share/riscv-tests/isa/rv64um-p-* .build/riscv-tests/relevant-cases/
cp .build/share/riscv-tests/isa/rv64uf-p-* .build/riscv-tests/relevant-cases/
cp .build/share/riscv-tests/isa/rv64ud-p-* .build/riscv-tests/relevant-cases/

rm .build/riscv-tests/relevant-cases/*.dump

swift build

# From https://www.bruh.ltd/blog/how-to-test-your-risc-v-emulator/

RUNNER=.build/debug/emulator

RED='\033[0;31m'
GREEN='\033[0;32m'
NORMAL='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

for CASE in .build/riscv-tests/relevant-cases/*
do
	riscv64-unknown-elf-objcopy -O binary "${CASE}" .build/riscv-tests/extracted-case.bin # Extract just the relevant object code
    if "${RUNNER}" --riscv-test .build/riscv-tests/extracted-case.bin
    then
        echo -e "${GREEN}$(basename "${CASE}"): PASS${NORMAL}"
        let PASS_COUNT+=1
    else
        echo -e "${RED}$(basename "${CASE}"): FAIL${NORMAL}"
        let FAIL_COUNT+=1
    fi
done

echo -e "${GREEN}PASSED: ${PASS_COUNT}${NORMAL}"
echo -e "${RED}FAILED: ${FAIL_COUNT}${NORMAL}"