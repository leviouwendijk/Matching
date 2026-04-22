import Position

public struct MatchResolvedLineSpan: Sendable, Hashable {
    public let fieldName: String
    public let matchRange: MatchRange
    public let lineRange: LineRange

    public init(
        fieldName: String,
        matchRange: MatchRange,
        lineRange: LineRange
    ) {
        self.fieldName = fieldName
        self.matchRange = matchRange
        self.lineRange = lineRange
    }
}

public enum MatchPositionResolver {
    public static func lineSpans(
        for fieldResult: MatchedFieldResult,
        in text: String
    ) -> [MatchResolvedLineSpan] {
        lineSpans(
            for: fieldResult.spans,
            in: text
        )
    }

    public static func lineSpans(
        for spans: [MatchSpan],
        in text: String
    ) -> [MatchResolvedLineSpan] {
        let lineTable = LineTable(text: text)

        return spans.map { span in
            let start = lineTable.lineAndColumn(
                at: span.range.startOffset
            )

            let inclusiveEndOffset = span.range.isEmpty
                ? span.range.startOffset
                : max(
                    span.range.startOffset,
                    span.range.endOffset - 1
                )

            let end = lineTable.lineAndColumn(
                at: inclusiveEndOffset
            )

            return MatchResolvedLineSpan(
                fieldName: span.fieldName,
                matchRange: span.range,
                lineRange: LineRange(
                    uncheckedStart: start.line,
                    uncheckedEnd: end.line
                )
            )
        }
    }
}
