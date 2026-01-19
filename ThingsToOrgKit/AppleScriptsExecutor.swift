import AppKit
import Carbon

public actor AppleScriptsExecutor {
    private static let shared: AppleScriptsExecutor = .init()
    private(set) var scripts: [(AppleScript, CheckedContinuation<String, any Error>)] = []
    private var isExecuting = false

    private init() {}

    public static func execute(_ script: AppleScript) async throws -> String {
        try await shared.execute(script)
    }

    private func execute(_ script: AppleScript) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            scripts.append((script, continuation))
            runPendingScriptsIfNeeded()
        }
    }

    private func runPendingScriptsIfNeeded() {
        guard !isExecuting else { return }
        isExecuting = true
        defer { isExecuting = false }

        while !scripts.isEmpty {
            let (script, continuation) = scripts.removeFirst()
            do {
                let appleScript = NSAppleScript(source: script.script)
                var error: NSDictionary? = nil

                let output = appleScript?.executeAndReturnError(&error)
                if let error = error {
                    throw AppleScript.Error(payload: error.description)
                }
                func string(from desc: NSAppleEventDescriptor) -> String {
                    // Try coercing anything to Unicode text first
                    if let coerced = desc.coerce(toDescriptorType: typeUnicodeText),
                       let s = coerced.stringValue {
                        return s
                    }
                    // Handle lists by converting each item
                    if desc.descriptorType == typeAEList {
                        var parts: [String] = []
                        let count = desc.numberOfItems
                        if count > 0 {
                            for i in 1...count {
                                if let item = desc.atIndex(i) {
                                    parts.append(string(from: item))
                                }
                            }
                        }
                        return parts.joined(separator: "\n")
                    }
                    // For records, fall back to description (stringValue is usually nil)
                    if desc.descriptorType == typeAERecord {
                        return desc.description
                    }
                    // Default fallback
                    return desc.stringValue ?? desc.description
                }

                let result: String = {
                    guard let output else { return "" }
                    return string(from: output)
                }()
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
