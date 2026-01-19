import Foundation

public enum ThingsItemStatus: String, Sendable {
    case open
    case completed
    case cancelled
    case canceled // Things uses both spellings
}

public struct ThingsProject: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let notes: String?
    public let areaId: String?
    public let status: ThingsItemStatus
    public let dueDate: Date?
    public let completionDate: Date?
    public let tagIds: [String]

    public init(
        id: String,
        name: String,
        notes: String? = nil,
        areaId: String? = nil,
        status: ThingsItemStatus = .open,
        dueDate: Date? = nil,
        completionDate: Date? = nil,
        tagIds: [String] = []
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.areaId = areaId
        self.status = status
        self.dueDate = dueDate
        self.completionDate = completionDate
        self.tagIds = tagIds
    }
}
