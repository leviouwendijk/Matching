import Matching
import TestFlows
import Tokens

extension MatchingFlowSuite {
    static var directTextMatchingFlow: TestFlow {
        TestFlow(
            "matching-direct-text-ranges",
            tags: [
                "matching",
                "text",
                "position",
                "contains",
                "subsequence",
            ]
        ) {
            Step(
                "contains returns every non-overlapping occurrence using character offsets"
            ) {
                let result = TextMatcher.match(
                    "foo",
                    in: "foo-foo-foo",
                    strategy: .contains,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    result.ranges.map(\.startOffset),
                    [
                        0,
                        4,
                        8,
                    ],
                    "matching.text.contains.starts"
                )

                try Expect.equal(
                    result.ranges.map(\.endOffset),
                    [
                        3,
                        7,
                        11,
                    ],
                    "matching.text.contains.ends"
                )

                let overlap = TextMatcher.match(
                    "ana",
                    in: "banana",
                    strategy: .contains,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    overlap.ranges.map(\.offsetRange),
                    [
                        1..<4,
                    ],
                    "matching.text.contains.non-overlapping"
                )
            }

            Step(
                "case-insensitive contains preserves Unicode character offsets"
            ) {
                let result = TextMatcher.match(
                    "foo",
                    in: "🐶Foo🐾foo",
                    strategy: .contains,
                    options: insensitiveOptions
                )

                try Expect.equal(
                    result.ranges.map(\.startOffset),
                    [
                        1,
                        5,
                    ],
                    "matching.text.unicode.starts"
                )

                try Expect.equal(
                    result.ranges.map(\.endOffset),
                    [
                        4,
                        8,
                    ],
                    "matching.text.unicode.ends"
                )
            }

            Step(
                "subsequence exposes fragmented ordered evidence and groups adjacent characters"
            ) {
                let fragmented = TextMatcher.match(
                    "sfn",
                    in: "some_file_name",
                    strategy: .subsequence,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    fragmented.ranges.map(\.offsetRange),
                    [
                        0..<1,
                        5..<6,
                        10..<11,
                    ],
                    "matching.text.subsequence.fragmented"
                )

                let contiguous = TextMatcher.match(
                    "file",
                    in: "some_file_name",
                    strategy: .subsequence,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    contiguous.ranges.map(\.offsetRange),
                    [
                        5..<9,
                    ],
                    "matching.text.subsequence.grouped"
                )
            }

            Step(
                "exact and prefix retain their distinct positional semantics"
            ) {
                let exact = TextMatcher.match(
                    "alpha",
                    in: "alpha",
                    strategy: .exact,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    exact.ranges.map(\.offsetRange),
                    [
                        0..<5,
                    ],
                    "matching.text.exact.range"
                )

                let exactPartial = TextMatcher.match(
                    "alpha",
                    in: "alphabet",
                    strategy: .exact,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    exactPartial.didMatch,
                    false,
                    "matching.text.exact.partial-rejected"
                )

                let prefix = TextMatcher.match(
                    "alpha",
                    in: "alphabet",
                    strategy: .prefix,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    prefix.ranges.map(\.offsetRange),
                    [
                        0..<5,
                    ],
                    "matching.text.prefix.range"
                )
            }

            Step(
                "identifier matching accepts bounded occurrences and rejects embedded components"
            ) {
                let result = TextMatcher.match(
                    "foo",
                    in: "foo foo_bar foo-bar",
                    strategy: .identifier,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    result.ranges.map(\.offsetRange),
                    [
                        0..<3,
                        12..<15,
                    ],
                    "matching.text.identifier.ranges"
                )
            }

            Step(
                "multi-query matching retains source query order and independent ranges"
            ) {
                let results = TextMatcher.match(
                    [
                        "draft",
                        "copy",
                        "missing",
                    ],
                    in: "draft-final-copy",
                    strategy: .contains,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    results.map { $0.query.raw },
                    [
                        "draft",
                        "copy",
                        "missing",
                    ],
                    "matching.text.multi-query.order"
                )

                try Expect.equal(
                    results.map { $0.ranges.map(\.offsetRange) },
                    [
                        [0..<5],
                        [12..<16],
                        [],
                    ],
                    "matching.text.multi-query.ranges"
                )
            }

            Step(
                "empty queries remain explicit no-match results"
            ) {
                let result = TextMatcher.match(
                    "",
                    in: "anything",
                    strategy: .contains,
                    options: sensitiveOptions
                )

                try Expect.equal(
                    result.didMatch,
                    false,
                    "matching.text.empty.no-match"
                )

                try Expect.equal(
                    result.ranges.isEmpty,
                    true,
                    "matching.text.empty.no-ranges"
                )
            }
        }
    }

    private static var sensitiveOptions: TokenNormalizationOptions {
        TokenNormalizationOptions(
            case: TokenCaseOptions(
                sensitivity: .sensitive
            )
        )
    }

    private static var insensitiveOptions: TokenNormalizationOptions {
        TokenNormalizationOptions(
            case: TokenCaseOptions(
                sensitivity: .insensitive
            )
        )
    }
}
