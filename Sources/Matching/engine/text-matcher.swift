import Tokens

public enum TextMatchStrategy:
    String,
    Sendable,
    Codable,
    Hashable,
    CaseIterable
{
    case exact
    case prefix
    case contains
    case identifier
    case subsequence
}

public struct TextMatchResult:
    Sendable,
    Codable,
    Hashable
{
    public let query: MatchQuery
    public let strategy: TextMatchStrategy
    public let ranges: [MatchRange]

    public init(
        query: MatchQuery,
        strategy: TextMatchStrategy,
        ranges: [MatchRange]
    ) {
        self.query = query
        self.strategy = strategy
        self.ranges = ranges
    }

    public var didMatch: Bool {
        !ranges.isEmpty
    }
}

public enum TextMatcher {
    public static func match(
        _ query: String,
        in candidate: String,
        strategy: TextMatchStrategy = .contains,
        options: TokenNormalizationOptions = .defaults
    ) -> TextMatchResult {
        match(
            MatchQuery(
                query,
                options: options
            ),
            in: candidate,
            strategy: strategy
        )
    }

    public static func match(
        _ query: MatchQuery,
        in candidate: String,
        strategy: TextMatchStrategy = .contains
    ) -> TextMatchResult {
        guard !query.isEmpty else {
            return TextMatchResult(
                query: query,
                strategy: strategy,
                ranges: []
            )
        }

        let ranges: [MatchRange]

        switch strategy {
        case .exact:
            if MatchComparison.isEqual(
                query.normalized,
                candidate: candidate,
                case: query.options.case
            ) {
                ranges = [
                    MatchRange(
                        uncheckedStart: 0,
                        uncheckedEnd: candidate.count
                    ),
                ]
            } else {
                ranges = []
            }

        case .prefix:
            if let range = MatchComparison.prefixRange(
                query.normalized,
                in: candidate,
                case: query.options.case
            ) {
                ranges = [
                    range,
                ]
            } else {
                ranges = []
            }

        case .contains:
            ranges = MatchComparison.containsRanges(
                query.normalized,
                in: candidate,
                case: query.options.case
            )

        case .identifier:
            ranges = MatchComparison.identifierRanges(
                query.normalized,
                in: candidate,
                case: query.options.case
            )

        case .subsequence:
            ranges = MatchComparison.subsequenceRanges(
                query.normalized,
                in: candidate,
                case: query.options.case
            ) ?? []
        }

        return TextMatchResult(
            query: query,
            strategy: strategy,
            ranges: ranges
        )
    }

    public static func match(
        _ queries: [String],
        in candidate: String,
        strategy: TextMatchStrategy = .contains,
        options: TokenNormalizationOptions = .defaults
    ) -> [TextMatchResult] {
        queries.map { query in
            match(
                query,
                in: candidate,
                strategy: strategy,
                options: options
            )
        }
    }

    public static func match(
        _ queries: [MatchQuery],
        in candidate: String,
        strategy: TextMatchStrategy = .contains
    ) -> [TextMatchResult] {
        queries.map { query in
            match(
                query,
                in: candidate,
                strategy: strategy
            )
        }
    }
}
