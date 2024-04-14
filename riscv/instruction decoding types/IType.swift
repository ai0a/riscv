//
//  IType.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

struct IType {
    let destinationRegister: UInt8 // Only 5 bits
    let sourceRegister: UInt8 // Only 5 bits
    let immediate: Int
    let funct3: UInt8 // Only 3 bits
    init(encodedInstruction: UInt32) {
        destinationRegister = RiscVDecoding.destinationRegister(from: encodedInstruction)
        sourceRegister = RiscVDecoding.sourceRegister1(from: encodedInstruction)
        let sexedInstruction = (encodedInstruction & 0xfff00000).signExtension()
        immediate = Int(sexedInstruction >> 20)
        funct3 = RiscVDecoding.funct3(from: encodedInstruction)
    }
}
