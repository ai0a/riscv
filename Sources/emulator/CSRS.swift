import Foundation

struct CSRS {
	func value(of index: Int) throws -> UInt64 {
		if index == 0x300 {
			return 0 //TODO: This is mstatus
		}
		guard let register = CSR(rawValue: index) else {
			throw Error.unknownCSR(index) // Not correct, should be reserved. See TODO in CPU.swift
		}
		switch register {
		case .fflags:
			return UInt64(fcsr & 0x1F)
		case .fcsr:
			return UInt64(fcsr)
		case .cycle:
			return cycleCount
		case .time:
			return UInt64(bitPattern: Int64(Date().timeIntervalSince(timeStart)))
		case .instret:
			// Since cycleCount is just the amount of instructions executed, can just use that
			return cycleCount - 1
		case .mhartid:
			return 0 // TODO: Other harts
		case .mie:
			return 0
		case .mtvec:
			return mtvec
		case .mepc:
			return mepc
		case .pmpaddr0:
			return 0 //TODO
		case .pmpcfg0:
			return 0 //TODO
		}
	}

	mutating func set(_ index: Int, to value: UInt64) throws {
		if index == 0x744 {
			return //TODO: This is MNSTATUS, which is not implemented so far. This is necessary to run riscv-tests
		}
		if index == 0x180 {
			return // TODO: This is SATP, which is not implemented so far. This is necessary to run riscv-tests
		}
		if index == 0x302 || index == 0x303 {
			return //TODO: This is medeleg and mideleg, which should not exist unless S mode is implemented
		}
		if index == 0x300 {
			return //TODO: This is mstatus
		}
		guard let register = CSR(rawValue: index) else {
			throw Error.unknownCSR(index) // Not correct, should be reserved. See TODO in CPU.swift
		}
		switch register {
		case .fflags:
			let oldFcsrValue = try self.value(of: CSR.fcsr.rawValue)
			try set(CSR.fcsr.rawValue, to: oldFcsrValue & ~0x1f | value)
		case .fcsr:
			// The first 24 bits are read only 0
			fcsr = UInt32(value & 0x7F)
		case .mie:
			break //TODO
		case .mtvec:
			//TODO: Ensure base is aligned
			let base = value >> 2
			let desiredMode = value & 0b11
			let mode = desiredMode >= 2 ? 0 : desiredMode
			mtvec = base << 2 | mode
		case .mepc:
			//TODO: When IALIGN=16 is supported, bit 1 need not be 0
			mepc = value & ~0b11
		case .pmpaddr0:
			break //TODO
		case .pmpcfg0:
			break //TODO
		default:
			throw Error.unwritable // Not correct, what should this be?
		}
	}

	enum Error: Swift.Error {
		case unknownCSR(Int)
		case unwritable
	}

	var fcsr: UInt32 = 0
	var mtvec: UInt64 = 0
	var mepc: UInt64 = 0
	var cycleCount: UInt64 = 0
	let timeStart = Date()

	mutating func addFloatingPointExceptions(_ exceptions: Set<FloatingPointException>) throws {
		var newBits = 0 as UInt32
		if exceptions.contains(.inexact) {
			newBits |= 0x1
		}
		if exceptions.contains(.underflow) {
			newBits |= 0x2
		}
		if exceptions.contains(.overflow) {
			newBits |= 0x4
		}
		if exceptions.contains(.divisionByZero) {
			newBits |= 0x8
		}
		if exceptions.contains(.invalid) {
			newBits |= 0x10
		}
		try set(CSR.fcsr.rawValue, to: UInt64(fcsr | newBits))
	}
}

fileprivate enum CSR: Int {
	case fflags = 0x001
	case fcsr = 0x3
	case cycle = 0xC00
	case time = 0xC01
	case instret = 0xC02
	case mhartid = 0xF14
	case mie = 0x304
	case mtvec = 0x305
	case mepc = 0x341
	case pmpcfg0 = 0x3A0
	case pmpaddr0 = 0x3B0
}