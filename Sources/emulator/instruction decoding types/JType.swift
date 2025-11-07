//
//  JType.swift
//  riscv
//
//  Created by z on 4/7/24.
//

import Foundation

struct JType {
    // If this ever breaks, Watto has parts
    let destinationRegister: UInt8 // Only 5 bits
    let offset: Int // Only the upper bits
    init(encodedInstruction: UInt32) {
        destinationRegister = RiscVDecoding.destinationRegister(from: encodedInstruction)
        let bits1thru10 = (encodedInstruction >> 20) & 0x7fe
        let bit11 = (encodedInstruction >> 9) & 0x800
        let bits12thru19 = encodedInstruction & 0xff000
        let bits20plus = (encodedInstruction & 0x80000000) >> 11
        let uOffset = bits20plus | bits12thru19 | bit11 | bits1thru10
        let sexedOffset = (uOffset << 12).signExtension() >> 12
        offset = Int(sexedOffset)
    }
}
