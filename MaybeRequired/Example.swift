//
//  Example.swift
//  MaybeRequired
//
//  Created by Mathew Polzin on 7/8/17.
//

import Foundation

// The following is intended to show a simplified example of real usage.

// Imagine having a datastore of objects that have been (or will be) retrieved
// via API calls to the server.
// There are two really common scenarios that come up:
// 1) A required object has been requested and the server has not returned
//		the object yet.
// 2) An object contains an optional key to look up another object in the
//		datastore.

// Now imagine you have an object `a` with an optional reference to an
// object `b` and you want to tell a view in your app to display object `b`. You
// want your view to be able to show the user one of:
// - "loading"
// - "error"
// - "value not set"
// - or information about `b`

// You cannot just tell your view controller that `b` does or does not exist. 
// It needs more information in order to choose between so many view states.

// MaybeRequired will package relavent information about the existence and
// necessity of objects together. The only piece of the above puzzle not directly
// addressed here is whether there is currently a network call waiting to retrieve
// `b` from the server.

struct Object {
	// If this object is associated with another object, this value is a non-nil key by
	// which the other object can be looked up in the datastore.
	let otherObjectPointer: String?
}

enum LoadingState {
	case loading
	case done
	case error
}

struct Example {
	var datastore: [String: Object]
	var rootObject: Object
	var viewController: ViewController
	
	func dataLoaded() {
		
		// This is where the magic happens. We declare that `rootObject` is not
		// required to have an `otherObjectPointer`, but if it does then we
		// declare that the `datastore` is required to contain the other object.
		let maybeObject = NotRequired(rootObject.otherObjectPointer).flatMap { otherObjectKey in
			Required(datastore[otherObjectKey])
		}
		
		// we will just hard code the loading state for the sake of having one
		// in this example:
		let loadingState: LoadingState = .done
		
		viewController.displayObject(maybeObject, loadingState: loadingState)
	}
}

class ViewController {
	func displayObject<T>(_ maybeObject: MaybeRequired<MaybeOK, T>, loadingState: LoadingState) {
		
		switch (maybeObject, loadingState) {
		case (.some(let value), _):
			print("Here is your information: \(value)")
			
		case (.none(.good), _):
			print("value not set")
			
		case (.none(.bad), .loading):
			print("loading")
			
		case (.none(.bad), .error), (.none(.bad), .done):
			print("error")
		}
	}
}
