extension Int32 {
	init(bitPatternFromLowerHalfOf i: Int64) {
		let lowerHalf = UInt64(bitPattern: i) & 0xffffffff
		self.init(bitPattern: UInt32(lowerHalf))
	}
}