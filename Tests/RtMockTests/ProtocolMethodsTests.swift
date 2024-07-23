import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module
// is not available when cross-compiling. Cross-compiled tests may still
// make use of the macro itself in end-to-end tests.
#if canImport(RtMockMacros)
import RtMockMacros


let testMacros: [String: Macro.Type] = [
    "RtMock": RtMockMacro.self
]
#endif

final class ProtocolMethodsTests: XCTestCase {
    func testMacroEmptyProtocol() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {}
            """,
            expandedSource: """
            protocol A {}

            class RtMockA: A {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithNoArgumentsNoReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo()
            }
            """,
            expandedSource: """
            protocol A {
                func foo()
            }

            class RtMockA: A {
                func foo() {
                    mocked_foo!()
                }
                var mocked_foo: (() -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithNoArgumentsNoReturnValueThrows() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo() throws
            }
            """,
            expandedSource: """
            protocol A {
                func foo() throws
            }

            class RtMockA: A {
                func foo() throws {
                    try mocked_foo!()
                }
                var mocked_foo: (() throws -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithNoArgumentsWithReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo() -> String
            }
            """,
            expandedSource: """
            protocol A {
                func foo() -> String
            }

            class RtMockA: A {
                func foo() -> String {
                    mocked_foo!()
                }
                var mocked_foo: (() -> String)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithOneArgumentNoReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: String)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: String)
            }

            class RtMockA: A {
                func foo(a: String) {
                    mocked_foo!(a)
                }
                var mocked_foo: ((String) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithOneOptionalArgumentNoReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: String?)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: String?)
            }

            class RtMockA: A {
                func foo(a: String?) {
                    mocked_foo!(a)
                }
                var mocked_foo: ((String?) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithOneNamedArgumentNoReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a b: String)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a b: String)
            }

            class RtMockA: A {
                func foo(a b: String) {
                    mocked_foo!(b)
                }
                var mocked_foo: ((String) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithTwoArgumentsNoReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: String, b: Int)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: String, b: Int)
            }

            class RtMockA: A {
                func foo(a: String, b: Int) {
                    mocked_foo!(a, b)
                }
                var mocked_foo: ((String, Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOnStruct() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            struct A {}
            """,
            expandedSource: """
            struct A {}
            """,
            diagnostics: [
                DiagnosticSpec(message: RtMockError.onlyApplicableToProtocol.description, line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
