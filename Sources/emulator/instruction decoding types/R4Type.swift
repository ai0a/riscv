struct R4Type {
    let destinationRegister: UInt8 // Only 5 bits
    let sourceRegister1: UInt8 // Only 5 bits
    let sourceRegister2: UInt8
	let sourceRegister3: UInt8
    let roundingMode: UInt8 // Only 3 bits
    let funct2: UInt8 // Only 2 bits
    init(encodedInstruction: UInt32) {
        destinationRegister = RiscVDecoding.destinationRegister(from: encodedInstruction)
        sourceRegister1 = RiscVDecoding.sourceRegister1(from: encodedInstruction)
        sourceRegister2 = RiscVDecoding.sourceRegister2(from: encodedInstruction)
        roundingMode = RiscVDecoding.funct3(from: encodedInstruction)
        let funct7 = RiscVDecoding.funct7(from: encodedInstruction)
		funct2 = funct7 & 0b11
		sourceRegister3 = funct7 >> 2
    }
}
