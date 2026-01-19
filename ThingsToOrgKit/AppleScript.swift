import Foundation
import Cocoa

public struct AppleScript: Hashable, Sendable {
    public struct Error: Swift.Error {
        public let payload: String // TODO: Make meaningful
    }

    let script: String

    public init(script: String) {
        self.script = script
    }

    /**
     Executes the AppleScript contained in this struct and returns the result as a String, if available.
     - Returns: The output of the AppleScript as a String, or nil if execution fails or the result is not a string.
     - Note: If an error occurs during execution, it will be printed to the console and nil is returned.
     */
    public func callAsFunction() async throws -> String {
        try await AppleScriptsExecutor.execute(self)
    }
}
