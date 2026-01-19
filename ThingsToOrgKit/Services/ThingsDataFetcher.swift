import Foundation

public actor ThingsDataFetcher {
    private let parser = ThingsParser()

    public init() {}

    public func fetchAll() async throws -> ThingsDatabase {
        // Execute all scripts in parallel
        async let tagsOutput = fetchTags()()
        async let areasOutput = fetchAreas()()
        async let projectsOutput = fetchProjects()()
        async let toDosOutput = fetchToDos()()

        let (tags, areas, projects, toDos) = try await (
            tagsOutput,
            areasOutput,
            projectsOutput,
            toDosOutput
        )

        return ThingsDatabase(
            tags: parser.parseTags(from: tags),
            areas: parser.parseAreas(from: areas),
            projects: parser.parseProjects(from: projects),
            toDos: parser.parseToDos(from: toDos)
        )
    }
}
