//
//  Integrity.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 7/8/17.
//

import Foundation

public protocol Integrity: Equatable {
	var integrity: MaybeOK { get }
}

/// Strict Integrities can be initialized with no arguments to a default value.
///
/// The intention is for this to be reasonable only because they have one, and
/// only one, possible value.
public protocol StrictIntegrity: Integrity {
	init()
}

public enum GoodIntegrity: StrictIntegrity {
	case good
	
	public var integrity: MaybeOK { return .good }
	
	public init() {
		self = .good
	}
}

public enum BadIntegrity: StrictIntegrity {
	case bad
	
	public var integrity: MaybeOK { return .bad }
	
	public init() {
		self = .bad
	}
}

public enum MaybeOK: Integrity {
	case good
	case bad
	
	public var integrity: MaybeOK { return self }
}

extension GoodIntegrity: CustomStringConvertible {
	public var description: String {
		return ".good"
	}
}

extension BadIntegrity: CustomStringConvertible {
	public var description: String {
		return ".bad"
	}
}

extension MaybeOK: CustomStringConvertible {
	public var description: String {
		switch self {
		case .good:
			return "MaybeOK.good"
			
		case .bad:
			return "MaybeOK.bad"
		}
	}
}
