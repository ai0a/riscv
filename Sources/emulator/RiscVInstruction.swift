//
//  RiscVInstruction.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

enum RiscVInstruction {
    init?(encodedInstruction: UInt32) {
        let opcode = encodedInstruction & 0x7f
        switch opcode {
        case 0x13:
            let decoded = IType(encodedInstruction: encodedInstruction)
            switch decoded.funct3 {
            case 0:
                self = .addi(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 2:
                self = .slti(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 3:
                self = .sltiu(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: UInt(bitPattern: decoded.immediate))
            case 4:
                self = .xori(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 6:
                self = .ori(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 7:
                self = .andi(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 1:
                // `& ((1 << 7) - 2)` because it should only check the highest *6* bits, not 7.
                guard RiscVDecoding.funct7(from: encodedInstruction) & ((1 << 7) - 2) == 0 else {
                    return nil
                }
                self = .slli(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, shamt: decoded.immediate)
            case 5:
                switch (RiscVDecoding.funct7(from: encodedInstruction)) {
                case 0:
                    self = .srli(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, shamt: decoded.immediate)
                case 0x20:
                    self = .srai(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, shamt: decoded.immediate & 0x1F)
                default:
                    return nil
                }
            default:
                return nil
            }
        case 0x33:
            let decoded = RType(encodedInstruction: encodedInstruction)
            switch decoded.funct3 {
            case 0:
                switch decoded.funct7 {
                case 0:
                    self = .add(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .mul(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 32:
                    self = .sub(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 1:
                switch decoded.funct7 {
                case 0:
                    self = .sll(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .mulh(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 2:
                switch decoded.funct7 {
                case 0:
                    self = .slt(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .mulhsu(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 3:
                switch decoded.funct7 {
                case 0:
                    self = .sltu(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .mulhu(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 4:
                switch decoded.funct7 {
                case 0:
                    self = .xor(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .div(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 5:
                switch decoded.funct7 {
                case 0:
                    self = .srl(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .divu(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 32:
                    self = .sra(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 6:
                switch decoded.funct7 {
                case 0:
                    self = .or(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .rem(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 7:
                switch decoded.funct7 {
                case 0:
                    self = .and(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .remu(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            default:
                return nil
            }
        case 0x37:
            let decoded = UType(encodedInstruction: encodedInstruction)
            self = .lui(destinationRegister: decoded.destinationRegister, immediate: decoded.immediate)
        case 0x17:
            let decoded = UType(encodedInstruction: encodedInstruction)
            self = .auipc(destinationRegister: decoded.destinationRegister, immediate: decoded.immediate)
        case 0x6f:
            let decoded = JType(encodedInstruction: encodedInstruction)
            self = .jal(destinationRegister: decoded.destinationRegister, offset: decoded.offset)
        case 0x67:
            let decoded = IType(encodedInstruction: encodedInstruction)
            guard decoded.funct3 == 0 else {
                return nil
            }
            self = .jalr(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, offsetImmediate: decoded.immediate)
        case 0x63:
            let decoded = BType(encodedInstruction: encodedInstruction)
            switch decoded.funct3 {
            case 0:
                self = .beq(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, offset: decoded.offset)
            case 1:
                self = .bne(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, offset: decoded.offset)
            case 4:
                self = .blt(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, offset: decoded.offset)
            case 5:
                self = .bge(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, offset: decoded.offset)
            case 6:
                self = .bltu(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, offset: decoded.offset)
            case 7:
                self = .bgeu(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, offset: decoded.offset)
            default:
                return nil
            }
        case 0xf:
            let decoded = IType(encodedInstruction: encodedInstruction)
            switch decoded.funct3 {
            case 0:
                guard encodedInstruction & 0xfffff == 0xf else {
                    return nil
                }
                self = .fence
            case 1:
                self = .fencei
            default:
                return nil
            }
        case 0x73:
            let funct3 = RiscVDecoding.funct3(from: encodedInstruction)
            guard funct3 != 0 else {
                let decoded = IType(encodedInstruction: encodedInstruction)
                switch (decoded.immediate) {
                case 0:
                    self = .ecall
                case 1:
                    self = .ebreak
                case 770:
                    self = .mret
                default:
                    return nil
                }
                return
            }
            switch funct3 >> 2 {
            case 0:
                let decoded = CSRType(encodedInstruction: encodedInstruction)
                switch funct3 {
                case 1:
                    self = .csrrw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, csr: decoded.csr)
                case 2:
                    self = .csrrs(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, csr: decoded.csr)
                case 3:
                    self = .csrrc(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, csr: decoded.csr)
                default:
                    return nil
                }
            case 1:
                let decoded = CSRIType(encodedInstruction: encodedInstruction)
                switch funct3 {
                case 5:
                    self = .csrrwi(destinationRegister: decoded.destinationRegister, immediate: decoded.immediate, csr: decoded.csr)
                case 6:
                    self = .csrrsi(destinationRegister: decoded.destinationRegister, immediate: decoded.immediate, csr: decoded.csr)
                case 7:
                    self = .csrrci(destinationRegister: decoded.destinationRegister, immediate: decoded.immediate, csr: decoded.csr)
                default:
                    return nil
                }
            default:
                // This should NEVER happen (should not be possible), so if it does, throw a huge fit
                fatalError("Somehow got a more than three-bit funct3")
            }
        case 0x3:
            let decoded = IType(encodedInstruction: encodedInstruction)
            switch (decoded.funct3) {
            case 0:
                self = .lb(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 1:
                self = .lh(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 2:
                self = .lw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 3:
                self = .ld(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 4:
                self = .lbu(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 5:
                self = .lhu(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            case 6:
                self = .lwu(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            default:
                return nil
            }
        case 0x7:
            let decoded = IType(encodedInstruction: encodedInstruction)
            switch decoded.funct3 {
            case 2:
                self = .flw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: decoded.immediate)
            default:
                return nil
            }
        case 0x23:
            let decoded = SType(encodedInstruction: encodedInstruction)
            switch (decoded.funct3) {
            case 0:
                self = .sb(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, immediate: decoded.immediate)
            case 1:
                self = .sh(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, immediate: decoded.immediate)
            case 2:
                self = .sw(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, immediate: decoded.immediate)
            case 3:
                self = .sd(sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, immediate: decoded.immediate)
            default:
                return nil
            }
        case 0x1B:
            let decoded = IType(encodedInstruction: encodedInstruction)
            guard decoded.funct3 != 0 else {
                let immediate = Int((UInt32(bitPattern: Int32(decoded.immediate & ((1 << 12) - 1))) << 20).signExtension() >> 20)
                self = .addiw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, immediate: immediate)
                return
            }
            let funct7 = RiscVDecoding.funct7(from: encodedInstruction)
            let shamt = Int(RiscVDecoding.sourceRegister2(from: encodedInstruction))
            switch (decoded.funct3) {
            case 1:
                guard funct7 == 0 else {
                    return nil
                }
                self = .slliw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, shamt: shamt)
            case 5:
                switch (funct7) {
                case 0:
                    self = .srliw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, shamt: shamt)
                case 32:
                    self = .sraiw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister, shamt: shamt)
                default:
                    return nil
                }
            default:
                return nil
            }
        case 0x3B:
            let decoded = RType(encodedInstruction: encodedInstruction)
            switch (decoded.funct3) {
            case 0:
                switch (decoded.funct7) {
                case 0:
                    self = .addw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .mulw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 32:
                    self = .subw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 1:
                guard decoded.funct7 == 0 else {
                    return nil
                }
                self = .sllw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
            case 4:
                switch decoded.funct7 {
                case 1:
                    self = .divw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 5:
                switch decoded.funct7 {
                case 0:
                    self = .srlw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .divuw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 32:
                    self = .sraw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 6:
                guard decoded.funct7 == 1 else {
                    return nil
                }
                self = .remw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
            case 7:
                guard decoded.funct7 == 1 else {
                    return nil
                }
                self = .remuw(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
            default:
                return nil
            }
        case 0x53:
            let decoded = RType(encodedInstruction: encodedInstruction)
            switch decoded.funct7 {
            case 0:
                self = .fadds(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, roundingMode: decoded.funct3)
            case 4:
                self = .fsubs(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, roundingMode: decoded.funct3)
            case 8:
                self = .fmuls(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2, roundingMode: decoded.funct3)
            case 0x50:
                switch decoded.funct3 {
                case 0:
                    self = .fles(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 1:
                    self = .flts(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                case 2:
                    self = .feqs(destinationRegister: decoded.destinationRegister, sourceRegister1: decoded.sourceRegister1, sourceRegister2: decoded.sourceRegister2)
                default:
                    return nil
                }
            case 0x60:
                switch decoded.sourceRegister2 {
                case 0:
                    self = .fcvtws(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister1, roundingMode: decoded.funct3)
                case 1:
                    self = .fcvtwus(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister1, roundingMode: decoded.funct3)
                default:
                    return nil
                }
            case 0x70:
                switch decoded.funct3 {
                case 0:
                    self = .fmvxw(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister1)
                case 1:
                    self = .fclasss(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister1)
                default:
                    return nil
                }
            case 0x78:
                switch decoded.funct3 {
                case 0:
                    self = .fmvwx(destinationRegister: decoded.destinationRegister, sourceRegister: decoded.sourceRegister1)
                default:
                    return nil
                }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    //rv64i
    case lb(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case lbu(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case lh(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case lhu(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case lw(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case lwu(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case ld(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case sb(sourceRegister1: UInt8, sourceRegister2: UInt8, immediate: Int)
    case sh(sourceRegister1: UInt8, sourceRegister2: UInt8, immediate: Int)
    case sw(sourceRegister1: UInt8, sourceRegister2: UInt8, immediate: Int)
    case sd(sourceRegister1: UInt8, sourceRegister2: UInt8, immediate: Int)
    case fence
    case ecall
    case ebreak
    case jalr(destinationRegister: UInt8, sourceRegister: UInt8, offsetImmediate: Int)
    case jal(destinationRegister: UInt8, offset: Int)
    case beq(sourceRegister1: UInt8, sourceRegister2: UInt8, offset: Int)
    case bne(sourceRegister1: UInt8, sourceRegister2: UInt8, offset: Int)
    case blt(sourceRegister1: UInt8, sourceRegister2: UInt8, offset: Int)
    case bltu(sourceRegister1: UInt8, sourceRegister2: UInt8, offset: Int)
    case bge(sourceRegister1: UInt8, sourceRegister2: UInt8, offset: Int)
    case bgeu(sourceRegister1: UInt8, sourceRegister2: UInt8, offset: Int)
    case lui(destinationRegister: UInt8, immediate: Int)
    case auipc(destinationRegister: UInt8, immediate: Int)
    case addi(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case addiw(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case xori(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case ori(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case andi(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case slli(destinationRegister: UInt8, sourceRegister: UInt8, shamt: Int)
    case slliw(destinationRegister: UInt8, sourceRegister: UInt8, shamt: Int)
    case srli(destinationRegister: UInt8, sourceRegister: UInt8, shamt: Int)
    case srliw(destinationRegister: UInt8, sourceRegister: UInt8, shamt: Int)
    case srai(destinationRegister: UInt8, sourceRegister: UInt8, shamt: Int)
    case sraiw(destinationRegister: UInt8, sourceRegister: UInt8, shamt: Int)
    case slti(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case sltiu(destinationRegister: UInt8, sourceRegister: UInt8, immediate: UInt)
    case add(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case addw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case sub(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case subw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case sll(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case sllw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case srl(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case srlw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case sra(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case sraw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case slt(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case sltu(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case xor(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case or(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case and(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    // f extension
    case flw(destinationRegister: UInt8, sourceRegister: UInt8, immediate: Int)
    case fadds(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8, roundingMode: UInt8)
    case fsubs(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8, roundingMode: UInt8)
    case fmuls(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8, roundingMode: UInt8)
    case fcvtws(destinationRegister: UInt8, sourceRegister: UInt8, roundingMode: UInt8)
    case fcvtwus(destinationRegister: UInt8, sourceRegister: UInt8, roundingMode: UInt8)
    case fmvxw(destinationRegister: UInt8, sourceRegister: UInt8)
    case feqs(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case flts(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case fles(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case fclasss(destinationRegister: UInt8, sourceRegister: UInt8)
    case fmvwx(destinationRegister: UInt8, sourceRegister: UInt8)
    // m extension
    case mul(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case mulw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case mulh(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case mulhsu(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case mulhu(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case div(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case divw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case divu(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case divuw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case rem(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case remw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case remu(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    case remuw(destinationRegister: UInt8, sourceRegister1: UInt8, sourceRegister2: UInt8)
    //zicsr
    case csrrw(destinationRegister: UInt8, sourceRegister: UInt8, csr: Int)
    case csrrs(destinationRegister: UInt8, sourceRegister: UInt8, csr: Int)
    case csrrc(destinationRegister: UInt8, sourceRegister: UInt8, csr: Int)
    case csrrwi(destinationRegister: UInt8, immediate: Int, csr: Int)
    case csrrsi(destinationRegister: UInt8, immediate: Int, csr: Int)
    case csrrci(destinationRegister: UInt8, immediate: Int, csr: Int)
    // zifenci
    case fencei
    // Privileged
    case mret
}
