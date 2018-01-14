//
//  MaybeRequired.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 7/8/17.
//

import Foundation

/// If something `CanBeMaybeRequired` then it can be represented as one of:
/// - `.some(value)`
/// - `.none`
/// - `.missing`
public protocol CanBeMaybeRequired {
	associatedtype Wrapped
	
	var maybeRequired: MaybeRequired<Wrapped> { get }
	
	/// Something `isMissing` if it should have a value but it is `nil`.
	var isMissing: Bool { get }
	
	var value: Wrapped? { get }
}

public extension CanBeMaybeRequired {
	/// Something `isMissing` if it should have a value but it is `nil`.
	var isMissing: Bool {
		guard case .missing = maybeRequired else {
			return false
		}
		return true
	}
	
	var value: Wrapped? {
		guard case .some(let value) = maybeRequired else {
			return nil
		}
		return value
	}
}

/// Any two things that CanBeMaybeRequired and wrap the same type can be compared.
/// .some(v1) == .some(v2) IF v1 == v2
/// .missing == .missing
/// .none == .none
/// .missing != .none
public func ==<T1: CanBeMaybeRequired, T2: CanBeMaybeRequired>(lhs: T1, rhs: T2) -> Bool where T1.Wrapped: Equatable, T2.Wrapped == T1.Wrapped {
	switch (lhs.maybeRequired, rhs.maybeRequired) {
	case (.some(let value1), .some(let value2)) where value1 == value2:
		return true
	case (.missing, .missing):
		return true
	case (.none, .none):
		return true
		
	default:
		return false
	}
}

/// If something is `Binary` then it provides a mapping from Optional's `.none`
/// and `.some(value)` to its own binary representation.
public protocol Binary {
	associatedtype Wrapped
	
	init(fromOptional: Wrapped?)
}

public enum MaybeRequired<Wrapped> {
	case some(Wrapped)
	case none
	case missing
}

extension MaybeRequired: CanBeMaybeRequired {
	public var maybeRequired: MaybeRequired<Wrapped> { return self }
}

public extension MaybeRequired {
	
	func map<NewWrapped>(fn: (Wrapped) -> NewWrapped) -> MaybeRequired<NewWrapped> {
		switch self {
		case .some(let value):
			return .some(fn(value))
		case .none:
			return .none
		case .missing:
			return .missing
		}
	}
	
	func flatMap<NewWrapped>(fn: (Wrapped) -> MaybeRequired<NewWrapped>) -> MaybeRequired<NewWrapped> {
		switch self {
		case .some(let value):
			return fn(value)
		case .none:
			return .none
		case .missing:
			return .missing
		}
	}
	
	/// Given that `Self` is `.missing`, the return is `MaybeRequired.missing`
	///
	/// Given that `Self` is `.none`, the return is `MaybeRequired.none`
	///
	/// Given that `Self` is `.some(value)`, the return is `MaybeRequired.missing` or
	/// `MaybeRequired.some(fn(value))` depending on the output of `fn(value)`
	///
	/// - parameter fn: A function returning a required value or `nil`
	func require<NewWrapped>(fn: (Wrapped) -> NewWrapped?) -> MaybeRequired<NewWrapped> {
		switch self {
		case .some(let value):
			return Required<NewWrapped>(fromOptional: fn(value)).maybeRequired
		case .none:
			return .none
		case .missing:
			return .missing
		}
	}
	
	/// Given that `Self` is `.missing`, the return is `MaybeRequired.missing`
	///
	/// Given that `Self` is `.none`, the return is `MaybeRequired.none`
	///
	/// Given that `Self` is `.some(value)`, the return is `MaybeRequired.none` or
	/// `MaybeRequired.some(fn(value))` depending on the output of `fn(value)`
	///
	/// - parameter fn: A function returning an optional value or `nil`
	func suppose<NewWrapped>(fn: (Wrapped) -> NewWrapped?) -> MaybeRequired<NewWrapped> {
		switch self {
		case .some(let value):
			return fn(value).maybeRequired
		case .none:
			return .none
		case .missing:
			return .missing
		}
	}
}

extension MaybeRequired: CustomStringConvertible {
	public var description: String {
		switch self {
		case .some(let value):
			return "MaybeRequired(\(value))"
		case .none:
			return "MaybeRequired(none)"
		case .missing:
			return "MaybeRequired(missing)"
		}
	}
}
