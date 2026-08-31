import Foundation
import Tokens

enum MatchComparison {
    static func isEqual(
        _ query: String,
        candidate: String,
        `case`: TokenCaseOptions
    ) -> Bool {
        candidate.compare(
            query,
            options: compareOptions(case: `case`)
        ) == .orderedSame
    }

    static func prefixRange(
        _ query: String,
        in candidate: String,
        `case`: TokenCaseOptions
    ) -> MatchRange? {
        guard !query.isEmpty else {
            return nil
        }

        guard let range = candidate.range(
            of: query,
            options: compareOptions(
                case: `case`,
                anchored: true
            )
        ) else {
            return nil
        }

        return offsetRange(
            from: range,
            in: candidate
        )
    }

    static func containsRanges(
        _ query: String,
        in candidate: String,
        `case`: TokenCaseOptions
    ) -> [MatchRange] {
        literalRanges(
            query,
            in: candidate,
            case: `case`
        ) { _, _ in
            true
        }
    }

    static func identifierRanges(
        _ query: String,
        in candidate: String,
        `case`: TokenCaseOptions
    ) -> [MatchRange] {
        guard !query.isEmpty,
              query.allSatisfy(isIdentifierMember)
        else {
            return []
        }

        return literalRanges(
            query,
            in: candidate,
            case: `case`
        ) { range, candidate in
            isIdentifierBounded(
                range,
                in: candidate
            )
        }
    }

    static func subsequenceRanges(
        _ query: String,
        in candidate: String,
        `case`: TokenCaseOptions
    ) -> [MatchRange]? {
        guard !query.isEmpty else {
            return nil
        }

        var matchedIndices: [String.Index] = []
        matchedIndices.reserveCapacity(query.count)

        var candidateIndex = candidate.startIndex

        for queryCharacter in query {
            var foundIndex: String.Index?

            while candidateIndex < candidate.endIndex {
                let currentIndex = candidateIndex
                let candidateCharacter = candidate[currentIndex]

                candidate.formIndex(after: &candidateIndex)

                if charactersEqual(
                    queryCharacter,
                    candidateCharacter,
                    caseSensitivity: `case`.sensitivity
                ) {
                    foundIndex = currentIndex
                    break
                }
            }

            guard let foundIndex else {
                return nil
            }

            matchedIndices.append(foundIndex)
        }

        return groupedRanges(
            from: matchedIndices,
            in: candidate
        )
    }

    private static func literalRanges(
        _ query: String,
        in candidate: String,
        `case`: TokenCaseOptions,
        accepting: (
            Range<String.Index>,
            String
        ) -> Bool
    ) -> [MatchRange] {
        guard !query.isEmpty else {
            return []
        }

        let options = compareOptions(
            case: `case`
        )
        var result: [MatchRange] = []
        var start = candidate.startIndex

        while start < candidate.endIndex,
              let range = candidate.range(
                  of: query,
                  options: options,
                  range: start..<candidate.endIndex
              )
        {
            if accepting(
                range,
                candidate
            ) {
                result.append(
                    offsetRange(
                        from: range,
                        in: candidate
                    )
                )
            }

            start = range.upperBound
        }

        return result
    }

    private static func isIdentifierBounded(
        _ range: Range<String.Index>,
        in candidate: String
    ) -> Bool {
        if range.lowerBound != candidate.startIndex {
            let previous = candidate.index(
                before: range.lowerBound
            )

            if isIdentifierMember(
                candidate[previous]
            ) {
                return false
            }
        }

        if range.upperBound != candidate.endIndex,
           isIdentifierMember(
               candidate[range.upperBound]
           )
        {
            return false
        }

        return true
    }

    private static func isIdentifierMember(
        _ character: Character
    ) -> Bool {
        if character == "_" {
            return true
        }

        return character.unicodeScalars.allSatisfy { scalar in
            CharacterSet.alphanumerics.contains(
                scalar
            )
                || CharacterSet.nonBaseCharacters.contains(
                    scalar
                )
        }
    }

    private static func compareOptions(
        case: TokenCaseOptions,
        anchored: Bool = false
    ) -> String.CompareOptions {
        var options: String.CompareOptions = []

        if anchored {
            options.insert(.anchored)
        }

        if `case`.sensitivity == .insensitive {
            options.insert(.caseInsensitive)
        }

        return options
    }

    private static func charactersEqual(
        _ lhs: Character,
        _ rhs: Character,
        caseSensitivity: TokenCaseSensitivity
    ) -> Bool {
        switch caseSensitivity {
        case .sensitive:
            return lhs == rhs

        case .insensitive:
            return String(lhs).lowercased() == String(rhs).lowercased()
        }
    }

    private static func offsetRange(
        from range: Range<String.Index>,
        in string: String
    ) -> MatchRange {
        let start = string.distance(
            from: string.startIndex,
            to: range.lowerBound
        )
        let end = string.distance(
            from: string.startIndex,
            to: range.upperBound
        )

        return MatchRange(
            uncheckedStart: start,
            uncheckedEnd: end
        )
    }

    private static func groupedRanges(
        from indices: [String.Index],
        in string: String
    ) -> [MatchRange] {
        guard let first = indices.first else {
            return []
        }

        var ranges: [Range<String.Index>] = []
        var groupStart = first
        var groupEnd = string.index(after: first)
        var previous = first

        for index in indices.dropFirst() {
            if string.index(after: previous) == index {
                groupEnd = string.index(after: index)
            } else {
                ranges.append(groupStart..<groupEnd)
                groupStart = index
                groupEnd = string.index(after: index)
            }

            previous = index
        }

        ranges.append(groupStart..<groupEnd)

        return ranges.map {
            offsetRange(
                from: $0,
                in: string
            )
        }
    }
}
