import Foundation

public struct ThingsArea: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let notes: String?
    public let tagIds: [String]

    public init(id: String, name: String, notes: String? = nil, tagIds: [String] = []) {
        self.id = id
        self.name = name
        self.notes = notes
        self.tagIds = tagIds
    }
}
