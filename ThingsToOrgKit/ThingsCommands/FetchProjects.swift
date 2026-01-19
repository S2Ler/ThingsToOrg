import Foundation

public func fetchProjects() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            repeat with p in projects
                set pid to id of p
                set pname to name of p
                set pnotes to ""
                try
                    set pnotes to notes of p
                end try
                set parea to ""
                try
                    set parea to id of area of p
                end try
                set pstatus to status of p as string
                set pdueDate to ""
                try
                    set pdueDate to due date of p as string
                end try
                set pcompletionDate to ""
                try
                    set pcompletionDate to completion date of p as string
                end try
                set ptags to ""
                try
                    set tagList to tags of p
                    repeat with t in tagList
                        set ptags to ptags & (id of t) & ","
                    end repeat
                end try
                set output to output & pid & "|||" & pname & "|||" & pnotes & "|||" & parea & "|||" & pstatus & "|||" & pdueDate & "|||" & pcompletionDate & "|||" & ptags & "~~~"
            end repeat
            return output
        end tell
        """)
}
