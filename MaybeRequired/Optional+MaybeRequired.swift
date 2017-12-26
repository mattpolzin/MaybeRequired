//
//  Optional+MaybeRequired.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 12/2/17.
//

import Foundation

extension Optional: Binary {
	public init(fromOptional value: Wrapped?) {
		guard let value = value else {
			self = .none
			return
		}
		
		self = .some(value)
	}
}

extension Optional: CanBeMaybeRequired {
	public var maybeRequired: MaybeRequired<Wrapped> {
		switch self {
		case .some(let value):
			return .some(value)
		case .none:
			return .none
		}
	}
}

public extension Optional {
	
	/// Given that `Self` is `.none`, the return is `MaybeRequired.none`
	///
	/// Given that `Self` is `.some(value)`, the return is `MaybeRequired.missing` or
	/// `MaybeRequired.some(fn(value))` depending on the output of `fn(value)`
	///
	/// - parameter fn: A function returning a required value or `nil`
	func require<NewWrapped>(fn: (Wrapped) -> NewWrapped?) -> MaybeRequired<NewWrapped> {
		switch self {
		case .some(let value):
			return Required(fromOptional: fn(value)).maybeRequired
		case .none:
			return .none
		}
	}
	
	/// Given that `Self` is `.none`, the return is `Optional.none`
	///
	/// Given that `Self` is `.some(value)`, the return is the output of `fn(value)`.
	///
	/// This operation is equivalent to `flatMap`.
	///
	/// - parameter fn: A function returning an optional value or `nil`
	func suppose<NewWrapped>(fn: (Wrapped) -> NewWrapped?) -> NewWrapped? {
		return flatMap(fn)
	}
}
