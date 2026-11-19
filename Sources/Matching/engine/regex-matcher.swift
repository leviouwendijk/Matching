import Foundation
import Tokens

public struct RegexMatcher<Candidate: MatchCandidate>: Matcher {
    public let strategy: MatchStrategy = .regex

    public init() {}

    /// Matches the query's raw text as a pattern: normalizing it would
    /// change its meaning.
    public func match(
        query: MatchQuery,
        against candidate: Candidate
    ) -> MatchResult<Candidate.MatchID> {
        guard !query.raw.isEmpty else {
            return .noMatch(candidateID: candidate.matchID)
        }

        var fieldResults: [MatchedFieldResult] = []

        for field in candidate.allFields where !field.isEmpty {
            let ranges = MatchComparison.regexRanges(
                query.raw,
                in: field.text,
                case: query.options.case
            )

            guard !ranges.isEmpty else {
                continue
            }

            let score = MatchScore(
                value: 600 * field.weight,
                components: [
                    .init(
                        name: "regex",
                        value: 600
                    ),
                    .init(
                        name: "fieldWeight",
                        value: field.weight,
                        detail: field.name
                    ),
                ]
            )

            fieldResults.append(
                MatchedFieldResult(
                    field: field,
                    score: score,
                    spans: ranges.map {
                        MatchSpan(
                            fieldName: field.name,
                            range: $0
                        )
                    }
                )
            )
        }

        return MatchResultBuilder.build(
            candidateID: candidate.matchID,
            fieldResults: fieldResults
        )
    }
}

public enum RegexPattern {
    /// Whether `pattern` compiles as a regular expression.
    public static func isValid(
        _ pattern: String
    ) -> Bool {
        MatchComparison.regularExpression(pattern, case: .init()) != nil
    }

    /// The non-empty ranges `pattern` matches in `text`, in character
    /// offsets; empty when it does not compile. `^` and `$` match at line
    /// ends.
    public static func ranges(
        _ pattern: String,
        in text: String,
        case: TokenCaseOptions = .defaults
    ) -> [MatchRange] {
        MatchComparison.regexRanges(pattern, in: text, case: `case`)
    }

    /// `text` as a pattern that matches it literally.
    public static func escaped(
        _ text: String
    ) -> String {
        NSRegularExpression.escapedPattern(for: text)
    }
}
