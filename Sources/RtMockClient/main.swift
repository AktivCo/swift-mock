import RtMock

@RtMock
protocol A {
   func foo(a: String) throws -> Void
}
