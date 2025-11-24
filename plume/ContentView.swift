import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var journalService: JournalService
    @State private var selectedTab: Tab = .today
    @State private var showSettings = false
    @State private var presentOnboarding = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    enum Tab: CaseIterable {
        case calendar
        case today
        case todos
        case explore
    }

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.title, systemImage: tab.icon)
                    }
                }
            }
            .navigationTitle("Plume")
        } detail: {
            tabContent(for: selectedTab)
                .toolbar {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
        }
        #else
        ZStack {
            AppColors.Background.mainLight
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                tabContent(for: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                PlumeTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 12)
            }
        }
        .tint(AppColors.primary)
        .onAppear {
            presentOnboarding = !hasCompletedOnboarding
        }
        .fullScreenCover(isPresented: $presentOnboarding) {
            OnboardingView {
                hasCompletedOnboarding = true
                presentOnboarding = false
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showSettings = false
                            }
                        }
                    }
                    .navigationTitle("Settings")
            }
            .presentationDetents([.medium, .large])
        }
        #endif
    }
    
    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        switch tab {
        case .calendar:
            NavigationStack {
                CalendarView()
            }
        case .today:
            TodayHeroView(date: Date(), showSettings: $showSettings)
                .environmentObject(journalService)
        case .todos:
            NavigationStack {
                TodosView()
                    .navigationTitle("Tasks")
            }
        case .explore:
            NavigationStack {
                ExploreView()
                    .navigationTitle("Explore")
            }
        }
    }
}

private struct PlumeTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    
    private let items: [(ContentView.Tab, String, String)] = [
        (.calendar, "calendar", "Calendar"),
        (.today, "circle.inset.filled", "Today"),
        (.todos, "checkmark.circle", "Todos"),
        (.explore, "safari", "Explore")
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(items, id: \.0) { item in
                    let isActive = selectedTab == item.0
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            selectedTab = item.0
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                if isActive {
                                    Circle()
                                        .fill(AppColors.primary.opacity(0.18))
                                        .frame(width: 44, height: 44)
                                }
                                Image(systemName: item.1)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(item.2)
                                .font(.caption)
                                .fontWeight(isActive ? .semibold : .regular)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(isActive ? AppColors.primary : AppColors.Text.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .padding(.bottom, 20)
        .background(
            AppColors.Background.secondaryLight
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

private extension ContentView.Tab {
    var icon: String {
        switch self {
        case .calendar: return "calendar"
        case .today: return "sun.max"
        case .todos: return "checkmark.circle"
        case .explore: return "safari"
        }
    }
    
    var title: String {
        switch self {
        case .calendar: return "Calendar"
        case .today: return "Today"
        case .todos: return "Todos"
        case .explore: return "Explore"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
        .environmentObject(AIService())
}
