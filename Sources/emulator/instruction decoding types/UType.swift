//
//  UType.swift
//  riscv
//
//  Created by z on 4/7/24.
//

import Foundation

struct UType {
    let destinationRegister: UInt8 // Only 5 bits
    let immediate: Int // Only the upper bits
    init(encodedInstruction: UInt32) {
        destinationRegister = RiscVDecoding.destinationRegister(from: encodedInstruction)
        // Just remove the lower 11 bits
        immediate = Int(encodedInstruction & 0xFFFFF800)
    }
}
