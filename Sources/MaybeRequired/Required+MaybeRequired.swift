//
//  Required.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 12/2/17.
//

public enum Required<Wrapped> {
	case some(Wrapped)
	case missing(type: Any.Type) // The type of value that is missing
	
	public init(_ value: Wrapped) {
		self = .some(value)
	}
}

extension Required: CanBeMaybeRequired {
	public var maybeRequired: MaybeRequired<Wrapped> {
		switch self {
		case .some(let value):
			return .some(value)
		case .missing(let missingType):
			return .missing(type: missingType)
		}
	}
}

extension Required: Binary {
	public init(fromOptional value: Wrapped?) {
		guard let value = value else {
			self = .missing(type: Wrapped.self)
			return
		}
		
		self = .some(value)
	}
}

public extension Required {
	
	public static var missing: Required {
		return .missing(type: Wrapped.self)
	}
	
	public func map<NewWrapped>(fn: (Wrapped) -> NewWrapped) -> Required<NewWrapped> {
		switch self {
		case .some(let value):
			return .some(fn(value))
		case .missing(let missingType):
			return .missing(type: missingType)
		}
	}
	
	public func flatMap<NewWrapped>(fn: (Wrapped) -> Required<NewWrapped>) -> Required<NewWrapped> {
		switch self {
		case .some(let value):
			return fn(value)
		case .missing(let missingType):
			return .missing(type: missingType)
		}
	}
	
	/// Given that `Self` is `.missing`, the return is `Required.missing`
	///
	/// Given that `Self` is `.some(value)`, the return is `Required.missing` or
	/// `Required.some(fn(value))` depending on the output of `fn(value)`
	///
	/// - parameter fn: A function returning a required value or `nil`
	public func require<NewWrapped>(fn: (Wrapped) -> NewWrapped?) -> Required<NewWrapped> {
		switch self {
		case .some(let value):
			return Required<NewWrapped>(fromOptional: fn(value))
		case .missing(let missingType):
			return .missing(type: missingType)
		}
	}
	
	/// Given that `Self` is `.missing`, the return is `MaybeRequired.missing`
	///
	/// Given that `Self` is `.some(value)`, the return is `MaybeRequired.none` or
	/// `MaybeRequired.some(fn(value))` depending on the output of `fn(value)`
	///
	/// - parameter fn: A function returning an optional value or `nil`
	public func suppose<NewWrapped>(fn: (Wrapped) -> NewWrapped?) -> MaybeRequired<NewWrapped> {
		switch self {
		case .some(let value):
			return fn(value).maybeRequired
		case .missing(let missingType):
			return .missing(type: missingType)
		}
	}
}

extension Required: CustomStringConvertible {
	public var description: String {
		switch self {
		case .some(let value):
			return "Required(\(value))"
		case .missing(let missingType):
			return "Required(missing: \(missingType))"
		}
	}
}
