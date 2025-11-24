import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Tab = .calendar
    
    enum Tab {
        case calendar
        case today
        case todos
        case explore
        case settings
    }

    var body: some View {
        #if os(iOS)
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(Tab.calendar)
                .keyboardShortcut("1", modifiers: .command)
            
            NavigationStack {
                EntryDetailView(date: Date())
            }
            .tabItem {
                Label("Today", systemImage: "sun.max")
            }
            .tag(Tab.today)
            .keyboardShortcut("t", modifiers: .command)
            
            NavigationStack {
                TodosView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(Tab.todos)
            .keyboardShortcut("2", modifiers: .command)
            
            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label("Explore", systemImage: "magnifyingglass")
            }
            .tag(Tab.explore)
            .keyboardShortcut("3", modifiers: .command)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(Tab.settings)
            .keyboardShortcut("4", modifiers: .command)
        }
        #else
        NavigationSplitView {
            List(selection: $selectedTab) {
                NavigationLink(value: Tab.calendar) {
                    Label("Calendar", systemImage: "calendar")
                }
                NavigationLink(value: Tab.today) {
                    Label("Today", systemImage: "sun.max")
                }
                NavigationLink(value: Tab.todos) {
                    Label("Tasks", systemImage: "checklist")
                }
                NavigationLink(value: Tab.explore) {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                NavigationLink(value: Tab.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("Plume")
        } detail: {
            switch selectedTab {
            case .calendar:
                CalendarView()
            case .today:
                EntryDetailView(date: Date())
            case .todos:
                TodosView()
            case .explore:
                ExploreView()
            case .settings:
                SettingsView()
            }
        }
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
        .environmentObject(AIService())
}
