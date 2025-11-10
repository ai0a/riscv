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

extension FloatingPoint {
	// Spooky!
	private func trackExceptions<T>(for op: (Self, Self) -> T, on other: Self) -> (T, exceptions: Set<FloatingPointException>) {
		// Clear existing floating-point exceptions
		feclearexcept(FE_ALL_EXCEPT)

		let result = op(self, other)
		
		// Capture exceptions
		let exceptions = fetestexcept(FE_ALL_EXCEPT)
		
		return (result, setify(exceptions))
	}
	func squareRootTrackingExceptions() -> (Self, exceptions: Set<FloatingPointException>) {
		// Clear existing floating-point exceptions
		feclearexcept(FE_ALL_EXCEPT)

		let result = self.squareRoot()
		
		// Capture exceptions
		let exceptions = fetestexcept(FE_ALL_EXCEPT)
		
		return (result, setify(exceptions))
	}

	func multiplyAddTrackingExceptions(_ other: Self, _ other2: Self) -> (Self, exceptions: Set<FloatingPointException>) {
		// Clear existing floating-point exceptions
		feclearexcept(FE_ALL_EXCEPT)

		let result = other2.addingProduct(self, other)
		
		// Capture exceptions
		let exceptions = fetestexcept(FE_ALL_EXCEPT)
		
		return (result, setify(exceptions))
	}

	func addingTrackingExceptions(_ other: Self) -> (Self, exceptions: Set<FloatingPointException>) {
		trackExceptions(for: +, on: other)
	}

	func subtractingTrackingExceptions(_ other: Self) -> (Self, exceptions: Set<FloatingPointException>) {
		trackExceptions(for: -, on: other)
	}

	func multiplyingTrackingExceptions(_ other: Self) -> (Self, exceptions: Set<FloatingPointException>) {
		trackExceptions(for: *, on: other)
	}

	func dividingTrackingExceptions(_ other: Self) -> (Self, exceptions: Set<FloatingPointException>) {
		trackExceptions(for: /, on: other)
	}

	func lessThanTrackingExceptions(_ other: Self) -> (Bool, exceptions: Set<FloatingPointException>) {
		trackExceptions(for: <, on: other)
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