import Foundation

public actor ExportService {
    private let fetcher = ThingsDataFetcher()
    private let formatter = OrgFormatter()

    public init() {}

    public struct ExportResult: Sendable {
        public let content: String
        public let statistics: Statistics

        public struct Statistics: Sendable {
            public let areasCount: Int
            public let projectsCount: Int
            public let toDosCount: Int
            public let tagsCount: Int
        }
    }

    public func export() async throws -> ExportResult {
        let database = try await fetcher.fetchAll()
        let content = formatter.format(database: database)

        return ExportResult(
            content: content,
            statistics: .init(
                areasCount: database.areas.count,
                projectsCount: database.projects.count,
                toDosCount: database.toDos.count,
                tagsCount: database.tags.count
            )
        )
    }

    public func exportToFile(url: URL) async throws -> ExportResult {
        let result = try await export()
        try result.content.write(to: url, atomically: true, encoding: .utf8)
        return result
    }
}
