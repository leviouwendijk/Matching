public struct MatchRange: Sendable, Codable, Hashable, CustomStringConvertible {
    public let startOffset: Int
    public let endOffset: Int

    public init(
        startOffset: Int,
        endOffset: Int
    ) {
        precondition(startOffset >= 0, "MatchRange.startOffset must be >= 0")
        precondition(endOffset >= startOffset, "MatchRange.endOffset must be >= startOffset")

        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    public init(
        uncheckedStart startOffset: Int,
        uncheckedEnd endOffset: Int
    ) {
        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    public var isEmpty: Bool {
        startOffset == endOffset
    }

    public var offsetRange: Range<Int> {
        startOffset..<endOffset
    }

    public var description: String {
        "\(startOffset)..<\(endOffset)"
    }
}

public struct MatchSpan: Sendable, Codable, Hashable {
    public let fieldName: String
    public let range: MatchRange

    public init(
        fieldName: String,
        range: MatchRange
    ) {
        self.fieldName = fieldName
        self.range = range
    }

    public var isEmpty: Bool {
        range.isEmpty
    }
}

public struct MatchScoreComponent: Sendable, Codable, Hashable {
    public let name: String
    public let value: Int
    public let detail: String?

    public init(
        name: String,
        value: Int,
        detail: String? = nil
    ) {
        self.name = name
        self.value = value
        self.detail = detail
    }
}

public struct MatchScore: Sendable, Codable, Hashable {
    public let value: Int
    public let components: [MatchScoreComponent]

    public init(
        value: Int,
        components: [MatchScoreComponent] = []
    ) {
        self.value = value
        self.components = components
    }

    public static let zero: Self = .init(
        value: 0,
        components: []
    )
}

public enum MatchDiagnosticSeverity: String, Sendable, Codable, Hashable, CaseIterable {
    case info
    case warning
    case error
}

public struct MatchDiagnostic: Sendable, Codable, Hashable {
    public let severity: MatchDiagnosticSeverity
    public let message: String

    public init(
        severity: MatchDiagnosticSeverity,
        message: String
    ) {
        self.severity = severity
        self.message = message
    }
}

public struct MatchedFieldResult: Sendable, Codable, Hashable {
    public let field: MatchField
    public let score: MatchScore
    public let spans: [MatchSpan]
    public let diagnostics: [MatchDiagnostic]

    public init(
        field: MatchField,
        score: MatchScore,
        spans: [MatchSpan],
        diagnostics: [MatchDiagnostic] = []
    ) {
        self.field = field
        self.score = score
        self.spans = spans
        self.diagnostics = diagnostics
    }

    public var didMatch: Bool {
        !spans.isEmpty
    }
}

public struct MatchResult<ID: Hashable & Sendable>: Sendable, Hashable {
    public let candidateID: ID
    public let didMatch: Bool
    public let score: MatchScore
    public let fieldResults: [MatchedFieldResult]
    public let diagnostics: [MatchDiagnostic]

    public init(
        candidateID: ID,
        didMatch: Bool,
        score: MatchScore,
        fieldResults: [MatchedFieldResult],
        diagnostics: [MatchDiagnostic] = []
    ) {
        self.candidateID = candidateID
        self.didMatch = didMatch
        self.score = score
        self.fieldResults = fieldResults
        self.diagnostics = diagnostics
    }

    public var matchedFields: [MatchedFieldResult] {
        fieldResults.filter(\.didMatch)
    }

    public var matchedSpans: [MatchSpan] {
        matchedFields.flatMap(\.spans)
    }

    public static func noMatch(
        candidateID: ID,
        diagnostics: [MatchDiagnostic] = []
    ) -> Self {
        .init(
            candidateID: candidateID,
            didMatch: false,
            score: .zero,
            fieldResults: [],
            diagnostics: diagnostics
        )
    }
}
