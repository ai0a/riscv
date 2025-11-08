//
//  CPU.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

struct CPU {
    var registers = [Int64](repeating: 0, count: 32)
    var pc: UInt64
    var memory: Memory
    
    enum ExecutionError: Error {
        case unknownInstruction
    }
    
    mutating func executeSingleInstruction() throws{
        // x0 is always 0
        registers[0] = 0
        
        let encodedInstruction = try fetchInstruction()
        guard let instruction = RiscVInstruction(encodedInstruction: encodedInstruction) else {
            throw ExecutionError.unknownInstruction
        }
        try execute(instruction)
    }
    mutating func fetchInstruction() throws -> UInt32 {
        let instruction = try memory.read32Bits(address: pc)
        pc += 4
        return instruction
    }
    mutating func execute(_ instruction: RiscVInstruction) throws {
        switch (instruction) {
        case .lb(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read8Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = Int64(value)
        case .lbu(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read8Bits(address: address)
            registers[Int(destinationRegister)] = Int64(value)
        case .lh(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read16Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = Int64(value)
        case .lhu(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read16Bits(address: address)
            registers[Int(destinationRegister)] = Int64(value)
        case .lw(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read32Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = Int64(value)
        case .lwu(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read32Bits(address: address)
            registers[Int(destinationRegister)] = Int64(value)
        case .ld(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(immediate)
            let value = try memory.read64Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = value
        case .sb(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(immediate)
            try memory.store8Bits(UInt8(UInt64(bitPattern: registers[Int(sourceRegister2)] & 0xff)), at: address)
        case .sh(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(immediate)
            try memory.store16Bits(UInt16(UInt64(bitPattern: registers[Int(sourceRegister2)]) & 0xffff), at: address)
        case .sw(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(immediate)
            try memory.store32Bits(UInt32(UInt64(bitPattern:registers[Int(sourceRegister2)] & 0xffffffff)), at: address)
        case .sd(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(immediate)
            try memory.store64Bits(UInt64(bitPattern: registers[Int(sourceRegister2)]), at: address)
        case .fence:
            // I don't think this is relevant.
            break
        case .jal(let destinationRegister, let offset):
            registers[Int(destinationRegister)] = Int64(pc)
            pc = UInt64(offset &+ Int(pc))
            pc &-= 4
        case .jalr(let destinationRegister, let sourceRegister, let offsetImmediate):
            registers[Int(destinationRegister)] = Int64(pc)
            var address = offsetImmediate + Int(registers[Int(sourceRegister)])
            if (address & 1 == 1) {
                address ^= 1
            }
            pc = UInt64(address)
        case .beq(let sourceRegister1, let sourceRegister2, let offset):
            if (registers[Int(sourceRegister1)] == registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .bne(let sourceRegister1, let sourceRegister2, let offset):
            if (registers[Int(sourceRegister1)] != registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .blt(let sourceRegister1, let sourceRegister2, let offset):
            if (registers[Int(sourceRegister1)] < registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .bltu(let sourceRegister1, let sourceRegister2, let offset):
            if UInt64(bitPattern: registers[Int(sourceRegister1)]) < UInt64(bitPattern: registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .bge(let sourceRegister1, let sourceRegister2, let offset):
            if (registers[Int(sourceRegister1)] > registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .bgeu(let sourceRegister1, let sourceRegister2, let offset):
            if UInt64(bitPattern: registers[Int(sourceRegister1)]) > UInt64(bitPattern: registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .lui(let destinationRegister, let immediate):
            registers[Int(destinationRegister)] = Int64(UInt32(immediate).signExtension())
        case .auipc(let destinationRegister, let immediate):
            // From position of auipic instruction, but pc has already been moved forward
            registers[Int(destinationRegister)] = Int64(UInt64(immediate) + pc - 4)
        case .addi(let destinationRegister, let sourceRegister, let immediate):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] &+ Int64(immediate)
        case .addiw(let destinationRegister, let sourceRegister, let immediate):
            let result32 = Int32(bitPattern: UInt32(registers[Int(sourceRegister)] & ((1 << 32) - 1))) &+ Int32(immediate)
            registers[Int(destinationRegister)] = Int64(result32)
        case .xori(let destinationRegister, let sourceRegister, let immediate):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] ^ Int64(immediate)
        case .ori(let destinationRegister, let sourceRegister, let immediate):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] | Int64(immediate)
        case .andi(let destinationRegister, let sourceRegister, let immediate):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] & Int64(immediate)
        case .slli(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] << Int64(shamt)
        case .slliw(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = Int64(UInt32(bitPattern: Int32(registers[Int(sourceRegister)] << Int64(shamt)) & ((1 << 32) - 1)).signExtension())
        case .srli(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] >> Int64(shamt)
        case .srliw(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = Int64(UInt32(bitPattern: Int32(registers[Int(sourceRegister)] >> Int64(shamt)) & ((1 << 32) - 1)).signExtension())
        case .srai(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] >> Int64(shamt)
        case .sraiw(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = Int64(UInt32(bitPattern: Int32(registers[Int(sourceRegister)] >> Int64(shamt)) & ((1 << 32) - 1)).signExtension())
        case .slti(let destinationRegister, let sourceRegister, let immediate):
            let result: Int64 = if registers[Int(sourceRegister)] < immediate {
                1
            } else {
                0
            }
            registers[Int(destinationRegister)] = result
        case .sltiu(let destinationRegister, let sourceRegister, let immediate):
            let result: Int64 = if registers[Int(sourceRegister)] < immediate {
                1
            } else {
                0
            }
            registers[Int(destinationRegister)] = result
        case .add(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] &+ registers[Int(sourceRegister2)]
        case .addw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1))
            registers[Int(destinationRegister)] =  Int64(firstOperand &+ secondOperand)
        case .sub(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] &- registers[Int(sourceRegister2)]
        case .subw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1))
            registers[Int(destinationRegister)] =  Int64(firstOperand &- secondOperand)
        case .sll(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] << registers[Int(sourceRegister2)]
        case .sllw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1))
            registers[Int(destinationRegister)] =  Int64(firstOperand << secondOperand)
        case .srl(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] >> registers[Int(sourceRegister2)]
        case .srlw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1))
            registers[Int(destinationRegister)] =  Int64(firstOperand >> secondOperand)
        case .sra(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] >> registers[Int(sourceRegister2)]
        case .sraw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1))
            registers[Int(destinationRegister)] =  Int64(firstOperand >> secondOperand)
        case .slt(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let result: Int64 = if registers[Int(sourceRegister1)] < registers[Int(sourceRegister2)] {
                1
            } else {
                0
            }
            registers[Int(destinationRegister)] = result
        case .sltu(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let result: Int64 = if registers[Int(sourceRegister1)] < registers[Int(sourceRegister2)] {
                1
            } else {
                0
            }
            registers[Int(destinationRegister)] = result
        case .xor(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] ^ registers[Int(sourceRegister2)]
        case .or(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] | registers[Int(sourceRegister2)]
        case .and(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] & registers[Int(sourceRegister2)]
        case .ecall:
            //TODO
            break
        case .ebreak:
            //TODO
            break
        case .csrrw(destinationRegister: let destinationRegister, sourceRegister: let sourceRegister, csr: let csr):
            fatalError("TODO: csrrw \(instruction)")
        case .csrrs(destinationRegister: let destinationRegister, sourceRegister: let sourceRegister, csr: let csr):
            fatalError("TODO: csrrs \(instruction)")
        case .csrrc(destinationRegister: let destinationRegister, sourceRegister: let sourceRegister, csr: let csr):
            fatalError("TODO: csrrc \(instruction)")
        case .csrrwi(destinationRegister: let destinationRegister, immediate: let immediate, csr: let csr):
            fatalError("TODO: csrrwi \(instruction)")
        case .csrrsi(destinationRegister: let destinationRegister, immediate: let immediate, csr: let csr):
            fatalError("TODO: csrrsi \(instruction)")
        case .csrrci(destinationRegister: let destinationRegister, immediate: let immediate, csr: let csr):
            fatalError("TODO: csrrci \(instruction)")
        case .mret:
            //TODO: There are MANY more things that should happen here
            pc = csrs.mepc
        }
        print(instruction)
    }
    
    func printRegisters() {
        for (index, register) in registers.enumerated() {
            print("x\(index) = 0x\(String(register, radix: 16))")
        }
        print("pc = 0x\(String(pc, radix: 16))")
    }
}
