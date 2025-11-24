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
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(.blue)
                Text("Tasks")
                    .font(.headline)
                
                Spacer()
                
                Text("\(todosForDate.filter { !$0.completed }.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Todo Items
            if todosForDate.isEmpty {
                Text("No tasks for this day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
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
            
            // Add New Todo
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .imageScale(.small)
                
                TextField("Add a task...", text: $newTodoText)
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .onSubmit {
                        addTodo()
                    }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(AppColors.Background.secondaryLight)
        .cornerRadius(12)
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
            // Checkbox
            Button(action: {
                withAnimation {
                    todo.completed.toggle()
                    todo.updatedAt = Date()
                }
            }) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.completed ? .green : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            
            // Title
            Text(todo.title)
                .strikethrough(todo.completed)
                .foregroundStyle(todo.completed ? .secondary : .primary)
            
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
                    .imageScale(.medium)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.vertical, 4)
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
