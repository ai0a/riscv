//
//  CPU.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

struct CPU {
    var registers = [Int64](repeating: 0, count: 32)
    var fpRegisters = [Double](repeating: 0, count: 32)
    var csrs = CSRS()
    var pc: UInt64
    var memory: Memory
    let ecallHandler: (any EcallHandler)?

    public init(pc: UInt64, memory: Memory, ecallHandler: (any EcallHandler)? = nil) {
        self.pc = pc
        self.memory = memory
        self.ecallHandler = ecallHandler
    }
    
    enum ExecutionError: Error {
        case unknownInstruction
    }
    
    mutating func executeSingleInstruction() throws{
        // x0 is always 0
        registers[0] = 0
        csrs.cycleCount += 1
        
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
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read8Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = Int64(value)
        case .lbu(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read8Bits(address: address)
            registers[Int(destinationRegister)] = Int64(value)
        case .lh(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read16Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = Int64(value)
        case .lhu(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read16Bits(address: address)
            registers[Int(destinationRegister)] = Int64(value)
        case .lw(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read32Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = Int64(value)
        case .lwu(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read32Bits(address: address)
            registers[Int(destinationRegister)] = Int64(value)
        case .ld(let destinationRegister, let sourceRegister, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read64Bits(address: address).signExtension()
            registers[Int(destinationRegister)] = value
        case .sb(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(bitPattern: Int64(immediate))
            try memory.store8Bits(UInt8(UInt64(bitPattern: registers[Int(sourceRegister2)] & 0xff)), at: address)
        case .sh(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(bitPattern: Int64(immediate))
            try memory.store16Bits(UInt16(UInt64(bitPattern: registers[Int(sourceRegister2)]) & 0xffff), at: address)
        case .sw(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(bitPattern: Int64(immediate))
            try memory.store32Bits(UInt32(UInt64(bitPattern:registers[Int(sourceRegister2)] & 0xffffffff)), at: address)
        case .sd(let sourceRegister1, let sourceRegister2, let immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister1)]) &+ UInt64(bitPattern: Int64(immediate))
            try memory.store64Bits(UInt64(bitPattern: registers[Int(sourceRegister2)]), at: address)
        case .fence:
            // I don't think this is relevant.
            break
        case .fencei:
            // I don't think this is relevant. Nothing needs to be done here in the case of this emulator
            break
        case .jal(let destinationRegister, let offset):
            registers[Int(destinationRegister)] = Int64(pc)
            pc = UInt64(offset &+ Int(pc))
            pc &-= 4
        case .jalr(let destinationRegister, let sourceRegister, let offsetImmediate):
            let oldPc = Int64(pc)
            var address = offsetImmediate + Int(registers[Int(sourceRegister)])
            if (address & 1 == 1) {
                address ^= 1
            }
            pc = UInt64(address)
            registers[Int(destinationRegister)] = oldPc
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
            if (registers[Int(sourceRegister1)] >= registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .bgeu(let sourceRegister1, let sourceRegister2, let offset):
            if UInt64(bitPattern: registers[Int(sourceRegister1)]) >= UInt64(bitPattern: registers[Int(sourceRegister2)]) {
                pc = UInt64(offset &+ Int(pc))
                pc &-= 4
            }
        case .lui(let destinationRegister, let immediate):
            registers[Int(destinationRegister)] = Int64(UInt32(immediate).signExtension())
        case .auipc(let destinationRegister, let immediate):
            // From position of auipic instruction, but pc has already been moved forward
            registers[Int(destinationRegister)] = Int64(bitPattern: (UInt64(immediate) + pc - 4).signExtension(ofBitCount: 32))
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
            //TODO: SLLIW, SRLIW, and SRAIW encodings with imm[5] ≠ 0 are reserved.
            let current = UInt32(UInt64(bitPattern: registers[Int(sourceRegister)]) & ((1 << 32) - 1))
            let shifted = current << UInt32(shamt)
            registers[Int(destinationRegister)] = Int64(shifted.signExtension())
        case .srli(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = Int64(bitPattern: UInt64(bitPattern: registers[Int(sourceRegister)]) >> UInt64(shamt))
        case .srliw(let destinationRegister, let sourceRegister, let shamt):
            //TODO: SLLIW, SRLIW, and SRAIW encodings with imm[5] ≠ 0 are reserved.
            let firstOperand = UInt32(UInt64(bitPattern: registers[Int(sourceRegister)]) & 0xffffffff)
            let secondOperand = UInt32(shamt)
            registers[Int(destinationRegister)] = Int64((firstOperand >> secondOperand).signExtension())
        case .srai(let destinationRegister, let sourceRegister, let shamt):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister)] >> Int64(shamt)
        case .sraiw(let destinationRegister, let sourceRegister, let shamt):
            //TODO: SLLIW, SRLIW, and SRAIW encodings with imm[5] ≠ 0 are reserved.
            let current = UInt32(UInt64(bitPattern: registers[Int(sourceRegister)]) & ((1 << 32) - 1))
            let shifted = UInt64(current >> UInt32(shamt)).signExtension(ofBitCount: 32 - UInt64(shamt))
            registers[Int(destinationRegister)] = shifted.signExtension()
        case .slti(let destinationRegister, let sourceRegister, let immediate):
            let result: Int64 = if registers[Int(sourceRegister)] < immediate {
                1
            } else {
                0
            }
            registers[Int(destinationRegister)] = result
        case .sltiu(let destinationRegister, let sourceRegister, let immediate):
            let result: Int64 = if UInt64(bitPattern: registers[Int(sourceRegister)]) < immediate {
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
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] << (registers[Int(sourceRegister2)] & 0x3f)
        case .sllw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1)) & 0x1f
            registers[Int(destinationRegister)] =  Int64(firstOperand << secondOperand)
        case .srl(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = Int64(bitPattern: UInt64(bitPattern: registers[Int(sourceRegister1)]) >> UInt64(bitPattern: registers[Int(sourceRegister2)] & 0x3f))
        case .srlw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = UInt32(bitPattern: Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)]))
            let secondOperand = UInt32(bitPattern: Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)]) & 0x1f)
            registers[Int(destinationRegister)] =  Int64(Int32(bitPattern: firstOperand >> secondOperand))
        case .sra(let destinationRegister, let sourceRegister1, let sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] >> (registers[Int(sourceRegister2)] & 0x3f)
        case .sraw(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)] & ((1 << 32) - 1))
            let secondOperand = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)] & ((1 << 32) - 1)) & 0x1f
            registers[Int(destinationRegister)] =  Int64(firstOperand >> secondOperand)
        case .slt(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let result: Int64 = if registers[Int(sourceRegister1)] < registers[Int(sourceRegister2)] {
                1
            } else {
                0
            }
            registers[Int(destinationRegister)] = result
        case .sltu(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let result: Int64 = if UInt64(bitPattern: registers[Int(sourceRegister1)]) < UInt64(bitPattern: registers[Int(sourceRegister2)]) {
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
        case let .mul(destinationRegister, sourceRegister1, sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)] &* registers[Int(sourceRegister2)]
        case let .mulw(destinationRegister, sourceRegister1, sourceRegister2):
            registers[Int(destinationRegister)] = Int64(Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)]) &* Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)]))
        case let .mulh(destinationRegister, sourceRegister1, sourceRegister2):
            registers[Int(destinationRegister)] = registers[Int(sourceRegister1)].multipliedFullWidth(by: registers[Int(sourceRegister2)]).high
        case let .mulhsu(destinationRegister, sourceRegister1, sourceRegister2):
            let firstOperand = Int128(registers[Int(sourceRegister1)])
            let secondOperand = Int128(UInt64(bitPattern: registers[Int(sourceRegister2)]))
            registers[Int(destinationRegister)] = Int64((firstOperand &* secondOperand) >> 64)
        case let .mulhu(destinationRegister, sourceRegister1, sourceRegister2):
            registers[Int(destinationRegister)] = Int64(bitPattern: UInt64(bitPattern: registers[Int(sourceRegister1)]).multipliedFullWidth(by: UInt64(bitPattern: registers[Int(sourceRegister2)])).high)
        case let .div(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = registers[Int(sourceRegister1)]
            let divisor = registers[Int(sourceRegister2)]
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = -1
                break
            }
            guard dividend != Int64.min || divisor != -1 else { // overflow
                registers[Int(destinationRegister)] = Int64.min
                break
            }
            registers[Int(destinationRegister)] = dividend / divisor
        case let .divw(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)])
            let divisor = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)])
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = -1
                break
            }
            guard dividend != Int32.min || divisor != -1 else { // overflow
                registers[Int(destinationRegister)] = Int64(Int32.min)
                break
            }
            registers[Int(destinationRegister)] = Int64(dividend / divisor)
        case let .divu(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = UInt64(bitPattern: registers[Int(sourceRegister1)])
            let divisor = UInt64(bitPattern: registers[Int(sourceRegister2)])
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = -1 // Same binary repr. as UInt64.max
                break
            }
            registers[Int(destinationRegister)] = Int64(bitPattern: dividend / divisor)
        case let .divuw(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = UInt32(bitPattern: Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)]))
            let divisor = UInt32(bitPattern: Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)]))
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = Int64(-1 as Int32) // Same binary repr. as UInt64.max
                break
            }
            registers[Int(destinationRegister)] = Int64(Int32(bitPattern: dividend / divisor))
        case let .rem(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = registers[Int(sourceRegister1)]
            let divisor = registers[Int(sourceRegister2)]
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = dividend
                break
            }
            guard dividend != Int64.min || divisor != -1 else { // overflow
                registers[Int(destinationRegister)] = 0
                break
            }
            registers[Int(destinationRegister)] = dividend % divisor
        case let .remw(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)])
            let divisor = Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)])
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = registers[Int(sourceRegister1)]
                break
            }
            guard dividend != Int32.min || divisor != -1 else { // overflow
                registers[Int(destinationRegister)] = 0
                break
            }
            registers[Int(destinationRegister)] = Int64(dividend % divisor)
        case let .remu(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = UInt64(bitPattern: registers[Int(sourceRegister1)])
            let divisor = UInt64(bitPattern: registers[Int(sourceRegister2)])
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = Int64(bitPattern: dividend)
                break
            }
            registers[Int(destinationRegister)] = Int64(bitPattern: dividend % divisor)
        case let .remuw(destinationRegister, sourceRegister1, sourceRegister2):
            let dividend = UInt32(bitPattern: Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister1)]))
            let divisor = UInt32(bitPattern: Int32(bitPatternFromLowerHalfOf: registers[Int(sourceRegister2)]))
            guard divisor != 0 else { // division by 0
                registers[Int(destinationRegister)] = registers[Int(sourceRegister1)]
                break
            }
            registers[Int(destinationRegister)] = Int64(Int32(bitPattern: dividend % divisor))
        case let .flw(destinationRegister, sourceRegister, immediate):
            let address = UInt64(bitPattern: registers[Int(sourceRegister)]) &+ UInt64(bitPattern: Int64(immediate))
            let value = try memory.read32Bits(address: address).asNaNBoxedDouble
            fpRegisters[Int(destinationRegister)] = value
        case .fadds(let destinationRegister, let sourceRegister1, let sourceRegister2, _):
            // TODO: Rounding mode
            let (value, exceptions) = fpRegisters[Int(sourceRegister1)].nanBoxedFloat.addingTrackingExceptions(fpRegisters[Int(sourceRegister2)].nanBoxedFloat)
            fpRegisters[Int(destinationRegister)] = Double(nanBoxing: value)
            try csrs.addFloatingPointExceptions(exceptions)
        case .fsubs(let destinationRegister, let sourceRegister1, let sourceRegister2, _):
            // TODO: Rounding mode
            let (value, exceptions) = fpRegisters[Int(sourceRegister1)].nanBoxedFloat.subtractingTrackingExceptions(fpRegisters[Int(sourceRegister2)].nanBoxedFloat)
            fpRegisters[Int(destinationRegister)] = Double(nanBoxing: value)
            try csrs.addFloatingPointExceptions(exceptions)
        case .fmuls(let destinationRegister, let sourceRegister1, let sourceRegister2, _):
            // TODO: Rounding mode
            let (value, exceptions) = fpRegisters[Int(sourceRegister1)].nanBoxedFloat.multiplyingTrackingExceptions(fpRegisters[Int(sourceRegister2)].nanBoxedFloat)
            fpRegisters[Int(destinationRegister)] = Double(nanBoxing: value)
            try csrs.addFloatingPointExceptions(exceptions)
        case let .fcvtws(destinationRegister, sourceRegister, roundingMode):
            let unconverted = fpRegisters[Int(sourceRegister)].nanBoxedFloat
            guard (!unconverted.isInfinite || unconverted.sign != .plus) && !unconverted.isNaN else {
                registers[Int(destinationRegister)] = Int64(Int32.max)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted > Float(Int32.min) else {
                registers[Int(destinationRegister)] = Int64(Int32.min)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard !unconverted.isInfinite || unconverted.sign != .minus else {
                registers[Int(destinationRegister)] = Int64(Int32.min)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted < Float(Int32.max) else {
                registers[Int(destinationRegister)] = Int64(Int32.max)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            let effectiveRoundingMode = if roundingMode == 7 { csrs.floatingPointRoundingMode } else { roundingMode }
            let converted = switch effectiveRoundingMode {
            case 0, 4:
                unconverted.rounded()
            case 1:
                unconverted
            case 2:
                floor(unconverted)
            case 3:
                ceil(unconverted)
            default:
                fatalError("TODO: Exception for invalid rounding mode")
            }
            registers[Int(destinationRegister)] = Int64(Int32(converted))
            if unconverted != Float(Int64(converted)) {
                try csrs.addFloatingPointExceptions([.inexact])
            }
        case let .fcvtwus(destinationRegister, sourceRegister, roundingMode):
            let unconverted = fpRegisters[Int(sourceRegister)].nanBoxedFloat
            guard (!unconverted.isInfinite || unconverted.sign != .plus) && !unconverted.isNaN else {
                registers[Int(destinationRegister)] = Int64(UInt32.max.signExtension())
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted > Float(UInt32.min) - 1 else {
                registers[Int(destinationRegister)] = Int64(UInt32.min)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard !unconverted.isInfinite || unconverted.sign != .minus else {
                registers[Int(destinationRegister)] = Int64(UInt32.min)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted <= Float(UInt32.max) else {
                registers[Int(destinationRegister)] = Int64(UInt32.max.signExtension())
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            let effectiveRoundingMode = if roundingMode == 7 { csrs.floatingPointRoundingMode } else { roundingMode }
            var converted = switch effectiveRoundingMode {
            case 0, 4:
                unconverted.rounded()
            case 1:
                unconverted
            case 2:
                floor(unconverted)
            case 3:
                ceil(unconverted)
            default:
                fatalError("TODO: Exception for invalid rounding mode")
            }
            if converted < 0 {
                converted = 0
            }
            registers[Int(destinationRegister)] = Int64(UInt32(converted).signExtension())
            if unconverted != Float(UInt32(converted)) {
                try csrs.addFloatingPointExceptions([.inexact])
            }
        case .feqs(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = fpRegisters[Int(sourceRegister1)].nanBoxedFloat
            let secondOperand = fpRegisters[Int(sourceRegister2)].nanBoxedFloat
            registers[Int(destinationRegister)] = if firstOperand == secondOperand { 1 } else { 0 }
            if firstOperand.isSignalingNaN || secondOperand.isSignalingNaN {
                try csrs.addFloatingPointExceptions([.invalid])
            }
        case .flts(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = fpRegisters[Int(sourceRegister1)].nanBoxedFloat
            let secondOperand = fpRegisters[Int(sourceRegister2)].nanBoxedFloat
            let (result, exceptions) = firstOperand.lessThanTrackingExceptions(secondOperand)
            registers[Int(destinationRegister)] = if result { 1 } else { 0 }
            try csrs.addFloatingPointExceptions(exceptions)
            // Invalid even if quiet NaNs
            if firstOperand.isNaN || secondOperand.isNaN {
                try csrs.addFloatingPointExceptions([.invalid])
            }
        case .fles(let destinationRegister, let sourceRegister1, let sourceRegister2):
            let firstOperand = fpRegisters[Int(sourceRegister1)].nanBoxedFloat
            let secondOperand = fpRegisters[Int(sourceRegister2)].nanBoxedFloat
            registers[Int(destinationRegister)] = if firstOperand <= secondOperand { 1 } else { 0 }
            // Invalid even if quiet NaNs
            if firstOperand.isNaN || secondOperand.isNaN {
                try csrs.addFloatingPointExceptions([.invalid])
            }
        case .fmvxw(let destinationRegister, let sourceRegister):
            registers[Int(destinationRegister)] = Int64(fpRegisters[Int(sourceRegister)].nanBoxedFloat.bitPattern.signExtension())
        case .fclasss(let destinationRegister, let sourceRegister):
            registers[Int(destinationRegister)] = switch fpRegisters[Int(sourceRegister)].nanBoxedFloat.floatingPointClass {
            case .negativeInfinity:
                0x1
            case .negativeNormal:
                0x2
            case .negativeSubnormal:
                0x4
            case .negativeZero:
                0x8
            case .positiveZero:
                0x10
            case .positiveSubnormal:
                0x20
            case .positiveNormal:
                0x40
            case .positiveInfinity:
                0x80
            case .signalingNaN:
                0x100
            case .quietNaN:
                0x200
            }
        case .fmvwx(let destinationRegister, let sourceRegister):
            let bitPattern = UInt32(UInt64(bitPattern: registers[Int(sourceRegister)]) & 0xffffffff)
            fpRegisters[Int(destinationRegister)] = Double(nanBoxing: Float(bitPattern: bitPattern))
        case let .fcvtls(destinationRegister, sourceRegister, roundingMode):
            let unconverted = fpRegisters[Int(sourceRegister)].nanBoxedFloat
            guard (!unconverted.isInfinite || unconverted.sign != .plus) && !unconverted.isNaN else {
                registers[Int(destinationRegister)] = Int64.max
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted > Float(Int64.min) else {
                registers[Int(destinationRegister)] = Int64.min
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard !unconverted.isInfinite || unconverted.sign != .minus else {
                registers[Int(destinationRegister)] = Int64.min
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted < Float(Int64.max) else {
                registers[Int(destinationRegister)] = Int64.max
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            let effectiveRoundingMode = if roundingMode == 7 { csrs.floatingPointRoundingMode } else { roundingMode }
            let converted = switch effectiveRoundingMode {
            case 0, 4:
                unconverted.rounded()
            case 1:
                unconverted
            case 2:
                floor(unconverted)
            case 3:
                ceil(unconverted)
            default:
                fatalError("TODO: Exception for invalid rounding mode")
            }
            registers[Int(destinationRegister)] = Int64(converted)
            if unconverted != Float(Int64(converted)) {
                try csrs.addFloatingPointExceptions([.inexact])
            }
        case let .fcvtlus(destinationRegister, sourceRegister, roundingMode):
            let unconverted = fpRegisters[Int(sourceRegister)].nanBoxedFloat
            guard (!unconverted.isInfinite || unconverted.sign != .plus) && !unconverted.isNaN else {
                registers[Int(destinationRegister)] = UInt64.max.signExtension()
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted > Float(UInt64.min) - 1 else {
                registers[Int(destinationRegister)] = Int64(bitPattern: UInt64.min)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard !unconverted.isInfinite || unconverted.sign != .minus else {
                registers[Int(destinationRegister)] = Int64(bitPattern: UInt64.min)
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            guard unconverted <= Float(UInt64.max) else {
                registers[Int(destinationRegister)] = UInt64.max.signExtension()
                try csrs.addFloatingPointExceptions([.invalid])
                break
            }
            let effectiveRoundingMode = if roundingMode == 7 { csrs.floatingPointRoundingMode } else { roundingMode }
            var converted = switch effectiveRoundingMode {
            case 0, 4:
                unconverted.rounded()
            case 1:
                unconverted
            case 2:
                floor(unconverted)
            case 3:
                ceil(unconverted)
            default:
                fatalError("TODO: Exception for invalid rounding mode")
            }
            if converted < 0 {
                converted = 0
            }
            registers[Int(destinationRegister)] = UInt64(converted).signExtension()
            if unconverted != Float(UInt64(converted)) {
                try csrs.addFloatingPointExceptions([.inexact])
            }
        case .ecall:
            if let ecallHandler {
                ecallHandler.ecall(cpu: self)
                break
            }
            //TODO
            break
        case .ebreak:
            fatalError("TODO: ebreak")
        //TODO: Instructions that access a non-existent CSR are reserved. Attempts to access a CSR without
        // appropriate privilege level raise illegal-instruction exception
        //TODO: Machine-mode standard read-write CSRs 0x7A0-0x7BF are reserved for use by the debug system. Of
        // these CSRs, 0x7A0-0x7AF are accessible to machine mode, whereas 0x7B0-0x7BF are only visible to
        // debug mode. Implementations should raise illegal-instruction exceptions on machine-mode access to
        // the latter set of registers.
        case .csrrw(destinationRegister: let destinationRegister, sourceRegister: let sourceRegister, csr: let csr):
            //TODO: This should be atomic, even in multiple-hart environments
            //The CSRRW (Atomic Read/Write CSR) instruction atomically swaps values in the CSRs and
            // integer registers.
            // If rd=x0, then
            // the instruction shall not read the CSR and shall not cause any of the side effects that might occur
            // on a CSR read.
            if destinationRegister != 0 {
                // CSRRW reads the old value of the CSR, zero-extends the value to XLEN bits,
                let csrValue = try csrs.value(of: csr)
                // then writes it to integer register rd.
                registers[Int(destinationRegister)] = Int64(bitPattern: csrValue)
            }
            // The initial value in rs1 is written to the CSR.
            try csrs.set(csr, to: UInt64(bitPattern: registers[Int(sourceRegister)]))
        case .csrrs(destinationRegister: let destinationRegister, sourceRegister: let sourceRegister, csr: let csr):
            // The CSRRS (Atomic Read and Set Bits in CSR) instruction reads the value of the CSR,
            let csrValue = try csrs.value(of: csr)
            // zero-extends the value to XLEN bits,
            // Already done here
            // and writes it to integer register rd.
            registers[Int(destinationRegister)] = Int64(bitPattern: csrValue)
            // The initial value in integer register rs1 is treated as a bit mask that specifies bit positions to be set in the CSR. Any bit that
            // is high in rs1 will cause the corresponding bit to be set in the CSR, if that CSR bit is writable.
            // Other bits in the CSR are unaffected (though CSRs might have side effects when written).
            let bitMask = UInt64(bitPattern: registers[Int(sourceRegister)])
            if bitMask != 0 {
                try csrs.set(csr, to: csrValue | bitMask)
            }
        case .csrrc(destinationRegister: let destinationRegister, sourceRegister: let sourceRegister, csr: let csr):
            let csrValue = try csrs.value(of: csr)
            registers[Int(destinationRegister)] = Int64(bitPattern: csrValue)
            let bitMask = UInt64(bitPattern: registers[Int(sourceRegister)])
            if bitMask != 0 {
                try csrs.set(csr, to: csrValue & ~bitMask)
            }
        case .csrrwi(destinationRegister: let destinationRegister, immediate: let immediate, csr: let csr):
            // Similar to csrrw, but with an immediate instead.
            //TODO: This should be atomic, even in multiple-hart environments
            if destinationRegister != 0 {
                // CSRRW reads the old value of the CSR, zero-extends the value to XLEN bits,
                let csrValue = try csrs.value(of: csr)
                // then writes it to integer register rd.
                registers[Int(destinationRegister)] = Int64(bitPattern: csrValue)
            }
            // The initial value in rs1 is written to the CSR.
            try csrs.set(csr, to: UInt64(immediate).signExtension(ofBitCount: 5))
        case .csrrsi(destinationRegister: let destinationRegister, immediate: let immediate, csr: let csr):
            let csrValue = try csrs.value(of: csr)
            registers[Int(destinationRegister)] = Int64(bitPattern: csrValue)
            let bitMask = UInt64(bitPattern: Int64(immediate))
            if bitMask != 0 {
                try csrs.set(csr, to: csrValue | bitMask)
            }
        case .csrrci(destinationRegister: let destinationRegister, immediate: let immediate, csr: let csr):
            let csrValue = try csrs.value(of: csr)
            registers[Int(destinationRegister)] = Int64(bitPattern: csrValue)
            let bitMask = UInt64(bitPattern: Int64(immediate))
            if bitMask != 0 {
                try csrs.set(csr, to: csrValue & ~bitMask)
            }
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
        for (index, register) in fpRegisters.enumerated() {
            if register.isNaN && !register.nanBoxedFloat.isNaN && register.bitPattern & 0xffffffff00000000 == 0xffffffff00000000 {
                print("f\(index) = \(register.nanBoxedFloat) (nan boxed to 64 bits) (0x\(String(register.bitPattern, radix: 16)))")
            } else {
                print("f\(index) = \(register) (0x\(String(register.bitPattern, radix: 16)))")
            }
        }
        print("pc = 0x\(String(pc, radix: 16))")
    }
}
