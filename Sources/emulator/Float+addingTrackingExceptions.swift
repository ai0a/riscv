//TODO: This doesn't look very cross-platform!
import Darwin
import Foundation

enum FloatingPointException {
	case inexact
	case underflow
	case overflow
	case divisionByZero
	case invalid

	init?(rawValue: Int32) {
		switch rawValue {
		case FE_INEXACT:
			self = .inexact
		case FE_UNDERFLOW:
			self = .underflow
		case FE_UNDERFLOW:
			self = .overflow
		case FE_DIVBYZERO:
			self = .divisionByZero
		case FE_INVALID:
			self = .invalid
		default:
			return nil
		}
	}
}

extension Float {
	// Spooky!
	func addingTrackingExceptions(_ other: Float) -> (Float, exceptions: Set<FloatingPointException>) {
		// Clear existing floating-point exceptions
		feclearexcept(FE_ALL_EXCEPT)

		let result = self + other
		
		// Capture exceptions
		let exceptions = fetestexcept(FE_ALL_EXCEPT)
		
		return (result, setify(exceptions))
	}
}

fileprivate func setify(_ exceptions: Int32) -> Set<FloatingPointException> {
	var result = Set<FloatingPointException>()
	for i in 0 ..< 32 {
		guard exceptions & (1 << i) != 0 else {
			continue
		}
		guard let exception = FloatingPointException(rawValue: 1 << i) else {
			continue
		}
		result.insert(exception)
	}
	return result
}