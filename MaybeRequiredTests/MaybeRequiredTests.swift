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
	let noString: String? = nil
	
	let string2: String? = "world"
	let map = ["hello": "HELLO"]
	
	func test_nonRequiredString() {
		
		let intentionalString1 = NotRequired(string)
		XCTAssert(intentionalString1 == MaybeRequired<GoodIntegrity, String>.some(string!))
		
		let intentionalString2 = NotRequired(noString)
		XCTAssert(intentionalString2 == MaybeRequired<GoodIntegrity, String>.none(.good))
	}
	
	func test_requiredString() {
		
		let intentionalString3 = Required(string)
		XCTAssert(intentionalString3 == MaybeRequired<BadIntegrity, String>.some(string!))
		
		let intentionalString4 = Required(noString)
		XCTAssert(intentionalString4 == MaybeRequired<BadIntegrity, String>.none(.bad))
	}
	
	func test_requiredKeyToRequiredValue() {
		
		let intentionalMapping1 = Required(string).flatMap { Required(map[$0]) }
		XCTAssert(intentionalMapping1 == MaybeRequired<BadIntegrity, String>.some(map[string!]!))
		
		let intentionalMapping2 = Required(noString).flatMap { Required(map[$0]) }
		XCTAssert(intentionalMapping2 == MaybeRequired<BadIntegrity, String>.none(.bad))
		
		let intentionalMapping3 = Required(string2).flatMap { Required(map[$0]) }
		XCTAssert(intentionalMapping3 == MaybeRequired<BadIntegrity, String>.none(.bad))
	}
	
	func test_optionalKeyToOptionalValue() {
	
		let intentionalMapping4 = NotRequired(string).flatMap { NotRequired(map[$0]) }
		XCTAssert(intentionalMapping4 == MaybeRequired<GoodIntegrity, String>.some(map[string!]!))
		
		let intentionalMapping5 = NotRequired(noString).flatMap { NotRequired(map[$0]) }
		XCTAssert(intentionalMapping5 == MaybeRequired<GoodIntegrity, String>.none(.good))
		
		let intentionalMapping6 = NotRequired(string2).flatMap { NotRequired(map[$0]) }
		XCTAssert(intentionalMapping6 == MaybeRequired<GoodIntegrity, String>.none(.good))
	}
	
	func test_requiredKeyToOptionalValue() {
	
		let intentionalMapping7 = Required(string).flatMap { NotRequired(map[$0]) }
		XCTAssert(intentionalMapping7 == MaybeRequired<MaybeOK, String>.some(map[string!]!))
		
		let intentionalMapping8 = Required(noString).flatMap { NotRequired(map[$0]) }
		XCTAssert(intentionalMapping8 == MaybeRequired<MaybeOK, String>.none(.bad))
		
		let intentionalMapping9 = Required(string2).flatMap { NotRequired(map[$0]) }
		XCTAssert(intentionalMapping9 == MaybeRequired<MaybeOK, String>.none(.good))
	}
	
	func test_optionalKeyToRequiredValue() {
	
		let intentionalMapping10 = NotRequired(string).flatMap { Required(map[$0]) }
		XCTAssert(intentionalMapping10 == MaybeRequired<MaybeOK, String>.some(map[string!]!))
		
		let intentionalMapping11 = NotRequired(noString).flatMap { Required(map[$0]) }
		XCTAssert(intentionalMapping11 == MaybeRequired<MaybeOK, String>.none(.good))
		
		let intentionalMapping12 = NotRequired(string2).flatMap { Required(map[$0]) }
		XCTAssert(intentionalMapping12 == MaybeRequired<MaybeOK, String>.none(.bad))
	}
}
