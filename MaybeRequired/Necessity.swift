//
//  Necessity.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 7/8/17.
//

import Foundation

public protocol Necessity: Equatable {
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

public enum Necessary: StrictNecessity {
	case necessary
	
	public var necessity: MaybeNecessary { return .necessary }
	
	public init() {
		self = .necessary
	}
}

public enum MaybeNecessary: Necessity {
	case unnecessary
	case necessary
	
	public var necessity: MaybeNecessary { return self }
}

extension Unnecessary: CustomStringConvertible {
	public var description: String {
		return ".unnecessary"
	}
}

extension Necessary: CustomStringConvertible {
	public var description: String {
		return ".necessary"
	}
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
