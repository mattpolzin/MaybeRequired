//
//  RequiredTests.swift
//  MaybeRequiredTests
//
//  Created by Mathew Polzin on 12/2/17.
//

import XCTest
import MaybeRequired

class RequiredTests: XCTestCase {
    
	let string: String? = "hello"
	let noString: String? = nil
	
	let string2: String? = "world"
	let map = ["hello": "HELLO"]
	
	func test_requiredConstruction() {
		
		let requiredString1 = Required(fromOptional: string)
		guard case .some(let str) = requiredString1,
			str == string! else {
				XCTFail("Required construction with Optional.some failed")
				return
		}
		
		let requiredString2 = Required(fromOptional: noString)
		guard case .missing = requiredString2 else {
			XCTFail("Required construction with Optional.none failed")
			return
		}
		
		let requiredString3 = Required(string!)
		guard case .some(let str2) = requiredString3,
			str2 == string! else {
				XCTFail("Required construction with non-optional failed")
				return
		}
	}
	
	func test_isMissing() {
		XCTAssertTrue(Required<String>.missing.isMissing)
		
		XCTAssertFalse(Required(fromOptional: string).isMissing)
	}
	
	func test_value() {
		XCTAssertNil(Required<String>.missing.value)
		
		XCTAssertEqual(Required(fromOptional: string).value, string)
	}
	
	func test_maybeRequired() {
		let maybeRequired1 = Required(fromOptional: string).maybeRequired
		guard case .some(let str) = maybeRequired1,
			str == string! else {
				XCTFail("MaybeRequired from Required with Optional.some failed")
				return
		}
		
		let maybeRequired2 = Required(fromOptional: noString).maybeRequired
		guard case .missing = maybeRequired2 else {
				XCTFail("MaybeRequired from Required with Optional.none failed")
				return
		}
	}
	
	func test_map() {
		let requiredNumber = Required(string!).map { $0.count }
		guard case .some(let number) = requiredNumber else {
			XCTFail("Required.some did not map to Required.some")
			return
		}
		XCTAssertTrue(type(of: number) == type(of: string!.count))
		XCTAssertTrue(type(of: requiredNumber) == Required<String.IndexDistance>.self)
		
		let requiredNumber2 = Required(fromOptional: noString).map { $0.count }
		guard case .missing = requiredNumber2 else {
			XCTFail("Required.missing did not map to Required.missing")
			return
		}
		XCTAssertTrue(type(of: requiredNumber2) == Required<String.IndexDistance>.self)
	}
	
	func test_flatMap() {
		let requiredNumber = Required(string!).flatMap { Required($0.count) }
		guard case .some(let number) = requiredNumber else {
			XCTFail("Required.some did not flatMap to Required.some")
			return
		}
		XCTAssertTrue(type(of: number) == type(of: string!.count))
		XCTAssertTrue(type(of: requiredNumber) == Required<String.IndexDistance>.self)
		
		let requiredNumber2 = Required(fromOptional: noString).flatMap { Required($0.count) }
		guard case .missing = requiredNumber2 else {
			XCTFail("Required.missing did not flatMap to Required.missing")
			return
		}
		XCTAssertTrue(type(of: requiredNumber2) == Required<String.IndexDistance>.self)
	}
	
	func test_require() {
		let requiredString1 = Required(fromOptional: string).require { map[$0] }
		guard case .some(let str) = requiredString1 else {
			XCTFail("Required.some requiring Optional.some failed")
			return
		}
		XCTAssertEqual(str, map[string!]!)
		
		let requiredString2 = Required(fromOptional: string2).require { map[$0] }
		guard case .missing = requiredString2 else {
			XCTFail("Required.some requiring Optional.none failed")
			return
		}
	}
	
	func test_suppose() {
		let optionalString1 = Required(fromOptional: string).suppose { map[$0] }
		guard case .some(let str) = optionalString1 else {
			XCTFail("Required.some supposing Optional.some failed")
			return
		}
		XCTAssertEqual(str, map[string!]!)
		
		let optionalString2 = Required(fromOptional: string2).suppose { map[$0] }
		guard case .none = optionalString2 else {
			XCTFail("Required.some supposing Optional.none failed")
			return
		}
	}
	
	func test_equality() {
		
		XCTAssertFalse(Required<Int>.some(1) == Required<Int>.some(2))
		XCTAssertFalse(Required<Int>.missing == Required<Int>.some(2))
		
		XCTAssertTrue(Required<Int>.some(1) == Required<Int>.some(1))
		XCTAssertTrue(Required<Int>.missing == Required<Int>.missing)
	}
	
	func test_optionalEquality() {
		XCTAssertFalse(Required<Int>.some(1) == Optional<Int>.some(2))
		XCTAssertFalse(Required<Int>.missing == Optional<Int>.some(2))
		XCTAssertFalse(Required<Int>.missing == Optional<Int>.none)
		XCTAssertFalse(Required<Int>.missing == nil)
		
		XCTAssertTrue(Required<Int>.some(1) == Optional<Int>.some(1))
	}
	
	func test_maybeRequiredEquality() {
		XCTAssertFalse(Required<Int>.some(1) == MaybeRequired<Int>.some(2))
		XCTAssertFalse(Required<Int>.missing == MaybeRequired<Int>.some(2))
		XCTAssertFalse(Required<Int>.missing == MaybeRequired<Int>.none)
		
		XCTAssertTrue(Required<Int>.some(1) == MaybeRequired<Int>.some(1))
		XCTAssertTrue(Required<Int>.missing == MaybeRequired<Int>.missing)
	}
}
