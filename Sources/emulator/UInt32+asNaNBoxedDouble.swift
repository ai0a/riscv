extension UInt32 {
	var asNaNBoxedDouble: Double {
		let bitPattern = UInt64(self) | (0xffffffff << 32)
		return Double(bitPattern: bitPattern)
	}
}