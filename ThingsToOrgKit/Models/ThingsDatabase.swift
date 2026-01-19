import Foundation

/// Represents all exported data from Things 3
public struct ThingsDatabase: Sendable {
    public let tags: [ThingsTag]
    public let areas: [ThingsArea]
    public let projects: [ThingsProject]
    public let toDos: [ThingsToDo]

    public init(
        tags: [ThingsTag] = [],
        areas: [ThingsArea] = [],
        projects: [ThingsProject] = [],
        toDos: [ThingsToDo] = []
    ) {
        self.tags = tags
        self.areas = areas
        self.projects = projects
        self.toDos = toDos
    }

    /// Get tag by ID
    public func tag(byId id: String) -> ThingsTag? {
        tags.first { $0.id == id }
    }

    /// Get projects for area
    public func projects(forAreaId areaId: String) -> [ThingsProject] {
        projects.filter { $0.areaId == areaId }
    }

    /// Get to-dos for project
    public func toDos(forProjectId projectId: String) -> [ThingsToDo] {
        toDos.filter { $0.projectId == projectId }
    }

    /// Get to-dos directly in area (not in project)
    public func toDos(forAreaId areaId: String) -> [ThingsToDo] {
        toDos.filter { $0.areaId == areaId && $0.projectId == nil }
    }

    /// Get orphan projects (no area)
    public func orphanProjects() -> [ThingsProject] {
        projects.filter { $0.areaId == nil }
    }

    /// Get orphan to-dos (no project, no area)
    public func orphanToDos() -> [ThingsToDo] {
        toDos.filter { $0.projectId == nil && $0.areaId == nil }
    }
}
