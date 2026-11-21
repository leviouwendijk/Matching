/// A value that offers its parts for matching: lines of an output, records
/// of a listing, entries of a library. Each candidate's `matchID` addresses
/// it within the source, so a hit can be resolved back to the part it came
/// from. The conformer decides what its candidates are and which fields they
/// carry; matching and ranking stay with the engine.
public protocol CandidateSource: Sendable {
    associatedtype Candidate: MatchCandidate

    func candidates() -> [Candidate]
}

/// Candidates already at hand.
extension Array: CandidateSource where Element: MatchCandidate {
    public func candidates() -> [Element] {
        self
    }
}

/// A candidate seen through one of its fields only, for a probe scoped to
/// that field. Without the field it has nothing to match.
public struct FieldScopedCandidate<Base: MatchCandidate>: MatchCandidate {
    public let base: Base
    public let field: String

    public init(
        _ base: Base,
        field: String
    ) {
        self.base = base
        self.field = field
    }

    public var matchID: Base.MatchID {
        base.matchID
    }

    public var primaryField: MatchField {
        base.allFields.first { $0.name == field }
            ?? MatchField(name: field, text: "", role: .primary)
    }

    public var secondaryFields: [MatchField] {
        []
    }

    public var metadata: MatchCandidateMetadata {
        base.metadata
    }
}
