import Foundation
import SwiftData
import UniformTypeIdentifiers

struct PlumeExport: Codable {
    let version: String
    let exportDate: Date
    let entries: [ExportEntry]
    let todos: [ExportTodo]
    
    struct ExportEntry: Codable {
        let id: String
        let date: Date
        let gratitudes: [String]
        let memory: String?
        let accomplishments: [String]
        let journal: String?
        let wordCount: Int
        let createdAt: Date
        let updatedAt: Date
    }
    
    struct ExportTodo: Codable {
        let id: String
        let date: Date
        let title: String
        let completed: Bool
        let createdAt: Date
        let updatedAt: Date
    }
}

@MainActor
class ExportService {
    static let shared = ExportService()
    
    func exportData(entries: [Entry], todos: [Todo]) throws -> Data {
        let exportEntries = entries.map { entry in
            PlumeExport.ExportEntry(
                id: entry.id.uuidString,
                date: entry.date,
                gratitudes: entry.gratitudes,
                memory: entry.memory,
                accomplishments: entry.accomplishments,
                journal: entry.journal,
                wordCount: entry.wordCount,
                createdAt: entry.createdAt,
                updatedAt: entry.updatedAt
            )
        }
        
        let exportTodos = todos.map { todo in
            PlumeExport.ExportTodo(
                id: todo.id.uuidString,
                date: todo.date,
                title: todo.title,
                completed: todo.completed,
                createdAt: todo.createdAt,
                updatedAt: todo.updatedAt
            )
        }
        
        let export = PlumeExport(
            version: "1.0",
            exportDate: Date(),
            entries: exportEntries,
            todos: exportTodos
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try encoder.encode(export)
    }
    
    func importData(from data: Data, modelContext: ModelContext) throws -> (entriesCount: Int, todosCount: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let importData = try decoder.decode(PlumeExport.self, from: data)
        
        // Import entries
        for exportEntry in importData.entries {
            let entry = Entry(
                id: UUID(uuidString: exportEntry.id) ?? UUID(),
                date: exportEntry.date,
                gratitudes: exportEntry.gratitudes,
                memory: exportEntry.memory,
                accomplishments: exportEntry.accomplishments,
                journal: exportEntry.journal
            )
            modelContext.insert(entry)
        }
        
        // Import todos
        for exportTodo in importData.todos {
            let todo = Todo(
                id: UUID(uuidString: exportTodo.id) ?? UUID(),
                date: exportTodo.date,
                title: exportTodo.title,
                completed: exportTodo.completed
            )
            modelContext.insert(todo)
        }
        
        try modelContext.save()
        
        return (importData.entries.count, importData.todos.count)
    }
    
    func exportToFile(entries: [Entry], todos: [Todo]) throws -> URL {
        let data = try exportData(entries: entries, todos: todos)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let filename = "plume-export-\(dateString).plume"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        try data.write(to: tempURL)
        
        return tempURL
    }
}

// Custom UTType for .plume files
extension UTType {
    static let plumeExport = UTType(exportedAs: "com.plume.export")
}
