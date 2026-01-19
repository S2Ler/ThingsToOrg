public func listProjects() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            repeat with p in projects
                set pname to name of p
                set pstatus to status of p as string
                set output to output & "[" & pstatus & "] " & pname & linefeed
            end repeat
            return output
        end tell
        """)
}
