extension Double {
	var nanBoxedFloat: Float {
		guard self.bitPattern & (0xffffffff << 32) == (0xffffffff << 32) else {
			return .nan
		}
		return uncheckingNanBoxedFloat
	}
	var uncheckingNanBoxedFloat: Float {
		let bitPattern = UInt32(self.bitPattern & 0xffffffff)
		return Float(bitPattern: bitPattern)
	}
}