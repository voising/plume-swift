import SwiftUI
import SwiftData

struct CommandPaletteView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entry.date, order: .reverse) private var entries: [Entry]
    @Query private var todos: [Todo]
    
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var selectedIndex = 0
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Modal
            VStack(spacing: 0) {
                // Search Input
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(AppColors.Text.secondary)
                    
                    TextField("Search your memories or type a command...", text: $searchText)
                        .font(.title3)
                        .textFieldStyle(.plain)
                        .foregroundStyle(AppColors.Text.primary)
                        .autocorrectionDisabled()
                }
                .padding(20)
                .background(AppColors.Background.elevated)
                
                Divider()
                    .overlay(AppColors.Border.subtle)
                
                // Results List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if searchResults.isEmpty && !searchText.isEmpty {
                            Text("No results found")
                                .foregroundStyle(AppColors.Text.secondary)
                                .padding(30)
                        } else if searchText.isEmpty {
                            // Empty state / Suggestions
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUGGESTIONS")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppColors.Text.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                
                                CommandRow(title: "Create new todo", subtitle: "Add a task to your list", icon: "checkmark.circle", isSelected: selectedIndex == 0)
                                CommandRow(title: "Go to Today", subtitle: "Navigate to today's entry", icon: "sun.max", isSelected: selectedIndex == 1)
                            }
                        } else {
                            // Results
                            ForEach(Array(searchResults.prefix(20).enumerated()), id: \.element.id) { index, result in
                                CommandRow(
                                    title: result.title,
                                    subtitle: result.subtitle,
                                    icon: result.icon,
                                    isSelected: index == selectedIndex
                                )
                                .onTapGesture {
                                    // Handle selection
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
                
                // Footer
                HStack {
                    Text("Type to search...")
                        .font(.caption)
                        .foregroundStyle(AppColors.Text.secondary)
                    Spacer()
                    HStack(spacing: 16) {
                        Label("Select", systemImage: "arrow.up.arrow.down")
                        Label("Open", systemImage: "return")
                    }
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
                }
                .padding(12)
                .background(AppColors.Background.secondaryLight)
            }
            .frame(width: 600)
            .background(AppColors.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.Border.subtle, lineWidth: 1)
            )
            .offset(y: -50) // Slightly above center
        }
        .transition(.opacity)
    }
    
    private var searchResults: [SearchResult] {
        var results: [SearchResult] = []
        
        // Filter entries
        let filteredEntries = entries.filter { entry in
            (entry.memory?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (entry.journal?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            entry.gratitudes.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            entry.accomplishments.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        for entry in filteredEntries {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateStr = formatter.string(from: entry.date)
            
            var subtitle = ""
            if let memory = entry.memory, memory.localizedCaseInsensitiveContains(searchText) {
                subtitle = memory
            } else if let journal = entry.journal, journal.localizedCaseInsensitiveContains(searchText) {
                subtitle = journal
            } else {
                subtitle = "Entry from \(dateStr)"
            }
            
            results.append(SearchResult(title: dateStr, subtitle: subtitle, icon: "doc.text", type: .entry))
        }
        
        // Filter todos
        let filteredTodos = todos.filter { todo in
            todo.title.localizedCaseInsensitiveContains(searchText)
        }
        
        for todo in filteredTodos {
            results.append(SearchResult(title: todo.title, subtitle: "Todo", icon: "checkmark.circle", type: .todo))
        }
        
        return results
    }
    
    struct SearchResult: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let type: ResultType
        
        enum ResultType {
            case entry
            case todo
            case action
        }
    }
}

private struct CommandRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? .white : AppColors.Text.secondary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(isSelected ? .white : AppColors.Text.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : AppColors.Text.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "return")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? AppColors.primary : Color.clear)
        .contentShape(Rectangle())
    }
}

#Preview {
    CommandPaletteView(isPresented: .constant(true))
}
