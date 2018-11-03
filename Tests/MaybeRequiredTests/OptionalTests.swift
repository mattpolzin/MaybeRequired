//
//  OptionalTests.swift
//  MaybeRequiredTests
//
//  Created by Mathew Polzin on 12/2/17.
//

import XCTest
import MaybeRequired

class OptionalTests: XCTestCase {
    
	let string: String? = "hello"
	let noString: String? = nil
	
	let string2: String? = "world"
	let map = ["hello": "HELLO"]
	
	func test_isMissing() {
		XCTAssertFalse(Optional<String>.none.isMissing)
		XCTAssertFalse(string.isMissing)
	}
	
	func test_missingType() {
		XCTAssertTrue(Optional<Int>.some(2).missingType is Void.Type)
		
		XCTAssertTrue(Optional<Int>.none.missingType is Void.Type)
	}
	
	func test_value() {
		XCTAssertNil(Optional<String>.none.value)
		
		XCTAssertEqual(string.value, string)
	}
	
	func test_maybeRequired() {
		let maybeRequired1 = string.maybeRequired
		guard case .some(let str) = maybeRequired1,
			str == string! else {
				XCTFail("MaybeRequired from Optional.some failed")
				return
		}
		
		let maybeRequired2 = noString.maybeRequired
		guard case .none = maybeRequired2 else {
			XCTFail("MaybeRequired from Optional.none failed")
			return
		}
	}
	
	func test_require() {
		let requiredString1 = string.require { map[$0] }
		guard case .some(let str) = requiredString1 else {
			XCTFail("Optional.some requiring Optional.some failed")
			return
		}
		XCTAssertEqual(str, map[string!]!)
		
		let requiredString2 = string2.require { map[$0] }
		guard case .missing = requiredString2 else {
			XCTFail("Optional.some requiring Optional.none failed")
			return
		}
	}
	
	func test_suppose() {
		let optionalString1 = string.suppose { map[$0] }
		guard case .some(let str) = optionalString1 else {
			XCTFail("Optional.some supposing Optional.some failed")
			return
		}
		XCTAssertEqual(str, map[string!]!)
		
		let optionalString2 = string2.suppose { map[$0] }
		guard case .none = optionalString2 else {
			XCTFail("Optional.some supposing Optional.none failed")
			return
		}
	}
	
	func test_maybeRequiredEquality() {
		XCTAssertFalse(Optional<Int>.some(2) == MaybeRequired<Int>.some(1))
		XCTAssertFalse(Optional<Int>.some(2) == MaybeRequired<Int>.missing)
		XCTAssertFalse(Optional<Int>.none == MaybeRequired<Int>.missing)
		
		XCTAssertTrue(Optional<Int>.some(1) == MaybeRequired<Int>.some(1))
		XCTAssertTrue(Optional<Int>.none == MaybeRequired<Int>.none)
	}
}
