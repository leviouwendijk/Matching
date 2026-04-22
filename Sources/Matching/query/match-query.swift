import Tokens

public struct MatchQuery: Sendable, Codable, Hashable {
    public let raw: String
    public let normalized: String
    public let tokens: [TextToken]
    public let options: TokenNormalizationOptions

    public init(
        _ raw: String,
        options: TokenNormalizationOptions = .defaults
    ) {
        self.raw = raw
        self.options = options
        self.normalized = TokenNormalizer.normalize(
            raw,
            options: options
        )
        self.tokens = QueryTokenizer.tokenize(
            raw,
            normalization: options
        )
    }

    public var isEmpty: Bool {
        normalized.isEmpty
    }
}
