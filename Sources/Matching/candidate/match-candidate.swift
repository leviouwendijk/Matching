public enum MatchFieldRole: String, Sendable, Codable, Hashable, CaseIterable {
    case primary
    case secondary
    case alias
    case keyword
    case title
    case subtitle
    case body
    case tag
}

public struct MatchField: Sendable, Codable, Hashable {
    public let name: String
    public let text: String
    public let role: MatchFieldRole
    public let weight: Int

    public init(
        name: String,
        text: String,
        role: MatchFieldRole = .secondary,
        weight: Int = 1
    ) {
        self.name = name
        self.text = text
        self.role = role
        self.weight = max(1, weight)
    }

    public var isEmpty: Bool {
        text.isEmpty
    }
}

public struct MatchCandidateMetadata: Sendable, Codable, Hashable {
    public var values: [String: String]

    public init(
        values: [String: String] = [:]
    ) {
        self.values = values
    }

    public var isEmpty: Bool {
        values.isEmpty
    }
}

public protocol MatchCandidate: Sendable {
    associatedtype MatchID: Hashable & Sendable

    var matchID: MatchID { get }
    var primaryField: MatchField { get }
    var secondaryFields: [MatchField] { get }
    var metadata: MatchCandidateMetadata { get }
}

public extension MatchCandidate {
    var allFields: [MatchField] {
        [primaryField] + secondaryFields
    }
}

public struct BasicMatchCandidate<ID: Hashable & Sendable>: MatchCandidate, Sendable, Hashable {
    public let matchID: ID
    public let primaryField: MatchField
    public let secondaryFields: [MatchField]
    public let metadata: MatchCandidateMetadata

    public init(
        matchID: ID,
        primaryField: MatchField,
        secondaryFields: [MatchField] = [],
        metadata: MatchCandidateMetadata = .init()
    ) {
        self.matchID = matchID
        self.primaryField = primaryField
        self.secondaryFields = secondaryFields
        self.metadata = metadata
    }
}
