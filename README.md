[Russian/Русский](README_RUS.md) 

## Description
RtMock is a library for generating mocks for writing unit tests.

## Requirements
This library requires swift-tools 5.9 and newer.

## Installation
**Swift Package Manager**

Navigate to the SPM section in your project, add a new package, point it to
this repository and choose necessary version.

## Usage
To use this library first import it
```bash
import RtMock
```

For generating mock class add annotation @RtMock to a protocol declaration
```bash
@RtMock
protocol Foo {
    func f()
    var a: Int { get }
}
```

This will generate a class RtMockFoo that implements protocol.
To mock some function call or some property use a corresponding generated field from mock class.
```bash
let mockedFoo = RtMockFoo()
mockedFoo.mocked_f_Void = { }
mockedFoo.mocked_a = 0
```

## Features
RtMock supports generating
- functions with optional and generic parameters and return types
- optional properties
- overloaded functions

If function/property with no provided mock value was called during a test, 
that will trigger error during force unwrap.