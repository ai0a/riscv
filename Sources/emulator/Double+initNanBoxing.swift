extension Double {
	init(nanBoxing float: Float) {
		self = float.bitPattern.asNaNBoxedDouble
	}
}