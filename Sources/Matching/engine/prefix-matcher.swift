public struct PrefixMatcher<Candidate: MatchCandidate>: Matcher {
    public let strategy: MatchStrategy = .prefix

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
            guard let range = MatchComparison.prefixRange(
                query.normalized,
                in: field.text,
                case: query.options.case
            ) else {
                continue
            }

            let score = MatchScore(
                value: 800 * field.weight,
                components: [
                    .init(
                        name: "prefix",
                        value: 800
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
                    spans: [
                        MatchSpan(
                            fieldName: field.name,
                            range: range
                        )
                    ]
                )
            )
        }

        return MatchResultBuilder.build(
            candidateID: candidate.matchID,
            fieldResults: fieldResults
        )
    }
}
