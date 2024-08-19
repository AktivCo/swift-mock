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
                    mocked_foo_Void!()
                }
                var mocked_foo_Void: (() -> Void)?
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
                    try mocked_foo_Void!()
                }
                var mocked_foo_Void: (() throws -> Void)?
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
                    mocked_foo_String!()
                }
                var mocked_foo_String: (() -> String)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithNoArgumentsWithReturnOptionalValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
                """
                @RtMock
                protocol A {
                    func foo() -> String?
                }
                """,
                expandedSource: """
                protocol A {
                    func foo() -> String?
                }

                class RtMockA: A {
                    func foo() -> String? {
                        mocked_foo_StringOptional!()
                    }
                    var mocked_foo_StringOptional: (() -> String?)?
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
                    mocked_foo_aString_Void!(a)
                }
                var mocked_foo_aString_Void: ((String) -> Void)?
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
                    mocked_foo_aStringOptional_Void!(a)
                }
                var mocked_foo_aStringOptional_Void: ((String?) -> Void)?
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
                    mocked_foo_aBString_Void!(b)
                }
                var mocked_foo_aBString_Void: ((String) -> Void)?
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
                    mocked_foo_aString_bInt_Void!(a, b)
                }
                var mocked_foo_aString_bInt_Void: ((String, Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithArrayArgument() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: [String]?)
                func foo(a: [String?])
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: [String]?)
                func foo(a: [String?])
            }

            class RtMockA: A {
                func foo(a: [String]?) {
                    mocked_foo_aArrayOf_String_Optional_Void!(a)
                }
                var mocked_foo_aArrayOf_String_Optional_Void: (([String]?) -> Void)?
                func foo(a: [String?]) {
                    mocked_foo_aArrayOf_StringOptional_Void!(a)
                }
                var mocked_foo_aArrayOf_StringOptional_Void: (([String?]) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroMethodWithGenericTypesWithReturnOptionalValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: WrappedPointer<OpaquePointer??>) -> Void
                func foo(a: WrappedPointer<OpaquePointer?>?) -> T<A, B>
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: WrappedPointer<OpaquePointer??>) -> Void
                func foo(a: WrappedPointer<OpaquePointer?>?) -> T<A, B>
            }

            class RtMockA: A {
                func foo(a: WrappedPointer<OpaquePointer??>) -> Void {
                    mocked_foo_aWrappedPointerOf_OpaquePointerOptionalOptional_Void!(a)
                }
                var mocked_foo_aWrappedPointerOf_OpaquePointerOptionalOptional_Void: ((WrappedPointer<OpaquePointer??>) -> Void)?
                func foo(a: WrappedPointer<OpaquePointer?>?) -> T<A, B> {
                    mocked_foo_aWrappedPointerOf_OpaquePointerOptional_Optional_TOf_AB!(a)
                }
                var mocked_foo_aWrappedPointerOf_OpaquePointerOptional_Optional_TOf_AB: ((WrappedPointer<OpaquePointer?>?) -> T<A, B>)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethod() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: String, b: Int)
                func foo(with a: String, b: Int)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: String, b: Int)
                func foo(with a: String, b: Int)
            }

            class RtMockA: A {
                func foo(a: String, b: Int) {
                    mocked_foo_aString_bInt_Void!(a, b)
                }
                var mocked_foo_aString_bInt_Void: ((String, Int) -> Void)?
                func foo(with a: String, b: Int) {
                    mocked_foo_withAString_bInt_Void!(a, b)
                }
                var mocked_foo_withAString_bInt_Void: ((String, Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethodOptionalParams() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: SomeStrangeType, b: Int?)
                func foo(a: SomeStrangeType, b: Int)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: SomeStrangeType, b: Int?)
                func foo(a: SomeStrangeType, b: Int)
            }

            class RtMockA: A {
                func foo(a: SomeStrangeType, b: Int?) {
                    mocked_foo_aSomeStrangeType_bIntOptional_Void!(a, b)
                }
                var mocked_foo_aSomeStrangeType_bIntOptional_Void: ((SomeStrangeType, Int?) -> Void)?
                func foo(a: SomeStrangeType, b: Int) {
                    mocked_foo_aSomeStrangeType_bInt_Void!(a, b)
                }
                var mocked_foo_aSomeStrangeType_bInt_Void: ((SomeStrangeType, Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethodLabelAndParamMatch() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a b: String)
                func foo(a: String, b: Int)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a b: String)
                func foo(a: String, b: Int)
            }

            class RtMockA: A {
                func foo(a b: String) {
                    mocked_foo_aBString_Void!(b)
                }
                var mocked_foo_aBString_Void: ((String) -> Void)?
                func foo(a: String, b: Int) {
                    mocked_foo_aString_bInt_Void!(a, b)
                }
                var mocked_foo_aString_bInt_Void: ((String, Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethodAsync() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo()
                func foo() async
            }
            """,
            expandedSource: """
            protocol A {
                func foo()
                func foo() async
            }

            class RtMockA: A {
                func foo() {
                    mocked_foo_Void!()
                }
                var mocked_foo_Void: (() -> Void)?
                func foo() async {
                    await mocked_foo_async_Void!()
                }
                var mocked_foo_async_Void: (() async -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethodDifferentReturnValue() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo()
                func foo() -> Int
            }
            """,
            expandedSource: """
            protocol A {
                func foo()
                func foo() -> Int
            }

            class RtMockA: A {
                func foo() {
                    mocked_foo_Void!()
                }
                var mocked_foo_Void: (() -> Void)?
                func foo() -> Int {
                    mocked_foo_Int!()
                }
                var mocked_foo_Int: (() -> Int)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethodDifferentTypes() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo(a: String)
                func foo(a: Int)
            }
            """,
            expandedSource: """
            protocol A {
                func foo(a: String)
                func foo(a: Int)
            }

            class RtMockA: A {
                func foo(a: String) {
                    mocked_foo_aString_Void!(a)
                }
                var mocked_foo_aString_Void: ((String) -> Void)?
                func foo(a: Int) {
                    mocked_foo_aInt_Void!(a)
                }
                var mocked_foo_aInt_Void: ((Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOverloadedMethodWithGenerics() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                func foo<X, Y>(a: X, b: Y)
                func foo(with a: String, b: Int)
            }
            """,
            expandedSource: """
            protocol A {
                func foo<X, Y>(a: X, b: Y)
                func foo(with a: String, b: Int)
            }

            class RtMockA: A {
                func foo<X, Y>(a: X, b: Y) {
                    mocked_foo_aX_bY_Void!(a, b)
                }
                var mocked_foo_aX_bY_Void: ((X, Y) -> Void)?
                func foo(with a: String, b: Int) {
                    mocked_foo_withAString_bInt_Void!(a, b)
                }
                var mocked_foo_withAString_bInt_Void: ((String, Int) -> Void)?
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
