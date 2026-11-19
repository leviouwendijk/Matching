import Matching
import Testing
import Tokens

enum RegexMatchingTestSuite {
    static var testSuite: TestSuite {
        TestSuite(
            "matching-regex",
            title: "Regex matching tests"
        ) {
            Test("regex finds every match with character offsets") {
                let result = match("ba[rz]", in: "bar baz bat")
                try Expect.equal(
                    result.matchedSpans.map(\.range.startOffset),
                    [0, 4],
                    "matching.regex.starts"
                )
                try Expect.equal(
                    result.matchedSpans.map(\.range.endOffset),
                    [3, 7],
                    "matching.regex.ends"
                )
            }

            Test("regex anchors match at line ends") {
                let result = match("^let", in: "var a\nlet b\n  let c")
                try Expect.equal(
                    result.matchedSpans.map(\.range.startOffset),
                    [6],
                    "matching.regex.line-anchor"
                )
            }

            Test("regex follows the query's case options") {
                try Expect.equal(
                    match("foo", in: "FOO", sensitivity: .insensitive).didMatch,
                    true,
                    "matching.regex.insensitive"
                )
                try Expect.equal(
                    match("foo", in: "FOO", sensitivity: .sensitive).didMatch,
                    false,
                    "matching.regex.sensitive"
                )
                try Expect.equal(
                    match("(?-i)foo", in: "FOO", sensitivity: .insensitive).didMatch,
                    false,
                    "matching.regex.inline-flag"
                )
            }

            Test("escaped text matches literally; invalid patterns are reported") {
                try Expect.equal(
                    match(RegexPattern.escaped("a.b(c)"), in: "axb(c) a.b(c)").matchedSpans.map(\.range.startOffset),
                    [7],
                    "matching.regex.escaped"
                )
                try Expect.equal(RegexPattern.isValid("a("), false, "matching.regex.invalid")
                try Expect.equal(RegexPattern.isValid("a\\("), true, "matching.regex.valid")
            }

            Test("ranges report the whole match or a capture group") {
                let text = "user=sam KEY_A=x1 key_b=yz"
                try Expect.equal(
                    RegexPattern.ranges("[a-z_]+=([a-z0-9]+)", in: text).map(\.offsetRange),
                    [0..<8, 9..<17, 18..<26],
                    "matching.regex.ranges.whole"
                )
                try Expect.equal(
                    RegexPattern.ranges("[a-z_]+=(?<value>[a-z0-9]+)", in: text, group: .named("value")).map(\.offsetRange),
                    [5..<8, 15..<17, 24..<26],
                    "matching.regex.ranges.named"
                )
                try Expect.equal(
                    RegexPattern.ranges("[a-z_]+=([a-z0-9]+)", in: text, group: .index(1)).map(\.offsetRange),
                    [5..<8, 15..<17, 24..<26],
                    "matching.regex.ranges.index"
                )
                try Expect.equal(
                    RegexPattern.ranges("(a)|(b)", in: "ab", group: .index(2)).map(\.offsetRange),
                    [1..<2],
                    "matching.regex.ranges.unmatched-group-left-out"
                )
                try Expect.equal(
                    RegexPattern.ranges("(a)", in: "a", group: .index(4)),
                    [],
                    "matching.regex.ranges.missing-group"
                )
                try Expect.equal(
                    RegexPattern.ranges("é(?<n>\\d)", in: "café é7").map(\.offsetRange),
                    [5..<7],
                    "matching.regex.ranges.character-offsets"
                )
            }
        }
    }

    private static func match(
        _ pattern: String,
        in text: String,
        sensitivity: TokenCaseSensitivity = .sensitive
    ) -> MatchResult<Int> {
        RegexMatcher<BasicMatchCandidate<Int>>().match(
            query: MatchQuery(
                pattern,
                options: TokenNormalizationOptions(
                    case: TokenCaseOptions(sensitivity: sensitivity)
                )
            ),
            against: BasicMatchCandidate(
                matchID: 0,
                primaryField: MatchField(name: "text", text: text)
            )
        )
    }
}
