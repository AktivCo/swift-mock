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
            protocol MockFactory{}
            """,
            expandedSource: """
            protocol MockFactory{}

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo()
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo()
            }

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo() throws
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo() throws
            }

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo() -> String
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo() -> String
            }

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo(a: String)
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo(a: String)
            }

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo(a: String?)
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo(a: String?)
            }

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo(a b: String)
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo(a b: String)
            }

            class RtMockA: MockFactory {
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
            protocol MockFactory{
                func foo(a: String, b: Int)
            }
            """,
            expandedSource: """
            protocol MockFactory{
                func foo(a: String, b: Int)
            }

            class RtMockA: MockFactory {
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
            struct MockFactory{}
            """,
            expandedSource: """
            struct MockFactory{}
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
