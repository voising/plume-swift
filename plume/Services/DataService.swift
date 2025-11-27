import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Combine

@MainActor
final class DataService: ObservableObject {
    private let modelContext: ModelContext
    @Published var lastExportDate: Date?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Export
    
    struct ExportData: Codable {
        let version: String
        let exportedAt: Date
        let entries: [EntryData]
        let todos: [TodoData]
        
        struct EntryData: Codable {
            let id: UUID
            let date: Date
            let gratitudes: [String]
            let memory: String?
            let accomplishments: [String]
            let journal: String?
            let createdAt: Date
            let updatedAt: Date
        }
        
        struct TodoData: Codable {
            let id: UUID
            let date: Date
            let title: String
            let completed: Bool
            let createdAt: Date
            let updatedAt: Date
        }
    }
    
    func exportData() -> URL? {
        do {
            // Fetch all data
            let entryDescriptor = FetchDescriptor<Entry>()
            let entries = try modelContext.fetch(entryDescriptor)
            
            let todoDescriptor = FetchDescriptor<Todo>()
            let todos = try modelContext.fetch(todoDescriptor)
            
            // Map to codable structs
            let exportEntries = entries.map { entry in
                ExportData.EntryData(
                    id: entry.id,
                    date: entry.date,
                    gratitudes: entry.gratitudes,
                    memory: entry.memory,
                    accomplishments: entry.accomplishments,
                    journal: entry.journal,
                    createdAt: entry.createdAt,
                    updatedAt: entry.updatedAt
                )
            }
            
            let exportTodos = todos.map { todo in
                ExportData.TodoData(
                    id: todo.id,
                    date: todo.date,
                    title: todo.title,
                    completed: todo.completed,
                    createdAt: todo.createdAt,
                    updatedAt: todo.updatedAt
                )
            }
            
            let exportData = ExportData(
                version: "1.0",
                exportedAt: Date(),
                entries: exportEntries,
                todos: exportTodos
            )
            
            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportData)
            
            // Write to temporary file
            let fileName = "Plume_Backup_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).json"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            
            lastExportDate = Date()
            
            return fileURL
            
        } catch {
            print("Export failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Import (Placeholder logic for now, as we need a UI to pick file)
    func importData(from url: URL) async throws {
        // 1. Decode data
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let importData = try decoder.decode(ExportData.self, from: data)
        
        // 2. Clear existing data? Or merge? 
        // For simplicity in this version, we'll append/merge based on ID, or just insert.
        // A real app might ask the user.
        
        for item in importData.entries {
            // Check if exists
            let id = item.id
            let descriptor = FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })
            if let existing = try? modelContext.fetch(descriptor).first {
                // Update
                existing.journal = item.journal
                existing.memory = item.memory
                existing.gratitudes = item.gratitudes
                existing.accomplishments = item.accomplishments
                existing.updatedAt = item.updatedAt
            } else {
                // Insert
                let newEntry = Entry(
                    id: item.id,
                    date: item.date,
                    gratitudes: item.gratitudes,
                    memory: item.memory,
                    accomplishments: item.accomplishments,
                    journal: item.journal
                )
                newEntry.createdAt = item.createdAt
                newEntry.updatedAt = item.updatedAt
                modelContext.insert(newEntry)
            }
        }
        
        for item in importData.todos {
            let id = item.id
            let descriptor = FetchDescriptor<Todo>(predicate: #Predicate { $0.id == id })
            if let existing = try? modelContext.fetch(descriptor).first {
                existing.title = item.title
                existing.completed = item.completed
                existing.updatedAt = item.updatedAt
            } else {
                let newTodo = Todo(
                    id: item.id,
                    date: item.date,
                    title: item.title,
                    completed: item.completed
                )
                newTodo.createdAt = item.createdAt
                newTodo.updatedAt = item.updatedAt
                modelContext.insert(newTodo)
            }
        }
    }
    
    func deleteAllData() {
        do {
            try modelContext.delete(model: Entry.self)
            try modelContext.delete(model: Todo.self)
        } catch {
            print("Delete failed: \(error)")
        }
    }
}
