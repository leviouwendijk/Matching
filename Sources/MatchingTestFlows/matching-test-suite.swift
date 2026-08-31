import TestFlows

enum MatchingFlowSuite: TestFlowRegistry {
    static let title = "Matching flow tests"

    static let flows: [TestFlow] = [
        directTextMatchingFlow,
    ]
}
