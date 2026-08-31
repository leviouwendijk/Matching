public struct IdentifierMatcher<Candidate: MatchCandidate>: Matcher {
    public let strategy: MatchStrategy = .identifier

    public init() {}

    public func match(
        query: MatchQuery,
        against candidate: Candidate
    ) -> MatchResult<Candidate.MatchID> {
        guard !query.isEmpty else {
            return .noMatch(candidateID: candidate.matchID)
        }

        var fieldResults: [MatchedFieldResult] = []

        for field in candidate.allFields where !field.isEmpty {
            let ranges = MatchComparison.identifierRanges(
                query.normalized,
                in: field.text,
                case: query.options.case
            )

            guard !ranges.isEmpty else {
                continue
            }

            let score = MatchScore(
                value: 700 * field.weight,
                components: [
                    .init(
                        name: "identifier",
                        value: 700
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
