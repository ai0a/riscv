//
//  RType.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

struct RType {
    let destinationRegister: UInt8 // Only 5 bits
    let sourceRegister1: UInt8 // Only 5 bits
    let sourceRegister2: UInt8
    let funct3: UInt8 // Only 3 bits
    let funct7: UInt8 // Only 7 bits
    init(encodedInstruction: UInt32) {
        destinationRegister = RiscVDecoding.destinationRegister(from: encodedInstruction)
        sourceRegister1 = RiscVDecoding.sourceRegister1(from: encodedInstruction)
        sourceRegister2 = RiscVDecoding.sourceRegister2(from: encodedInstruction)
        funct3 = RiscVDecoding.funct3(from: encodedInstruction)
        funct7 = RiscVDecoding.funct7(from: encodedInstruction)
    }
}
