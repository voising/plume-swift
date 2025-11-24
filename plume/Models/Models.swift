import Foundation
import SwiftData

@Model
final class Entry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var gratitudes: [String]
    var memory: String?
    var accomplishments: [String]
    var journal: String?
    var wordCount: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), date: Date = Date(), gratitudes: [String] = [], memory: String? = nil, accomplishments: [String] = [], journal: String? = nil) {
        self.id = id
        self.date = date
        self.gratitudes = gratitudes
        self.memory = memory
        self.accomplishments = accomplishments
        self.journal = journal
        self.wordCount = (journal?.split { $0.isWhitespace }.count) ?? 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class Todo {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var completed: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), date: Date = Date(), title: String, completed: Bool = false) {
        self.id = id
        self.date = date
        self.title = title
        self.completed = completed
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
