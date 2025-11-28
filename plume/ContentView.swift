import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var journalService: JournalService
    @State private var selectedTab: Tab = .today
    @State private var showSettings = false
    @State private var showSearch = false
    @State private var showCommandPalette = false
    @State private var presentOnboarding = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    enum Tab: CaseIterable {
        case calendar
        case today
        case todos
        case explore
    }

    var body: some View {
        ZStack {
            #if os(macOS)
            macOSView
            #else
            iOSView
            #endif
            
            if showCommandPalette {
                CommandPaletteView(isPresented: $showCommandPalette)
                    .zIndex(100)
            }
        }
        .background(
            Button("Command Palette") {
                showCommandPalette.toggle()
            }
            .keyboardShortcut("k", modifiers: .command)
            .opacity(0)
        )
    }

    @ViewBuilder
    private var iOSView: some View {
        ZStack {
            AppColors.Background.mainLight
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header - always show on iOS
                plumeHeader

                // Tab Content
                tabContent(for: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Navigation - show on iPhone only
                if !isIPad {
                    PlumeTabBar(selectedTab: $selectedTab)
                }
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
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
    }

    #if os(macOS)
    @ViewBuilder
    private var macOSView: some View {
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
    }
    #endif

    // MARK: - Header matching React Native
    private var plumeHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            // Left: Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("Plume")
                    .font(.system(size: isIPad ? 42 : 20, weight: .bold))
                    .foregroundStyle(AppColors.Text.primary)
                    .fontDesign(.serif)

                if isIPad {
                    Text("Reflect, grow, and track your journey")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.Text.secondary)
                }
            }

            Spacer()

            // Right: Navigation grouped together
            HStack(spacing: isIPad ? 16 : 8) {
                // Settings button
                HeaderButton(icon: "gearshape.fill") {
                    showSettings = true
                }

                // iPad Tab Navigation
                if isIPad {
                    iPadTabNavigation
                }

                // Search button
                HeaderButton(icon: "magnifyingglass") {
                    showSearch = true
                }
            }
        }
        .padding(.horizontal, isIPad ? 24 : 12)
        .padding(.vertical, isIPad ? 20 : 12)
        .background(
            AppColors.Background.mainLight.opacity(0.95)
                .overlay(
                    Rectangle()
                        .fill(AppColors.Border.subtle.opacity(0.5))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }

    // iPad-specific tab navigation in header (like React Native)
    private var iPadTabNavigation: some View {
        HStack(spacing: 0) {
            iPadTab(.calendar, label: "Calendar", icon: "calendar")
            iPadTab(.today, label: "Today", icon: "circle.fill")
            iPadTab(.explore, label: "Explore", icon: "safari.fill")
        }
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
    }

    private func iPadTab(_ tab: Tab, label: String, icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? AppColors.Background.secondaryDark : AppColors.Text.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(selectedTab == tab ? AppColors.primary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        switch tab {
        case .calendar:
            CalendarView()
        case .today:
            TodayHeroView(date: Date())
                .environmentObject(journalService)
        case .todos:
            TodosView()
        case .explore:
            ExploreView()
        }
    }
}

// Header button matching React Native style
private struct HeaderButton: View {
    let icon: String
    let action: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: isIPad ? 20 : 18, weight: .medium))
                .foregroundStyle(AppColors.Text.primary)
                .frame(width: isIPad ? 44 : 36, height: isIPad ? 44 : 36)
                .background(AppColors.Background.secondaryDark)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColors.Border.subtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
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
