import Foundation

public func fetchToDos() -> AppleScript {
    .init(script: """
        tell application "Things3"
            set output to ""
            repeat with td in to dos
                set tdid to id of td
                set tdname to name of td
                set tdnotes to ""
                try
                    set tdnotes to notes of td
                end try
                set tdcreation to ""
                try
                    set tdcreation to creation date of td as string
                end try
                set tdmod to ""
                try
                    set tdmod to modification date of td as string
                end try
                set tddueDate to ""
                try
                    set tddueDate to due date of td as string
                end try
                set tdactivation to ""
                try
                    set tdactivation to activation date of td as string
                end try
                set tdcompletion to ""
                try
                    set tdcompletion to completion date of td as string
                end try
                set tdcancellation to ""
                try
                    set tdcancellation to cancellation date of td as string
                end try
                set tdstatus to status of td as string
                set tdtoday to "false"
                set tdproject to ""
                try
                    set tdproject to id of project of td
                end try
                set tdarea to ""
                try
                    set tdarea to id of area of td
                end try
                set tdtags to ""
                try
                    set tagList to tags of td
                    repeat with t in tagList
                        set tdtags to tdtags & (id of t) & ","
                    end repeat
                end try
                set output to output & tdid & "|||" & tdname & "|||" & tdnotes & "|||" & tdcreation & "|||" & tdmod & "|||" & tddueDate & "|||" & tdactivation & "|||" & tdcompletion & "|||" & tdcancellation & "|||" & tdstatus & "|||" & tdtoday & "|||" & tdproject & "|||" & tdarea & "|||" & tdtags & "~~~"
            end repeat
            return output
        end tell
        """)
}
