import Foundation

public func fetchAreas() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            repeat with a in areas
                set aid to id of a
                set aname to name of a
                set anotes to ""
                try
                    set anotes to notes of a
                end try
                set atags to ""
                try
                    set tagList to tags of a
                    repeat with t in tagList
                        set atags to atags & (id of t) & ","
                    end repeat
                end try
                set output to output & aid & "|||" & aname & "|||" & anotes & "|||" & atags & "~~~"
            end repeat
            return output
        end tell
        """)
}
