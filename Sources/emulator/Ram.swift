//
//  Ram.swift
//  riscv
//
//  Created by z on 4/6/24.
//

import Foundation

struct Memory {
    var data: Data
    
    func read64Bits(address: UInt64) throws -> UInt64 {
        guard address < data.count - 8 else {
            throw MemoryError.invalidAddress
        }
        return data.subdata(in: Data.Index(address)..<Data.Index(address) + 8).withUnsafeBytes {
            $0.load(as: UInt64.self).littleEndian
        }
    }
    
    func read32Bits(address: UInt64) throws -> UInt32 {
        guard address < data.count - 4 else {
            throw MemoryError.invalidAddress
        }
        return data.subdata(in: Data.Index(address)..<Data.Index(address) + 4).withUnsafeBytes {
            $0.load(as: UInt32.self).littleEndian
        }
    }
    
    func read16Bits(address: UInt64) throws -> UInt16 {
        guard address < data.count - 2 else {
            throw MemoryError.invalidAddress
        }
        return data.subdata(in: Data.Index(address)..<Data.Index(address) + 2).withUnsafeBytes {
            $0.load(as: UInt16.self).littleEndian
        }
    }
    
    func read8Bits(address: UInt64) throws -> UInt8 {
        guard address < data.count else {
            throw MemoryError.invalidAddress
        }
        return data[Int(address)]
    }
    
    mutating func store8Bits(_ data: UInt8, at address: UInt64) throws {
        guard address < self.data.count else {
            throw MemoryError.invalidAddress
        }
        self.data[Int(address)] = data
    }
    
    mutating func store16Bits(_ data: UInt16, at address: UInt64) throws {
        // Store most significant bytes last
        try store8Bits(UInt8(data >> 8), at: address + 1)
        try store8Bits(UInt8(data & 0xff), at: address)
    }
    
    mutating func store32Bits(_ data: UInt32, at address: UInt64) throws {
        // Store most significant bytes last
        try store8Bits(UInt8(data >> 24), at: address + 3)
        try store8Bits(UInt8((data >> 16) & 0xff), at: address + 2)
        try store8Bits(UInt8((data >> 8) & 0xff), at: address + 1)
        try store8Bits(UInt8(data & 0xff), at: address)
    }
    
    mutating func store64Bits(_ data: UInt64, at address: UInt64) throws {
        // Store most significant bytes last
        try store8Bits(UInt8((data >> 56) & 0xff), at: address + 7)
        try store8Bits(UInt8((data >> 48) & 0xff), at: address + 6)
        try store8Bits(UInt8((data >> 40) & 0xff), at: address + 5)
        try store8Bits(UInt8((data >> 32) & 0xff), at: address + 4)
        try store8Bits(UInt8((data >> 24) & 0xff), at: address + 3)
        try store8Bits(UInt8((data >> 16) & 0xff), at: address + 2)
        try store8Bits(UInt8((data >> 8) & 0xff), at: address + 1)
        try store8Bits(UInt8(data & 0xff), at: address)
    }
    
    enum MemoryError: Error {
        case invalidAddress
    }
}
