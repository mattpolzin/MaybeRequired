import Foundation

/// A `MaybeRequired` value is one of:
/// - `.some(T)`
/// - `.none(Necessity)`
///
/// The builtin necessities are `Necessary` and `Unnecessary` which get you
/// `.none(.necessary)` and `.none(.unnecessary)`, respectively.
///
/// If you `flatMap` from one `MaybeRequired<Necessary, _>` to another,
/// your result will be a `MaybeRequired<Necessary, _>`. 
///
/// If you `flatMap` from one `MaybeRequired<Unnecessary, _>` to another your 
/// result will be a `MaybeRequired<Unnecessary, _>`. 
///
/// However, if you `flatMap` from a `Necessary` to an `Unnecessary` or 
/// vice versa then your result will be a `MaybeRequired<MaybeNecessary, _>`.
public enum MaybeRequired<NoneType: Necessity, SomeType> {
	case none(NoneType)
	case some(SomeType)
}

public extension MaybeRequired where NoneType: StrictNecessity {
	
	/// Create a `MaybeRequired` value with the specified necessity.
	///
	/// If your `Optional` is `.some` then the `MaybeRequired` will be as well.
	public init(_ value: SomeType?) {
		guard let trueValue = value else {
			self = .none(NoneType())
			return
		}
		
		self = .some(trueValue)
	}
}

public extension MaybeRequired {
	
	/// Map to another `MaybeRequired` of the same necessity.
	public func flatMap<SomeOtherType>(_ f: (SomeType) -> MaybeRequired<NoneType, SomeOtherType>) -> MaybeRequired<NoneType, SomeOtherType> {
		switch self {
		case .none(let necessity):
			return .none(necessity)
			
		case .some(let value):
			return f(value)
		}
	}
	
	/// Map to another `MaybeRequired` of different necessity.
	public func flatMap<U: Necessity, SomeOtherType>(_ f: (SomeType) -> MaybeRequired<U, SomeOtherType>) -> MaybeRequired<MaybeNecessary, SomeOtherType> {
		switch self {
		case .none(let maybeRequired):
			return .none(maybeRequired.necessity)
			
		case .some(let value):
			switch f(value) {
			case .none(let maybeRequired):
				return .none(maybeRequired.necessity)
				
			case .some(let value):
				return .some(value)
			}
		}
	}
}

extension MaybeRequired: CustomStringConvertible {
	public var description: String {
		switch self {
		case .none(let noneValue):
			return ".none(\(noneValue))"
		case .some(let someValue):
			return ".some(\(someValue))"
		}
	}
}

public protocol Necessity {
	var necessity: MaybeNecessary { get }
}

/// Strict Necessities can be initialized with no arguments to a default value.
///
/// The intention is for this to be reasonable only because they have one, and
/// only one, possible value.
public protocol StrictNecessity: Necessity {
	init()
}

public enum Unnecessary: StrictNecessity {
	case unnecessary
	
	public var necessity: MaybeNecessary { return .unnecessary }
	
	public init() {
		self = .unnecessary
	}
}

extension Unnecessary: CustomStringConvertible {
	public var description: String {
		return ".unnecessary"
	}
}

public enum Necessary: StrictNecessity {
	case necessary
	
	public var necessity: MaybeNecessary { return .necessary }
	
	public init() {
		self = .necessary
	}
}

extension Necessary: CustomStringConvertible {
	public var description: String {
		return ".necessary"
	}
}

public enum MaybeNecessary: Necessity {
	case unnecessary
	case necessary
	
	public var necessity: MaybeNecessary { return self }
}

extension MaybeNecessary: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unnecessary:
			return "MaybeNecessary.unnecessary"
			
		case .necessary:
			return "MaybeNecessary.necessary"
		}
	}
}
