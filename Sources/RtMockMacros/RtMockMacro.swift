import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public enum RtMockError: Error, CustomStringConvertible {
    case onlyApplicableToProtocol

    public var description: String {
        switch self {
        case .onlyApplicableToProtocol:
            return "@RtMock can only be applied to a protocol"
        }
    }
}

public struct RtMockMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw RtMockError.onlyApplicableToProtocol
        }

        return [DeclSyntax(
            StructDeclSyntax(
                name: .identifier("RtMock\(protocolDecl.name)"),
                inheritanceClause: SwiftSyntax.InheritanceClauseSyntax(
                    inheritedTypes: [
                        InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("\(protocolDecl.name)")))
                    ]
                ),
            memberBlock: MemberBlockSyntax(stringLiteral: "{}")
            )
        )
        ]
    }
}

@main
struct RtMockPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RtMockMacro.self,
    ]
}
