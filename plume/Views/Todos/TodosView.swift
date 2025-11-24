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
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColors.primary)
                        TextField("Quick add a task...", text: $newTodoText)
                            .textFieldStyle(.plain)
                            .foregroundStyle(AppColors.Text.primary)
                            .focused($isInputFocused)
                            .onSubmit {
                                addTodo()
                            }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(AppColors.Background.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(TodoFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .plumeCard()
                
                if !overdueTodos.isEmpty && selectedFilter != .completed {
                    VStack(alignment: .leading, spacing: 12) {
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
                    .background(AppColors.Background.elevated.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.red.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                if filteredTodos.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 58))
                            .foregroundStyle(AppColors.EntryType.memory.opacity(0.6))
                        Text(emptyStateMessage)
                            .font(.headline)
                            .foregroundStyle(AppColors.Text.secondary)
                    }
                    .padding(.vertical, 80)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.Background.secondaryDark)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 16) {
                        ForEach(groupedTodos.keys.sorted(), id: \.self) { date in
                            if let todos = groupedTodos[date] {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(formatDate(date))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppColors.Text.secondary)
                                        .textCase(.uppercase)
                                    
                                    VStack(spacing: 12) {
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
                                .plumeCard()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
        .background(AppColors.Background.mainLight)
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
            Button(action: toggle) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.completed ? AppColors.EntryType.memory : AppColors.Border.subtle)
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .foregroundStyle(todo.completed ? AppColors.Text.secondary : AppColors.Text.primary)
                    .strikethrough(todo.completed, color: AppColors.Text.secondary)
                
                Text(statusText)
                    .font(.caption2)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            
            Spacer()
            
            Menu {
                if !Calendar.current.isDateInToday(todo.date) {
                    Button(action: onMoveToToday) {
                        Label("Move to Today", systemImage: "arrowshape.turn.up.left")
                    }
                }
                
                Button(action: onMoveToTomorrow) {
                    Label("Move to Tomorrow", systemImage: "arrow.right.circle")
                }
                
                Divider()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(AppColors.Text.secondary)
            }
            .menuStyle(.borderlessButton)
        }
        .padding()
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
    }
    
    private var statusText: String {
        if todo.completed {
            return "Completed"
        } else if Calendar.current.isDateInToday(todo.date) {
            return "Due Today"
        } else if todo.date < Date() {
            return "Overdue"
        } else {
            return "Upcoming"
        }
    }
    
    private func toggle() {
        withAnimation {
            todo.completed.toggle()
            todo.updatedAt = Date()
        }
    }
}

#Preview {
    NavigationStack {
        TodosView()
            .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
    }
}
