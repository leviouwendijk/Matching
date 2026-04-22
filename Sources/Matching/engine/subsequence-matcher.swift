public struct SubsequenceMatcher<Candidate: MatchCandidate>: Matcher {
    public let strategy: MatchStrategy = .subsequence

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
            guard let ranges = MatchComparison.subsequenceRanges(
                query.normalized,
                in: field.text,
                case: query.options.case
            ) else {
                continue
            }

            let spanCount = ranges.count
            let characterCount = query.normalized.count
            let fragmentationPenalty: Int = max(0, spanCount - 1) * 5
            let base = 400 * field.weight
            let total = base + characterCount - fragmentationPenalty

            let spans = ranges.map {
                MatchSpan(
                    fieldName: field.name,
                    range: $0
                )
            }

            let score = MatchScore(
                value: total,
                components: [
                    .init(
                        name: "subsequence",
                        value: base
                    ),
                    .init(
                        name: "matchedCharacters",
                        value: characterCount
                    ),
                    .init(
                        name: "fragmentationPenalty",
                        value: 0 - fragmentationPenalty
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
                    spans: spans
                )
            )
        }

        return MatchResultBuilder.build(
            candidateID: candidate.matchID,
            fieldResults: fieldResults
        )
    }
}
