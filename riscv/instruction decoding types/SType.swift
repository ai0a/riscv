//
//  SType.swift
//  riscv
//
//  Created by z on 4/12/24.
//

import Foundation

struct SType {
    let sourceRegister1: UInt8 // Only 5 bits
    let sourceRegister2: UInt8 // Only 5 bits
    let funct3: UInt8 // Only 3 bits
    let immediate: Int
    init(encodedInstruction: UInt32) {
        sourceRegister1 = RiscVDecoding.sourceRegister1(from: encodedInstruction)
        sourceRegister2 = RiscVDecoding.sourceRegister2(from: encodedInstruction)
        funct3 = RiscVDecoding.funct3(from: encodedInstruction)
        let bits0Thru4 = (encodedInstruction >> 6) & ((1 << 5) - 1)
        let bits5Thru11 = (encodedInstruction >> 25) << 5
        let uImmediate = bits0Thru4 | bits5Thru11
        immediate = Int((uImmediate << 11).signExtension() >> 11)
    }
}
