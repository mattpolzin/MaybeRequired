//
//  MaybeRequiredTests.swift
//  MaybeRequiredTests
//
//  Created by Mathew Polzin on 7/8/17.
//

import XCTest
import MaybeRequired

class MaybeRequiredTests: XCTestCase {
	
	let string: String? = "hello"
	lazy var maybeRequiredString: MaybeRequired<String> = .some(string!)
	let noString: String? = nil
	
	let string2: String? = "world"
	lazy var maybeRequiredString2: MaybeRequired<String> = .some(string2!)
	let map = ["hello": "HELLO"]
	
	func test_isMissing() {
		XCTAssertTrue(MaybeRequired<String>.missing.isMissing)
		
		XCTAssertFalse(MaybeRequired<String>.none.isMissing)
		XCTAssertFalse(maybeRequiredString.isMissing)
	}
	
	func test_missingType() {
		XCTAssertTrue(MaybeRequired<Int>.some(2).missingType is Void.Type)
		XCTAssertTrue(MaybeRequired<Int>.none.missingType is Void.Type)
		
		XCTAssertTrue(MaybeRequired<Int>.missing.missingType is Int.Type)
	}
	
	func test_value() {
		XCTAssertNil(MaybeRequired<String>.none.value)
		XCTAssertNil(MaybeRequired<String>.missing.value)
		
		XCTAssertEqual(maybeRequiredString.value, string)
	}
	
	func test_maybeRequired() {
		let maybeRequired1 = maybeRequiredString.maybeRequired
		guard case .some(let str) = maybeRequired1,
			str == string! else {
				XCTFail("MaybeRequired from MaybeRequired with Optional.some failed")
				return
		}
		
		let maybeRequired2 = MaybeRequired<String>.missing.maybeRequired
		guard case .missing = maybeRequired2 else {
			XCTFail("MaybeRequired from MaybeRequired.missing failed")
			return
		}
		
		let maybeRequired3 = MaybeRequired<String>.none.maybeRequired
		guard case .none = maybeRequired3 else {
			XCTFail("MaybeRequired from MaybeRequired.none failed")
			return
		}
	}
	
	func test_map() {
		let requiredNumber = maybeRequiredString.map { $0.count }
		guard case .some(let number) = requiredNumber else {
			XCTFail("MaybeRequired.some did not map to MaybeRequired.some")
			return
		}
		XCTAssertTrue(type(of: number) == type(of: string!.count))
		XCTAssertTrue(type(of: requiredNumber) == MaybeRequired<String.IndexDistance>.self)
		
		let requiredNumber2 = MaybeRequired<String>.missing.map { $0.count }
		guard case .missing = requiredNumber2 else {
			XCTFail("MaybeRequired.missing did not map to MaybeRequired.missing")
			return
		}
		XCTAssertTrue(type(of: requiredNumber2) == MaybeRequired<String.IndexDistance>.self)
		
		let requiredNumber3 = MaybeRequired<String>.none.map { $0.count }
		guard case .none = requiredNumber3 else {
			XCTFail("MaybeRequired.none did not map to MaybeRequired.none")
			return
		}
		XCTAssertTrue(type(of: requiredNumber3) == MaybeRequired<String.IndexDistance>.self)
	}
	
	func test_flatMap() {
		let requiredNumber = maybeRequiredString.flatMap { .some($0.count) }
		guard case .some(let number) = requiredNumber else {
			XCTFail("MaybeRequired.some did not flatMap to MaybeRequired.some")
			return
		}
		XCTAssertTrue(type(of: number) == type(of: string!.count))
		XCTAssertTrue(type(of: requiredNumber) == MaybeRequired<String.IndexDistance>.self)
		
		let requiredNumber2 = MaybeRequired<String>.missing.flatMap { .some($0.count) }
		guard case .missing = requiredNumber2 else {
			XCTFail("MaybeRequired.missing did not flatMap to MaybeRequired.missing")
			return
		}
		XCTAssertTrue(type(of: requiredNumber2) == MaybeRequired<String.IndexDistance>.self)
		
		let requiredNumber3 = MaybeRequired<String>.none.flatMap { .some($0.count) }
		guard case .none = requiredNumber3 else {
			XCTFail("MaybeRequired.none did not flatMap to MaybeRequired.none")
			return
		}
		XCTAssertTrue(type(of: requiredNumber3) == MaybeRequired<String.IndexDistance>.self)
	}
	
	func test_require() {
		let requiredString1 = maybeRequiredString.require { map[$0] }
		guard case .some(let str) = requiredString1 else {
			XCTFail("MaybeRequired.some requiring Optional.some failed")
			return
		}
		XCTAssertEqual(str, map[string!]!)
		
		let requiredString2 = maybeRequiredString2.require { map[$0] }
		guard case .missing = requiredString2 else {
			XCTFail("MaybeRequired.some requiring Optional.none failed")
			return
		}
	}
	
	func test_suppose() {
		let optionalString1 = maybeRequiredString.suppose { map[$0] }
		guard case .some(let str) = optionalString1 else {
			XCTFail("MaybeRequired.some supposing Optional.some failed")
			return
		}
		XCTAssertEqual(str, map[string!]!)
		
		let optionalString2 = maybeRequiredString2.suppose { map[$0] }
		guard case .none = optionalString2 else {
			XCTFail("MaybeRequired.some supposing Optional.none failed")
			return
		}
	}
	
	func test_equality() {
		XCTAssertFalse(MaybeRequired<Int>.some(1) == MaybeRequired<Int>.some(2))
		XCTAssertFalse(MaybeRequired<Int>.missing == MaybeRequired<Int>.some(2))
		XCTAssertFalse(MaybeRequired<Int>.none == MaybeRequired<Int>.some(2))
		XCTAssertFalse(MaybeRequired<Int>.none == MaybeRequired<Int>.missing)
		
		XCTAssertTrue(MaybeRequired<Int>.some(1) == MaybeRequired<Int>.some(1))
		XCTAssertTrue(MaybeRequired<Int>.missing == MaybeRequired<Int>.missing)
		XCTAssertTrue(MaybeRequired<Int>.none == MaybeRequired<Int>.none)
	}
}
