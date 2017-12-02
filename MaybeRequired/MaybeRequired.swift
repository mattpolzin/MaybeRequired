//
//  MaybeRequired.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 7/8/17.
//

import Foundation

/// A `Required<T>` value is either `.some(T)` or `.none(.bad)`
public typealias Required<T> = MaybeRequired<BadIntegrity, T>

/// A `NotRequired<T>` value is either `.some(T)` or `.none(.good)`
public typealias NotRequired<T> = MaybeRequired<GoodIntegrity, T>

/// A `MaybeRequired` value is one of:
/// - `.some(T)`
/// - `.none(Integrity)`
///
/// The builtin integrities are `BadIntegrity` and `GoodIntegrity` which get you
/// `.none(.bad)` and `.none(.good)`, respectively.
///
/// If you `flatMap` from one `MaybeRequired<BadIntegrity, _>` to another,
/// your result will be a `MaybeRequired<BadIntegrity, _>`.
///
/// If you `flatMap` from one `MaybeRequired<GoodIntegrity, _>` to another your
/// result will be a `MaybeRequired<GoodIntegrity, _>`.
///
/// However, if you `flatMap` from a `BadIntegrity` to a `GoodIntegrity` or
/// vice versa then your result will be a `MaybeRequired<MaybeOK, _>`.
public enum MaybeRequired<NoneType: Integrity, SomeType> {
	case none(NoneType)
	case some(SomeType)
}

public extension MaybeRequired where NoneType: StrictIntegrity {
	
	/// Create a `MaybeRequired` value with the specified integrity.
	///
	/// If your `Optional` is `.some` then the `MaybeRequired` will be as well.
	///
	/// If your `Optional` is `.none` then a `MaybeRequired<BadIntegrity, _>` will
	/// be `.none(.bad)` and a `MaybeRequired<GoodIntegrity, _>` will be
	/// `.none(.good)`
	public init(_ value: SomeType?) {
		guard let trueValue = value else {
			self = .none(NoneType())
			return
		}
		
		self = .some(trueValue)
	}
}

public extension MaybeRequired {
	
	/// Map to another `MaybeRequired` of the same integrity.
	public func flatMap<SomeOtherType>(_ f: (SomeType) -> MaybeRequired<NoneType, SomeOtherType>) -> MaybeRequired<NoneType, SomeOtherType> {
		switch self {
		case .none(let integrity):
			return .none(integrity)
			
		case .some(let value):
			return f(value)
		}
	}
	
	/// Map to another `MaybeRequired` of different integrity.
	public func flatMap<U, SomeOtherType>(_ f: (SomeType) -> MaybeRequired<U, SomeOtherType>) -> MaybeRequired<MaybeOK, SomeOtherType> {
		switch self {
		case .none(let maybeRequired):
			return .none(maybeRequired.integrity)
			
		case .some(let value):
			switch f(value) {
			case .none(let maybeRequired):
				return .none(maybeRequired.integrity)
				
			case .some(let value):
				return .some(value)
			}
		}
	}
}

extension MaybeRequired where SomeType: Equatable {
	public static func ==(lhs: MaybeRequired, rhs: MaybeRequired) -> Bool {
		switch lhs {
		case .none(let leftValue):
			guard case .none(let rightValue) = rhs else { return false }
			
			return leftValue == rightValue
			
		case .some(let leftValue):
			guard case .some(let rightValue) = rhs else { return false }
			
			return leftValue == rightValue
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
