import Foundation

public struct ThingsTag: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let parentTagId: String?

    public init(id: String, name: String, parentTagId: String? = nil) {
        self.id = id
        self.name = name
        self.parentTagId = parentTagId
    }
}
