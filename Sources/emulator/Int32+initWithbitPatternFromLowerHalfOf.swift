extension Int32 {
	init(bitPatternFromLowerHalfOf i: Int64) {
		self.init(bitPattern: UInt32(i))
	}
}