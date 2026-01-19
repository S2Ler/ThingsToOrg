import Foundation

public struct ThingsParser {

    /// Delimiter between fields
    private static let fieldDelimiter = "|||"
    /// Delimiter between records
    private static let recordDelimiter = "~~~"

    public init() {}

    // MARK: - Date Parsing

    private func parseDate(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Things 3 returns dates in various formats depending on locale
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.dateStyle = .full
                f.timeStyle = .medium
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateStyle = .long
                f.timeStyle = .medium
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm:ss a"
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return f
            }()
        ]

        for formatter in formatters {
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        return nil
    }

    private func parseTagIds(_ string: String) -> [String] {
        string
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func parseStatus(_ string: String) -> ThingsItemStatus {
        switch string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
        case "open": return .open
        case "completed": return .completed
        case "cancelled", "canceled": return .cancelled
        default: return .open
        }
    }

    // MARK: - Entity Parsing

    public func parseTags(from output: String) -> [ThingsTag] {
        let records = output.components(separatedBy: Self.recordDelimiter)
        return records.compactMap { record -> ThingsTag? in
            let fields = record.components(separatedBy: Self.fieldDelimiter)
            guard fields.count >= 2 else { return nil }
            let id = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { return nil }

            return ThingsTag(
                id: id,
                name: fields[1].trimmingCharacters(in: .whitespacesAndNewlines),
                parentTagId: fields.count > 2 && !fields[2].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    : nil
            )
        }
    }

    public func parseAreas(from output: String) -> [ThingsArea] {
        let records = output.components(separatedBy: Self.recordDelimiter)
        return records.compactMap { record -> ThingsArea? in
            let fields = record.components(separatedBy: Self.fieldDelimiter)
            guard fields.count >= 2 else { return nil }
            let id = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { return nil }

            let notes = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""

            return ThingsArea(
                id: id,
                name: fields[1].trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.isEmpty ? nil : notes,
                tagIds: fields.count > 3 ? parseTagIds(fields[3]) : []
            )
        }
    }

    public func parseProjects(from output: String) -> [ThingsProject] {
        let records = output.components(separatedBy: Self.recordDelimiter)
        return records.compactMap { record -> ThingsProject? in
            let fields = record.components(separatedBy: Self.fieldDelimiter)
            guard fields.count >= 5 else { return nil }
            let id = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { return nil }

            let notes = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let areaId = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)

            return ThingsProject(
                id: id,
                name: fields[1].trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.isEmpty ? nil : notes,
                areaId: areaId.isEmpty ? nil : areaId,
                status: parseStatus(fields[4]),
                dueDate: fields.count > 5 ? parseDate(fields[5]) : nil,
                completionDate: fields.count > 6 ? parseDate(fields[6]) : nil,
                tagIds: fields.count > 7 ? parseTagIds(fields[7]) : []
            )
        }
    }

    public func parseToDos(from output: String) -> [ThingsToDo] {
        let records = output.components(separatedBy: Self.recordDelimiter)
        return records.compactMap { record -> ThingsToDo? in
            let fields = record.components(separatedBy: Self.fieldDelimiter)
            guard fields.count >= 10 else { return nil }
            let id = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { return nil }

            let notes = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let projectId = fields.count > 11 ? fields[11].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let areaId = fields.count > 12 ? fields[12].trimmingCharacters(in: .whitespacesAndNewlines) : ""

            return ThingsToDo(
                id: id,
                name: fields[1].trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.isEmpty ? nil : notes,
                creationDate: parseDate(fields[3]),
                modificationDate: parseDate(fields[4]),
                dueDate: parseDate(fields[5]),
                activationDate: parseDate(fields[6]),
                completionDate: parseDate(fields[7]),
                cancellationDate: parseDate(fields[8]),
                status: parseStatus(fields[9]),
                todayFlag: fields.count > 10 && fields[10].lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "true",
                projectId: projectId.isEmpty ? nil : projectId,
                areaId: areaId.isEmpty ? nil : areaId,
                tagIds: fields.count > 13 ? parseTagIds(fields[13]) : []
            )
        }
    }
}
