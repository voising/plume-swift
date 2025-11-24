import SwiftUI
import SwiftData

struct TodosView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Todo.date, order: .forward) private var allTodos: [Todo]
    
    @State private var selectedFilter: TodoFilter = .today
    @State private var newTodoText = ""
    @FocusState private var isInputFocused: Bool
    
    enum TodoFilter: String, CaseIterable {
        case today = "Today"
        case upcoming = "Upcoming"
        case all = "All"
        case completed = "Completed"
    }
    
    var filteredTodos: [Todo] {
        let calendar = Calendar.current
        
        switch selectedFilter {
        case .today:
            return allTodos.filter { calendar.isDateInToday($0.date) && !$0.completed }
        case .upcoming:
            return allTodos.filter { $0.date > Date() && !$0.completed }
        case .all:
            return allTodos.filter { !$0.completed }
        case .completed:
            return allTodos.filter { $0.completed }
        }
    }
    
    var overdueTodos: [Todo] {
        let calendar = Calendar.current
        return allTodos.filter { 
            $0.date < calendar.startOfDay(for: Date()) && !$0.completed 
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Quick Add
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                    
                    TextField("Quick add a task...", text: $newTodoText)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($isInputFocused)
                        .onSubmit {
                            addTodo()
                        }
                }
                .padding()
                .background(AppColors.Background.secondaryLight)
                .cornerRadius(12)
                
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TodoFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            
            // Todo List
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Overdue Section
                    if !overdueTodos.isEmpty && selectedFilter != .completed {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .foregroundStyle(.red)
                            
                            ForEach(overdueTodos) { todo in
                                TodoRowDetailed(todo: todo, onDelete: {
                                    deleteTodo(todo)
                                }, onMoveToToday: {
                                    moveToToday(todo)
                                }, onMoveToTomorrow: {
                                    moveToTomorrow(todo)
                                })
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Filtered Todos
                    if filteredTodos.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.green.opacity(0.5))
                            
                            Text(emptyStateMessage)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(groupedTodos.keys.sorted(), id: \.self) { date in
                            if let todos = groupedTodos[date] {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(formatDate(date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    
                                    ForEach(todos) { todo in
                                        TodoRowDetailed(todo: todo, onDelete: {
                                            deleteTodo(todo)
                                        }, onMoveToToday: {
                                            moveToToday(todo)
                                        }, onMoveToTomorrow: {
                                            moveToTomorrow(todo)
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Tasks")
    }
    
    private var groupedTodos: [Date: [Todo]] {
        let calendar = Calendar.current
        return Dictionary(grouping: filteredTodos) { todo in
            calendar.startOfDay(for: todo.date)
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .today:
            return "No tasks for today"
        case .upcoming:
            return "No upcoming tasks"
        case .all:
            return "No tasks yet"
        case .completed:
            return "No completed tasks"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    private func addTodo() {
        guard !newTodoText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let todo = Todo(date: Date(), title: newTodoText)
        modelContext.insert(todo)
        newTodoText = ""
        isInputFocused = true
    }
    
    private func deleteTodo(_ todo: Todo) {
        withAnimation {
            modelContext.delete(todo)
        }
    }
    
    private func moveToToday(_ todo: Todo) {
        withAnimation {
            todo.date = Date()
            todo.updatedAt = Date()
        }
    }
    
    private func moveToTomorrow(_ todo: Todo) {
        withAnimation {
            todo.date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            todo.updatedAt = Date()
        }
    }
}

struct TodoRowDetailed: View {
    @Bindable var todo: Todo
    let onDelete: () -> Void
    let onMoveToToday: () -> Void
    let onMoveToTomorrow: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                withAnimation {
                    todo.completed.toggle()
                    todo.updatedAt = Date()
                }
            }) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.completed ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .strikethrough(todo.completed)
                    .foregroundStyle(todo.completed ? .secondary : .primary)
                
                if todo.completed {
                    Text("Completed")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
            
            Spacer()
            
            // Actions Menu
            Menu {
                if !Calendar.current.isDateInToday(todo.date) {
                    Button(action: onMoveToToday) {
                        Label("Move to Today", systemImage: "arrow.right.circle")
                    }
                }
                
                Button(action: onMoveToTomorrow) {
                    Label("Move to Tomorrow", systemImage: "arrow.forward")
                }
                
                Divider()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
        }
        .padding()
        .background(AppColors.Background.secondaryLight)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        TodosView()
            .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
    }
}
