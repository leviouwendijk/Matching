import Tokens

public enum MatchNormalizer {
    public static func normalize(
        _ raw: String,
        options: TokenNormalizationOptions = .defaults
    ) -> String {
        TokenNormalizer.normalize(
            raw,
            options: options
        )
    }

    public static func tokenize(
        _ raw: String,
        options: TokenNormalizationOptions = .defaults
    ) -> [TextToken] {
        QueryTokenizer.tokenize(
            raw,
            normalization: options
        )
    }
}
