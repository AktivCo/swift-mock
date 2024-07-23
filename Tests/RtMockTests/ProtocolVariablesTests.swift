//
//  ProtocolVariablesTests.swift
//
//
//  Created by Vova Badyaev on 22.07.2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest


final class ProtocolVariablesTests: XCTestCase {
    func testMacroVariable() throws {
#if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                var someVar: Int { get }
            }
            """,
            expandedSource: """
            protocol A {
                var someVar: Int { get }
            }

            class RtMockA: A {
                var someVar: Int {
                    return mocked_someVar!
                }
                var mocked_someVar: Int?
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testMacroVariableWithGenericParameters() throws {
#if canImport(RtMockMacros)
        assertMacroExpansion(
            """
            @RtMock
            protocol A {
                var someVar: Int<X, Y> { get }
            }
            """,
            expandedSource: """
            protocol A {
                var someVar: Int<X, Y> { get }
            }

            class RtMockA: A {
                var someVar: Int<X, Y> {
                    return mocked_someVar!
                }
                var mocked_someVar: Int<X, Y>?
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
