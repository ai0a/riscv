extension Double {
	var nanBoxedFloat: Float {
		let bitPattern = UInt32(self.bitPattern & 0xffffffff)
		return Float(bitPattern: bitPattern)
	}
}