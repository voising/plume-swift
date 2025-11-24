import Foundation
import SwiftData
import Combine

@MainActor
class JournalService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Entry Operations
    
    func createEntry(date: Date) -> Entry {
        let entry = Entry(date: date)
        modelContext.insert(entry)
        return entry
    }
    
    func deleteEntry(_ entry: Entry) {
        modelContext.delete(entry)
    }
    
    func getEntry(for date: Date) -> Entry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        
        return try? modelContext.fetch(descriptor).first
    }
    
    // MARK: - Todo Operations
    
    func createTodo(title: String, date: Date) {
        let todo = Todo(date: date, title: title)
        modelContext.insert(todo)
    }
    
    func toggleTodo(_ todo: Todo) {
        todo.completed.toggle()
        todo.updatedAt = Date()
    }
    
    func deleteTodo(_ todo: Todo) {
        modelContext.delete(todo)
    }
    
    // MARK: - Statistics
    
    func calculateStreak() -> Int {
        // Simple streak calculation (consecutive days with entries)
        // This is a potentially expensive operation, should be optimized in real app
        var streak = 0
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check if today has an entry, if not check yesterday to start streak
        if getEntry(for: currentDate) == nil {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        while getEntry(for: currentDate) != nil {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    func totalWordCount() -> Int {
        let descriptor = FetchDescriptor<Entry>()
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.reduce(0) { $0 + $1.wordCount }
    }
}
