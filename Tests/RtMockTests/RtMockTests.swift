import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(RtMockMacros)
import RtMockMacros

let testMacros: [String: Macro.Type] = [
    "RtMock": RtMockMacro.self,
]
#endif

final class RtMockTests: XCTestCase {
    func testMacro() throws {
        #if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A{}
            """,
            expandedSource: """
            protocol A{}
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
            struct A{}
            """,
            expandedSource: """
            struct A{}
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
