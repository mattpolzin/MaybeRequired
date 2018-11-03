# MaybeRequired
[![MIT license](http://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT) [![Swift 4.2](http://img.shields.io/badge/Swift-4.2-blue.svg)](https://swift.org) [![Build Status](https://app.bitrise.io/app/06779980531377cd/status.svg?token=W0a5g6rOZJhvt9UHzzZ4xA&branch=master)](https://app.bitrise.io/app/06779980531377cd)

## Motivation
This library introduces the `Required` type as a companion to the built-in `Optional` type. The concenpt of `Required` values is useful for encoding into a type whether values retrieved from a server API are "optional" (i.e. set or not) or "required" (i.e. necessarily set, but maybe not available to the client because of a server error, network error, user error, or client programmer error). Any piece of code operating on a `Required` value knows that the absense of the wrapped value represents an error. 

## Alternatives Compared
This is essentially a specialization of the popular `Result` type, but `MaybeRequired` makes it effortless to map between `Optional` and `Required` types without needing to represent `Optional`'s `.none` case as an `Error` type. Therefore, it is even easier to draw a parallel between `MaybeRequired` and another popular type, `Either`. 

In fact, it would have been very easy to write the `MaybeRequired` type as `Either<Required, Optional>`. This exercise was never performed so I cannot speak to whether it would have yielded elegant code or not, but it almost certainly would not have made the result easier to work with in practice.

## In Brief
Just as an `Optional` value can be `.some(value)` or `.none`, a `Required` value can be `.some(value)` or `.missing`. Note that, although `Optional.some(value)` and `Required.some(value)` can be compared to determine if the two `value`s are equal, `Optional.none` is not equal to `Required.missing`.

`Optional<Wrapped>` and `Required<Wrapped>` values can both be mapped to functions that accept their `Wrapped` type and return `Optional<NewWrapped>` using the `suppose()` and `require()` methods.

Think of `value1.suppose(value2function)` as "Given that `value1` is `.some`, suppose the result of `value2function` is `.some`." If the result of `value2function` is `.none`, no big deal, it was only a supposition.

Think of `value1.require(value2function)` as "Given that `value1` is `.some`, require the result of `value2function` to be `.some`." If the result of `value2function` is `.none`, that is a big deal because it was required.

A chain starting with an `Optional` value and containing only `suppose`s will result in an `Optional` value.

A chain starting with a `Required` value and containing only `require`s will result in a `Required` value.

Chains starting with `Optional` values and containing any `require`s or starting with `Required` values and containing any `suppose`s will result in a `MaybeRequired` value.

`MaybeRequired` values can be `.some(value)`, `.none`, or `.missing`. This type also offers comparison with `Optional` and `Required` and provides `suppose()` and `require()` methods.

## A Taste
See `MaybeRequired/Example.swift` for a slightly more contextualized but also less concise example.

Here is some anecdotal pseudocode:
```
// To state that a Person is Required
let requiredPerson: Requried<Person> = Required(person)

// To state that an Optional<Person> is Required
let requiredPerson: Required<Person> = Required(fromOptional: person)
```
```
// Given a Required<Person> (with an ID of some kind), we require that they have a name.
let name: Required<String> = person.require { names[$0.id] }

// If we do not have the required person, the value will be .missing

// If we do have the required person and the person does have a name, the value will be .some(String)

// If we do have the required person and the person does not have a required name, the value will be .missing 
```
```
// Given an Optional<Dog> (with an ID of some kind), we suppose that it has a name tag with a name on it.
let nameTag: String? = dog.suppose { dogTags[$0.id] }

// If we do not have the optional dog, the value will be .none

// If we do have the optional dog and the dog does have a name tag, the value will be .some(String)

// If we do have the optional dog and the dog does not have the optional name tag, the value will be .none
```
```
// Given a Required<Person>, we suppose that they have a dog.
let dog: MaybeRequired<Dog> = person.suppose { dogs[$0.id] }

// If we do not have the required person, the value will be .missing

// If we do have the required person and the person does have a dog, the value will be .some(Dog)

// If we do have the required person but the person does not have the optional dog, the value will be .none
```
```
// Given a Required<Person>, we suppose that they have a dog.
// Given that they have a dog, we suppose the dog has a name tag.
// Given that the dog has a name tag, we require that the name tag is registered.
let registration: MaybeRequired<Registration> = person.suppose { dogs[$0.id] }.suppose { dogTags[$0.id] }.require { reg[$0] }

// If we do not have the required person, the value will be .missing

// Otherwise, if we do not have the optional dog, the value will be .none

// Otherwise, if we do not have the optional name tag, the value will be .none

// Otherwise, if we do not have the required registration, the value will be .missing

// Otherwise, the value will be .some(Registration)
```
