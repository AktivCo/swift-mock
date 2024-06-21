// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that adds mock which conforms to given protocol.

@attached(peer)
public macro RtMock() = #externalMacro(module: "RtMockMacros", type: "RtMockMacro")
