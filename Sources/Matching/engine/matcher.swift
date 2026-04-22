public enum MatchStrategy: String, Sendable, Codable, Hashable, CaseIterable {
    case exact
    case prefix
    case contains
    case subsequence
}

public protocol Matcher: Sendable {
    associatedtype Candidate: MatchCandidate

    var strategy: MatchStrategy { get }

    func match(
        query: MatchQuery,
        against candidate: Candidate
    ) -> MatchResult<Candidate.MatchID>
}

public extension Matcher {
    func matches(
        query: MatchQuery,
        against candidate: Candidate
    ) -> Bool {
        match(
            query: query,
            against: candidate
        ).didMatch
    }

    func match<S: Sequence>(
        query: MatchQuery,
        against candidates: S
    ) -> [MatchResult<Candidate.MatchID>]
    where S.Element == Candidate {
        candidates.compactMap { candidate in
            let result = match(
                query: query,
                against: candidate
            )

            return result.didMatch ? result : nil
        }
    }
}

enum MatchResultBuilder {
    static func build<ID: Hashable & Sendable>(
        candidateID: ID,
        fieldResults: [MatchedFieldResult],
        diagnostics: [MatchDiagnostic] = []
    ) -> MatchResult<ID> {
        guard !fieldResults.isEmpty else {
            return .noMatch(
                candidateID: candidateID,
                diagnostics: diagnostics
            )
        }

        let total = fieldResults.reduce(into: 0) { partial, fieldResult in
            partial += fieldResult.score.value
        }

        let components = fieldResults.flatMap(\.score.components)

        return MatchResult(
            candidateID: candidateID,
            didMatch: true,
            score: .init(
                value: total,
                components: components
            ),
            fieldResults: fieldResults,
            diagnostics: diagnostics
        )
    }
}
