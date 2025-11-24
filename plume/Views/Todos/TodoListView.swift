import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]
    
    let date: Date
    @State private var newTodoText = ""
    @FocusState private var isInputFocused: Bool
    
    var todosForDate: [Todo] {
        let calendar = Calendar.current
        return allTodos.filter { todo in
            calendar.isDate(todo.date, inSameDayAs: date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(AppColors.primary)
                Text("Tasks")
                    .font(.headline)
                    .foregroundStyle(AppColors.Text.primary)
                Spacer()
                Text("\(todosForDate.filter { !$0.completed }.count) open")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            
            if todosForDate.isEmpty {
                Text("No tasks for this day")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(todosForDate) { todo in
                        TodoRow(todo: todo, onDelete: {
                            deleteTodo(todo)
                        }, onMoveToToday: {
                            moveToToday(todo)
                        }, onMoveToTomorrow: {
                            moveToTomorrow(todo)
                        })
                    }
                }
            }
            
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .foregroundStyle(AppColors.primary)
                TextField("Add a task...", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppColors.Text.primary)
                    .focused($isInputFocused)
                    .onSubmit {
                        addTodo()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .plumeCard()
    }
    
    private func addTodo() {
        guard !newTodoText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let todo = Todo(date: date, title: newTodoText)
        modelContext.insert(todo)
        newTodoText = ""
        isInputFocused = true
    }
    
    private func deleteTodo(_ todo: Todo) {
        modelContext.delete(todo)
    }
    
    private func moveToToday(_ todo: Todo) {
        todo.date = Date()
        todo.updatedAt = Date()
    }
    
    private func moveToTomorrow(_ todo: Todo) {
        todo.date = Calendar.current.date(byAdding: .day, value: 1, to: todo.date) ?? todo.date
        todo.updatedAt = Date()
    }
}

struct TodoRow: View {
    @Bindable var todo: Todo
    let onDelete: () -> Void
    let onMoveToToday: () -> Void
    let onMoveToTomorrow: () -> Void
    
    @State private var showActions = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggleCompletion) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.completed ? AppColors.EntryType.memory : AppColors.Border.subtle)
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
            
            Text(todo.title)
                .foregroundStyle(todo.completed ? AppColors.Text.secondary : AppColors.Text.primary)
                .strikethrough(todo.completed, color: AppColors.Text.secondary)
            
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
        .padding(.vertical, 4)
    }
    
    private func toggleCompletion() {
        withAnimation {
            todo.completed.toggle()
            todo.updatedAt = Date()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Entry.self, Todo.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    
    // Add sample todos
    let todo1 = Todo(date: Date(), title: "Review code", completed: false)
    let todo2 = Todo(date: Date(), title: "Write tests", completed: true)
    context.insert(todo1)
    context.insert(todo2)
    
    return TodoListView(date: Date())
        .modelContainer(container)
        .frame(width: 400)
}
