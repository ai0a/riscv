//
//  SignExtension.swift
//  riscv
//
//  Created by z on 4/8/24.
//

import Foundation

extension UInt64 {
    func signExtension() -> Int64 {
        Int64(bitPattern: self)
    }
}

extension UInt32 {
    func signExtension() -> Int32 {
        Int32(bitPattern: self)
    }
}

extension UInt16 {
    func signExtension() -> Int16 {
        Int16(bitPattern: self)
    }
}

extension UInt8 {
    func signExtension() -> Int8 {
        Int8(bitPattern: self)
    }
}
