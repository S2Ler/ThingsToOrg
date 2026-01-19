import Foundation

public struct ThingsToDo: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let notes: String?
    public let creationDate: Date?
    public let modificationDate: Date?
    public let dueDate: Date?
    public let activationDate: Date?  // SCHEDULED in Org
    public let completionDate: Date?
    public let cancellationDate: Date?
    public let status: ThingsItemStatus
    public let todayFlag: Bool
    public let projectId: String?
    public let areaId: String?
    public let tagIds: [String]

    public init(
        id: String,
        name: String,
        notes: String? = nil,
        creationDate: Date? = nil,
        modificationDate: Date? = nil,
        dueDate: Date? = nil,
        activationDate: Date? = nil,
        completionDate: Date? = nil,
        cancellationDate: Date? = nil,
        status: ThingsItemStatus = .open,
        todayFlag: Bool = false,
        projectId: String? = nil,
        areaId: String? = nil,
        tagIds: [String] = []
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.dueDate = dueDate
        self.activationDate = activationDate
        self.completionDate = completionDate
        self.cancellationDate = cancellationDate
        self.status = status
        self.todayFlag = todayFlag
        self.projectId = projectId
        self.areaId = areaId
        self.tagIds = tagIds
    }
}
