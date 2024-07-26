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
    private static func createNameFromType(_ type: String) -> String {
        var result: String = type.replacingOccurrences(of: "->", with: "")
            .replacingOccurrences(of: "?", with: "Optional")
            .trimmingCharacters(in: .whitespaces)
        if result.contains("<") {
            result = result.replacingOccurrences(of: "<", with: "Of_")
                .replacingOccurrences(of: ">", with: "_")
        } else if result.contains("[") {
            result = result.replacingOccurrences(of: "[", with: "ArrayOf_")
                .replacingOccurrences(of: "]", with: "_")
        }
        if result.last == "_" {
            result.removeLast()
        }
        return result
    }

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
                var mockedVarName = "mocked_\(protoFunc.name)"
                let returnType = createNameFromType("\(protoFunc.signature.returnClause ?? ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "Void")))")

                // Create arg list for mock call/declaration
                var callArgs = LabeledExprListSyntax()
                var mockedCallArgs = LabeledExprListSyntax()
                var declArgs = TupleTypeElementListSyntax()
                protoFunc.signature.parameterClause.parameters.forEach { param in
                    let label: TokenSyntax?
                    let expression: ExprSyntax

                    let type = createNameFromType("\(param.type)")
                    if let secondName = param.secondName {
                        let name = "\(secondName)"
                        mockedVarName += "_\(param.firstName.trimmed)\(name.capitalized)\(type)"
                        label = "\(param.firstName)"
                        expression = ExprSyntax("\(secondName)")
                    } else {
                        mockedVarName += "_\(param.firstName)\(type)"
                        label = nil
                        expression = ExprSyntax("\(param.firstName)")
                    }
                    mockedCallArgs.append(LabeledExprSyntax(expression: expression, trailingComma: param.trailingComma))
                    callArgs.append(LabeledExprSyntax(label: label,
                                                      expression: expression,
                                                      trailingComma: param.trailingComma))
                    declArgs.append(TupleTypeElementSyntax(type: param.type, trailingComma: param.trailingComma))
                }
                let asyncKeyword = (protoFunc.signature.effectSpecifiers?.asyncSpecifier == nil) ? "" : "async_"
                mockedVarName += "_\(asyncKeyword)\(returnType)"

                // Define mock call inside func body
                var classFunc = protoFunc
                classFunc.body = CodeBlockSyntax {
                    let tryKeyword = (protoFunc.signature.effectSpecifiers?.throwsSpecifier == nil) ? "" : "try "
                    let asyncKeyword = (protoFunc.signature.effectSpecifiers?.asyncSpecifier == nil) ? "" : "await "
                    // swiftlint:disable:next one_space_after_closing_brace
                    FunctionCallExprSyntax(calledExpression: ExprSyntax("\(raw: tryKeyword)\(raw: asyncKeyword)\(raw: mockedVarName)!"),
                                           leftParen: TrivialToken.leftParen.token,
                                           arguments: mockedCallArgs,
                                           rightParen: TrivialToken.rightParen.token
                    )
                }

                result.memberBlock.members.append(try MemberBlockItemSyntax(validating: MemberBlockItemSyntax(decl: classFunc)))

                // Create arg list for mock declaration
                let effectSpecifiers = TypeEffectSpecifiersSyntax(asyncSpecifier: protoFunc.signature.effectSpecifiers?.asyncSpecifier,
                                                                  throwsSpecifier: protoFunc.signature.effectSpecifiers?.throwsSpecifier)
                let returnClause = protoFunc.signature.returnClause ?? ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "Void"))
                let closureType = FunctionTypeSyntax(leadingTrivia: "(",
                                                     parameters: declArgs,
                                                     effectSpecifiers: effectSpecifiers,
                                                     returnClause: returnClause,
                                                     trailingTrivia: ")")
                let optionalClosure = OptionalTypeSyntax(wrappedType: closureType)
                let varDecl = VariableDeclSyntax(.var, name: " \(raw: mockedVarName)", type: TypeAnnotationSyntax(type: optionalClosure))
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
                    // swiftlint:disable:next no_more_than_one_consecutive_space
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
