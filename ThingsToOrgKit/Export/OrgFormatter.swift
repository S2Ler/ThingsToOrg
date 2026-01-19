import Foundation

public struct OrgFormatter {

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd EEE"  // Org format: <2025-01-20 Mon>
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    public init() {}

    // MARK: - Status Mapping

    private func orgStatus(for status: ThingsItemStatus) -> String {
        switch status {
        case .open: return "TODO"
        case .completed: return "DONE"
        case .cancelled, .canceled: return "CANCELLED"
        }
    }

    // MARK: - Tag Formatting

    private func formatTags(_ tagIds: [String], database: ThingsDatabase, additionalTags: [String] = []) -> String {
        var allTags = additionalTags
        allTags += tagIds.compactMap { database.tag(byId: $0)?.name }

        guard !allTags.isEmpty else { return "" }

        // Org tags: replace spaces with underscores, join with colons
        let sanitized = allTags.map { tag in
            tag.replacingOccurrences(of: " ", with: "_")
               .replacingOccurrences(of: ":", with: "_")
        }
        return ":" + sanitized.joined(separator: ":") + ":"
    }

    // MARK: - Date Formatting

    private func formatOrgDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        return "<\(dateFormatter.string(from: date))>"
    }

    // MARK: - Notes Formatting

    private func formatNotes(_ notes: String?, indent: String) -> String {
        guard let notes, !notes.isEmpty else { return "" }

        // Escape lines that start with * (would be interpreted as headings)
        let lines = notes.components(separatedBy: .newlines)
        let escaped = lines.map { line -> String in
            if line.hasPrefix("*") {
                return ",\(line)"  // Org escape for literal *
            }
            return line
        }
        let indented = escaped.map { indent + $0 }.joined(separator: "\n")
        return "\n" + indented + "\n"
    }

    // MARK: - Main Export

    public func format(database: ThingsDatabase) -> String {
        var output = ""

        // File header
        output += "#+TITLE: Things 3 Export\n"
        output += "#+DATE: \(formatOrgDate(Date()) ?? "")\n"
        output += "#+STARTUP: overview\n"
        output += "#+TODO: TODO | DONE CANCELLED\n\n"

        // 1. Export areas with their projects and tasks
        for area in database.areas {
            output += formatArea(area, database: database)
        }

        // 2. Export orphan projects (no area)
        let orphanProjects = database.orphanProjects()
        if !orphanProjects.isEmpty {
            output += "* No Area                                                   :noArea:\n"
            for project in orphanProjects {
                output += formatProject(project, database: database, level: 2)
            }
        }

        // 3. Export orphan tasks (no project, no area)
        let orphanToDos = database.orphanToDos()
        if !orphanToDos.isEmpty {
            output += "* Inbox                                                     :inbox:\n"
            for toDo in orphanToDos {
                output += formatToDo(toDo, database: database, level: 2)
            }
        }

        return output
    }

    // MARK: - Entity Formatting

    private func formatArea(_ area: ThingsArea, database: ThingsDatabase) -> String {
        var output = ""

        // Area heading (level 1)
        let tags = formatTags(area.tagIds, database: database, additionalTags: ["area"])
        output += "* \(area.name)"
        if !tags.isEmpty {
            // Pad to column 60 for aligned tags
            let currentLen = 2 + area.name.count
            let padding = max(1, 60 - currentLen)
            output += String(repeating: " ", count: padding) + tags
        }
        output += "\n"

        // Area notes
        output += formatNotes(area.notes, indent: "  ")

        // Projects in this area
        for project in database.projects(forAreaId: area.id) {
            output += formatProject(project, database: database, level: 2)
        }

        // Direct tasks in area (not in project)
        for toDo in database.toDos(forAreaId: area.id) {
            output += formatToDo(toDo, database: database, level: 2)
        }

        return output
    }

    private func formatProject(_ project: ThingsProject, database: ThingsDatabase, level: Int) -> String {
        var output = ""

        let stars = String(repeating: "*", count: level)
        let indent = String(repeating: " ", count: level + 1)

        // Project heading with status
        let status = orgStatus(for: project.status)
        let tags = formatTags(project.tagIds, database: database, additionalTags: ["project"])

        output += "\(stars) \(status) \(project.name)"
        if !tags.isEmpty {
            let baseLen = level + 1 + status.count + 1 + project.name.count
            let padding = max(1, 60 - baseLen)
            output += String(repeating: " ", count: padding) + tags
        }
        output += "\n"

        // Deadline
        if let deadline = formatOrgDate(project.dueDate) {
            output += "\(indent)DEADLINE: \(deadline)\n"
        }

        // Completion date (as CLOSED)
        if let closed = formatOrgDate(project.completionDate) {
            output += "\(indent)CLOSED: \(closed)\n"
        }

        // Project notes
        output += formatNotes(project.notes, indent: indent)

        // Tasks in project
        for toDo in database.toDos(forProjectId: project.id) {
            output += formatToDo(toDo, database: database, level: level + 1)
        }

        return output
    }

    private func formatToDo(_ toDo: ThingsToDo, database: ThingsDatabase, level: Int) -> String {
        var output = ""

        let stars = String(repeating: "*", count: level)
        let indent = String(repeating: " ", count: level + 1)

        // Task heading with status
        let status = orgStatus(for: toDo.status)
        var additionalTags: [String] = []
        if toDo.todayFlag { additionalTags.append("today") }
        let tags = formatTags(toDo.tagIds, database: database, additionalTags: additionalTags)

        output += "\(stars) \(status) \(toDo.name)"
        if !tags.isEmpty {
            let baseLen = level + 1 + status.count + 1 + toDo.name.count
            let padding = max(1, 60 - baseLen)
            output += String(repeating: " ", count: padding) + tags
        }
        output += "\n"

        // Scheduled (activation date)
        if let scheduled = formatOrgDate(toDo.activationDate) {
            output += "\(indent)SCHEDULED: \(scheduled)\n"
        }

        // Deadline
        if let deadline = formatOrgDate(toDo.dueDate) {
            output += "\(indent)DEADLINE: \(deadline)\n"
        }

        // Completion date
        if let closed = formatOrgDate(toDo.completionDate) {
            output += "\(indent)CLOSED: \(closed)\n"
        }

        // Task notes
        output += formatNotes(toDo.notes, indent: indent)

        return output
    }
}
