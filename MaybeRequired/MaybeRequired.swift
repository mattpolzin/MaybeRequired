//
//  Necessity.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 7/8/17.
//

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
	///
	/// If your `Optional` is `.none` then a `MaybeRequired<Necessary, _>` will
	/// be `.none(.necessary)` and a `MaybeRequired<Unnecessary, _>` will be
	/// `.none(.unnecessary)`
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

// NOTE: With Swift 4, the following will be allowed:
//extension MaybeRequired: Equatable where SomeType: Equatable {

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
