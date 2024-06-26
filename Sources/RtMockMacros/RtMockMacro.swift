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
        guard let _ = declaration.as(ProtocolDeclSyntax.self) else {
            throw RtMockError.onlyApplicableToProtocol
        }

        return []
    }
}

@main
struct RtMockPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RtMockMacro.self,
    ]
}
