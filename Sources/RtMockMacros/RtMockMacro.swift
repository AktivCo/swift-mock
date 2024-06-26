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
        
        var n = StructDeclSyntax(
            name: .identifier("RtMock\(protocolDecl.name)"),
            inheritanceClause: SwiftSyntax.InheritanceClauseSyntax(
                inheritedTypes: [
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("\(protocolDecl.name)")))
                ]
            ),
            memberBlockBuilder: {}
        )
        for member in protocolDecl.memberBlock.members {
            guard let foo = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }

            let funcDecl = DeclSyntax(stringLiteral: "\(member) { mocked_\(foo.name)()}")
            let funcMember = MemberBlockItemSyntax(decl: funcDecl)
            n.memberBlock.members.append(try MemberBlockItemSyntax(validating: funcMember))

            let varDecl = DeclSyntax(stringLiteral: "var mocked_\(foo.name): () -> Void = {}")
            let varMember = MemberBlockItemSyntax(decl: varDecl)
            n.memberBlock.members.append(try MemberBlockItemSyntax(validating: varMember))
        }

        return [DeclSyntax(n)]
    }
}

@main
struct RtMockPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RtMockMacro.self,
    ]
}
