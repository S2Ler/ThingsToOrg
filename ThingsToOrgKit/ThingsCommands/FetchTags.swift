import Foundation

public func fetchTags() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            repeat with t in tags
                set tid to id of t
                set tname to name of t
                set tparent to ""
                try
                    set tparent to id of parent tag of t
                end try
                set output to output & tid & "|||" & tname & "|||" & tparent & "~~~"
            end repeat
            return output
        end tell
        """)
}
