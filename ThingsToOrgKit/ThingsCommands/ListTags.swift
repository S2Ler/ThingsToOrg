public func listTags() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            repeat with t in tags
                set output to output & name of t & linefeed
            end repeat
            return output
        end tell
        """)
}
