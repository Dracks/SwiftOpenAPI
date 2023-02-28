import Foundation

/// Defines a security scheme that can be used by the operations.
///
/// Supported schemas are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), mutual TLS (use of a client certificate), OAuth2's common flows (implicit, password, client credentials and authorization code) as defined in RFC6749, and OpenID Connect Discovery. Please note that as of 2020, the implicit flow is about to be deprecated by OAuth 2.0 Security Best Current Practice. Recommended for most use case is Authorization Code Grant flow with PKCE.
public struct SecuritySchemeObject: Codable, Equatable, SpecificationExtendable {
    
    /// The type of the security scheme.
    public var type: SecuritySchemeObjectType
    
    /// A description for security scheme. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    /// The name of the header, query or cookie parameter to be used.
    public var name: String?
    
    ///  The location of the API key
    public var `in`: In?
    
    /// The name of the HTTP Authorization scheme to be used in the Authorization header as defined in RFC7235. The values used SHOULD be registered in the IANA Authentication Scheme registry.
    public var scheme: HTTPAuthScheme?
    
    /// A hint to the client to identify how the bearer token is formatted. Bearer tokens are usually generated by an authorization server, so this information is primarily for documentation purposes.
    public var bearerFormat: String?
    
    /// An object containing configuration information for the flow types supported.
    public var flows: OAuthFlowsObject?
    
    /// OpenId Connect URL to discover OAuth2 configuration values. The OpenID Connect standard requires the use of TLS.
    public var openIdConnectUrl: URL?
    
    public init(
        type: SecuritySchemeObjectType,
        description: String? = nil,
        name: String? = nil,
        `in`: SecuritySchemeObject.In? = nil,
        scheme: HTTPAuthScheme? = nil,
        bearerFormat: String? = nil,
        flows: OAuthFlowsObject? = nil,
        openIdConnectUrl: URL? = nil
    ) {
        self.type = type
        self.description = description
        self.name = name
        self.`in` = `in`
        self.scheme = scheme
        self.bearerFormat = bearerFormat
        self.flows = flows
        self.openIdConnectUrl = openIdConnectUrl
    }
}

extension SecuritySchemeObject {
    
    public enum In: String, Codable {
        
        case query, header, cookie
    }
}

public enum SecuritySchemeObjectType: String, Codable {
    
    case apiKey, http, mutualTLS, oauth2, openIdConnect
}

public struct HTTPAuthScheme: LosslessStringConvertible, ExpressibleByStringLiteral, RawRepresentable, Hashable, Codable {
    
    public var rawValue: String
    public var description: String { rawValue }
    
    public init(_ string: String) {
        self.rawValue = string.lowercased()
    }
    
    public init(rawValue: String) {
        self.init(rawValue)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
    
    public static let basic: HTTPAuthScheme = "basic"
    public static let bearer: HTTPAuthScheme = "bearer"
    public static let digest: HTTPAuthScheme = "digest"
    
    /// The HOBA scheme can be used with either HTTP servers or proxies. When used in response to a 407 Proxy Authentication Required indication, the appropriate proxy authentication header fields are used instead, as with any other HTTP authentication scheme.
    public static let hoba: HTTPAuthScheme = "hoba"
    public static let mutual: HTTPAuthScheme = "mutual"
    public static let oauth: HTTPAuthScheme = "oauth"
    public static let scramSHA1: HTTPAuthScheme = "scram-sha-1"
    public static let scramSHA256: HTTPAuthScheme = "scram-sha-256"
    public static let vapid: HTTPAuthScheme = "vapid"
}

public extension SecuritySchemeObject {
    
    static var basic: SecuritySchemeObject {
        SecuritySchemeObject(type: .http, scheme: .basic)
    }
    
    static func apiKey(name: String = "api_key") -> SecuritySchemeObject {
        SecuritySchemeObject(type: .apiKey, name: name, in: .header)
    }
    
    static var bearerJWT: SecuritySchemeObject {
        SecuritySchemeObject(type: .http, scheme: .bearer, bearerFormat: "JWT")
    }
    
    static func oauth(
        authorizationUrl: URL,
        tokenUrl: URL? = nil,
        scopes: [String: String]? = nil
    ) -> SecuritySchemeObject {
        SecuritySchemeObject(
            type: .oauth2,
            flows: OAuthFlowsObject(
            		implicit: OAuthFlowObject(
                		authorizationUrl: authorizationUrl,
                    tokenUrl: tokenUrl,
                    scopes: scopes
                )
            )
        )
    }
}
