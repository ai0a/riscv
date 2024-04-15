//
//  CSRIType.swift
//  riscv
//
//  Created by z on 4/14/24.
//

import Foundation

struct CSRIType {
    let immediate: Int // Only 5 bits
    let destinationRegister: UInt8 // Only 5 bits
    let funct3: UInt8 // Only 3 bits
    let csr: Int // Only 12 bits
    init(encodedInstruction: UInt32) {
        immediate = Int((RiscVDecoding.sourceRegister1(from: encodedInstruction) << 5).signExtension() >> 5)
        destinationRegister = RiscVDecoding.destinationRegister(from: encodedInstruction)
        funct3 = RiscVDecoding.funct3(from: encodedInstruction)
        csr = Int(encodedInstruction >> 20)
    }
}
