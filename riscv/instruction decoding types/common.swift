//
//  common.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

struct RiscVDecoding {
    static func destinationRegister(from encodedInstruction: UInt32) -> UInt8 {
        UInt8((encodedInstruction >> 7) & 0x1f)
    }
    static func sourceRegister1(from encodedInstruction: UInt32) -> UInt8 {
        UInt8((encodedInstruction >> 15) & 0x1f)
    }
    static func sourceRegister2(from encodedInstruction: UInt32) -> UInt8 {
        UInt8((encodedInstruction >> 20) & 0x1f)
    }
    static func funct3(from encodedInstruction: UInt32) -> UInt8 {
        UInt8((encodedInstruction >> 12) & 0x07)
    }
    static func funct7(from encodedInstruction: UInt32) -> UInt8 {
        UInt8((encodedInstruction >> 25) & 0x7F)
    }
}
