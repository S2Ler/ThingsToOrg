public func listToday() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            set todayList to to dos of list id "TMTodayListSource"
            repeat with td in todayList
                set tdname to name of td
                set tdstatus to status of td as string
                set output to output & "[" & tdstatus & "] " & tdname & linefeed
            end repeat
            return output
        end tell
        """)
}
