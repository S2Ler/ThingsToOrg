public func areas() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set outputs to {}
            repeat with currentArea in areas
                set end of outputs to (properties of currentArea)
            end repeat
            return outputs
        end tell
        """)
}
