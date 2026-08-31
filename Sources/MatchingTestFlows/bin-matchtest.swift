import TestFlows

@main
enum MatchingFlowMain {
    static func main() async {
        await TestFlowCLI.run(
            suite: MatchingFlowSuite.self
        )
    }
}
