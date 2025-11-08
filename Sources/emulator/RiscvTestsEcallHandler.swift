import Foundation

struct RiscvTestsEcallHandler: EcallHandler {
	func ecall(cpu: CPU) {
		guard cpu.pc > 0x1a0 else {
			return // There is an ecall earlier in the code, ignore that
		}
		let testPassed = cpu.registers[3] == 1 && cpu.registers[10] == 0
		if testPassed {
			exit(0)
		} else {
			print("Failed!")
			cpu.printRegisters()
			exit(1)
		}
	}
}