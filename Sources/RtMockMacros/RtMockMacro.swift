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

enum TrivialToken {
    case rightParen
    case leftParen
    case colon
    case comma

    var kind: TokenKind {
        switch self {
        case .rightParen:
            TokenKind.rightParen
        case .leftParen:
            TokenKind.leftParen
        case .colon:
            TokenKind.colon
        case .comma:
            TokenKind.comma
        }
    }

    var token: TokenSyntax {
        TokenSyntax(self.kind, leadingTrivia: [], trailingTrivia: [], presence: .present)
    }
}

public struct RtMockMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw RtMockError.onlyApplicableToProtocol
        }
        
        var result = ClassDeclSyntax(
            name: .identifier("RtMock\(protocolDecl.name)"),
            inheritanceClause: SwiftSyntax.InheritanceClauseSyntax(
                inheritedTypes: [
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("\(protocolDecl.name)")))
                ]
            ),
            memberBlockBuilder: {}
        )

        for member in protocolDecl.memberBlock.members {
            guard let protoFunc = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }

            // Create arg list for mock call/declaration
            var callArgs = LabeledExprListSyntax()
            var declArgs = TupleTypeElementListSyntax()
            protoFunc.signature.parameterClause.parameters.forEach { param in
                let name = param.secondName ?? param.firstName
                callArgs.append(LabeledExprSyntax(expression: ExprSyntax("\(name)"), trailingComma: param.trailingComma))
                declArgs.append(TupleTypeElementSyntax(type: param.type, trailingComma: param.trailingComma))
            }

            // Define mock call inside func body
            var classFunc = protoFunc
            classFunc.body = CodeBlockSyntax {
                let tryKeyword = (protoFunc.signature.effectSpecifiers?.throwsSpecifier == nil) ? "" : "try "
                FunctionCallExprSyntax(calledExpression: ExprSyntax("\(raw: tryKeyword)mocked_\(protoFunc.name)!"),
                                       leftParen: TrivialToken.leftParen.token,
                                       arguments: callArgs,
                                       rightParen: TrivialToken.rightParen.token
                )
            }

            result.memberBlock.members.append(try MemberBlockItemSyntax(validating: MemberBlockItemSyntax(decl: classFunc)))

            // Create arg list for mock declaration

            
            let closureType = FunctionTypeSyntax(leadingTrivia: "(",
                                                 parameters: declArgs,
                                                 effectSpecifiers: TypeEffectSpecifiersSyntax(throwsSpecifier: protoFunc.signature.effectSpecifiers?.throwsSpecifier),
                                                 returnClause: protoFunc.signature.returnClause ?? ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "Void")),
                                                 trailingTrivia: ")")
            let optionalClosure = OptionalTypeSyntax(wrappedType: closureType)
            let varDecl = VariableDeclSyntax(.var, name: "mocked_\(protoFunc.name)", type: TypeAnnotationSyntax(type: optionalClosure))
            let varMember = MemberBlockItemSyntax(decl: varDecl)
            result.memberBlock.members.append(try MemberBlockItemSyntax(validating: varMember))
        }

        return [DeclSyntax(result)]
    }
}

@main
struct RtMockPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RtMockMacro.self,
    ]
}
