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
            name: .identifier("RtMock\(protocolDecl.name.trimmed)"),
            inheritanceClause: SwiftSyntax.InheritanceClauseSyntax(
                inheritedTypes: [
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("\(protocolDecl.name.trimmed)")))
                ]
            ),
            memberBlockBuilder: {}
        )

        for member in protocolDecl.memberBlock.members {
            if let protoFunc = member.decl.as(FunctionDeclSyntax.self) {
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
                    // swiftlint:disable:next one_space_after_closing_brace
                    FunctionCallExprSyntax(calledExpression: ExprSyntax("\(raw: tryKeyword)mocked_\(protoFunc.name)!"),
                                           leftParen: TrivialToken.leftParen.token,
                                           arguments: callArgs,
                                           rightParen: TrivialToken.rightParen.token
                    )
                }

                result.memberBlock.members.append(try MemberBlockItemSyntax(validating: MemberBlockItemSyntax(decl: classFunc)))

                // Create arg list for mock declaration
                let effectSpecifiers = TypeEffectSpecifiersSyntax(throwsSpecifier: protoFunc.signature.effectSpecifiers?.throwsSpecifier)
                let returnClause = protoFunc.signature.returnClause ?? ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "Void"))
                let closureType = FunctionTypeSyntax(leadingTrivia: "(",
                                                     parameters: declArgs,
                                                     effectSpecifiers: effectSpecifiers,
                                                     returnClause: returnClause,
                                                     trailingTrivia: ")")
                let optionalClosure = OptionalTypeSyntax(wrappedType: closureType)
                let varDecl = VariableDeclSyntax(.var, name: "mocked_\(protoFunc.name)", type: TypeAnnotationSyntax(type: optionalClosure))
                let varMember = MemberBlockItemSyntax(decl: varDecl)
                result.memberBlock.members.append(try MemberBlockItemSyntax(validating: varMember))
            } else if let protoVariable = member.decl.as(VariableDeclSyntax.self) {
                guard let binding = protoVariable.bindings.first,
                      let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                      let type = binding.typeAnnotation?.type.trimmed
                else {
                    continue
                }

                let mockedVarName: PatternSyntax = "mocked_\(identifier)"
                let computedProperty = try VariableDeclSyntax("var \(identifier): \(type)") {
                  StmtSyntax("    return \(mockedVarName)! ")
                }
                result.memberBlock.members.append(try MemberBlockItemSyntax(validating: MemberBlockItemSyntax(decl: computedProperty)))

                let varDecl = VariableDeclSyntax(.var,
                                                 name: mockedVarName,
                                                 type: TypeAnnotationSyntax(type: OptionalTypeSyntax(wrappedType: type)))
                let varMember = MemberBlockItemSyntax(decl: varDecl)
                result.memberBlock.members.append(try MemberBlockItemSyntax(validating: varMember))
            } else {
                continue
            }
        }

        return [DeclSyntax(result)]
    }
}

@main
struct RtMockPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RtMockMacro.self
    ]
}
