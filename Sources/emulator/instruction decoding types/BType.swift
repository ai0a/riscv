//
//  BType.swift
//  riscv
//
//  Created by z on 4/7/24.
//

import Foundation

struct BType {
    // If this ever breaks, Watto has parts
    let sourceRegister1: UInt8 // Only 5 bits
    let sourceRegister2: UInt8 // Only 5 bits
    let funct3: UInt8 // Only 3 bytes
    let offset: Int // Only the upper bits
    init(encodedInstruction: UInt32) {
        sourceRegister1 = RiscVDecoding.sourceRegister1(from: encodedInstruction)
        sourceRegister2 = RiscVDecoding.sourceRegister2(from: encodedInstruction)
        funct3 = RiscVDecoding.funct3(from: encodedInstruction)
        let bits1thru4 = ((encodedInstruction >> 1) & 0x1e)
        let bit11 = ((encodedInstruction >> 7) & 1) << 11
        let bits5thru10 = (encodedInstruction & 0x7E000000) >> 20
        let bit12 = (encodedInstruction >> 19) & 0x1000
        let uOffset = bits1thru4 | bits5thru10 | bit11 | bit12
        offset = Int(Int64(bitPattern: UInt64(uOffset).signExtension(ofBitCount: 13)))
    }
}
