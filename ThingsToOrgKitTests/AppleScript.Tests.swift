import Testing
@testable import ThingsToOrgKit

@Suite("AppleScript callAsFunction basic suite")
struct AppleScriptCallTests {
    @Test("Runs a simple AppleScript and returns its string result")
    func testSimpleScriptReturnsString() async throws {
        // This script should return the string "Hello"
        let script = "return \"Hello\""
        let appleScript = AppleScript(script: script)
        let result = try await appleScript()
        #expect(result == "Hello")
    }
        
    @Test("Returns nil for script that does not yield string result")
    func testNonStringResult() async throws {
        // AppleScript returns an integer
        let script = "return 444"
        let appleScript = AppleScript(script: script)
        let result = try await appleScript()
        #expect(result == "444")
    }
}
