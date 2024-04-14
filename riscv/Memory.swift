//
//  Memory.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

protocol Memory {
    func read64Bits(address: UInt64) throws -> UInt64
    mutating func store64Bits(_ data: UInt64, at address: UInt64) throws
    func read32Bits(address: UInt64) throws -> UInt32
    mutating func store32Bits(_ data: UInt32, at address: UInt64) throws
    func read8Bits(address: UInt64) throws -> UInt8
    mutating func store8Bits(_ data: UInt8, at address: UInt64) throws
    func read16Bits(address: UInt64) throws -> UInt16
    mutating func store16Bits(_ data: UInt16, at address: UInt64) throws
}
