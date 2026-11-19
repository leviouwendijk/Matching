import Foundation
import Tokens

/// A match of a compiled expression: character offsets and the matched text.
public struct RegexMatch: Sendable, Hashable {
    public let range: MatchRange
    public let text: String

    public init(range: MatchRange, text: String) {
        self.range = range
        self.text = text
    }
}

/// A regular expression (ICU) compiled once, for matching many texts.
/// Matches become character offsets in one forward walk over the text, so
/// the cost grows with the text, not with text × matches.
///
/// NSRegularExpression is immutable and safe to share between threads.
public struct CompiledRegex: @unchecked Sendable {
    public let pattern: String
    private let expression: NSRegularExpression

    /// Nil when `pattern` does not compile. `^` and `$` match at line ends.
    public init?(
        _ pattern: String,
        case: TokenCaseOptions = .defaults
    ) {
        guard let expression = MatchComparison.regularExpression(pattern, case: `case`) else {
            return nil
        }
        self.pattern = pattern
        self.expression = expression
    }

    /// The non-empty matches in `text`, in order; `group` reports a capture
    /// group instead of the whole match, leaving out matches whose group did
    /// not take part.
    public func matches(
        in text: String,
        group: RegexGroup = .whole
    ) -> [RegexMatch] {
        let whole = NSRange(text.startIndex..<text.endIndex, in: text)
        var results: [RegexMatch] = []
        // The walk's position: `index` is `offset` characters into the text.
        var index = text.startIndex
        var offset = 0
        for match in expression.matches(in: text, range: whole) {
            let selected: NSRange
            switch group {
            case .whole:
                selected = match.range
            case .index(let number):
                guard number < match.numberOfRanges else { continue }
                selected = match.range(at: number)
            case .named(let name):
                selected = match.range(withName: name)
            }
            // An unmatched optional group has location NSNotFound.
            guard selected.location != NSNotFound,
                  selected.length > 0,
                  let range = Range(selected, in: text)
            else {
                continue
            }
            // A group inside a lookbehind can lie before the walk; count it
            // from the start rather than walking backwards.
            let start = range.lowerBound >= index
                ? offset + text.distance(from: index, to: range.lowerBound)
                : text.distance(from: text.startIndex, to: range.lowerBound)
            let length = text.distance(from: range.lowerBound, to: range.upperBound)
            index = range.upperBound
            offset = start + length
            results.append(
                RegexMatch(
                    range: MatchRange(uncheckedStart: start, uncheckedEnd: start + length),
                    text: String(text[range])
                )
            )
        }
        return results
    }

    /// The ranges of `matches(in:group:)`.
    public func ranges(
        in text: String,
        group: RegexGroup = .whole
    ) -> [MatchRange] {
        matches(in: text, group: group).map(\.range)
    }
}
