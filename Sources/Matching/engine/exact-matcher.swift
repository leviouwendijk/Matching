public struct ExactMatcher<Candidate: MatchCandidate>: Matcher {
    public let strategy: MatchStrategy = .exact

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
            guard MatchComparison.isEqual(
                query.normalized,
                candidate: field.text,
                case: query.options.case
            ) else {
                continue
            }

            let span = MatchSpan(
                fieldName: field.name,
                range: MatchRange(
                    uncheckedStart: 0,
                    uncheckedEnd: field.text.count
                )
            )

            let score = MatchScore(
                value: 1_000 * field.weight,
                components: [
                    .init(
                        name: "exact",
                        value: 1_000
                    ),
                    .init(
                        name: "fieldWeight",
                        value: field.weight,
                        detail: field.name
                    )
                ]
            )

            fieldResults.append(
                MatchedFieldResult(
                    field: field,
                    score: score,
                    spans: [span]
                )
            )
        }

        return MatchResultBuilder.build(
            candidateID: candidate.matchID,
            fieldResults: fieldResults
        )
    }
}
