import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showEntryDetail = false
    @State private var filter: CalendarFilter = .all

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private func useTwoColumns(screenWidth: CGFloat) -> Bool {
        // Match React Native: isIpad && width >= 1024
        return isIPad && screenWidth >= 1024
    }

    enum CalendarFilter: String, CaseIterable {
        case all = "All"
        case memory = "Memories"
        case gratitude = "Gratitudes"
        case accomplishment = "Accomplishments"
    }

    var body: some View {
        GeometryReader { geometry in
            if useTwoColumns(screenWidth: geometry.size.width) {
                iPadLandscapeLayout(geometry: geometry)
            } else {
                singleColumnLayout
            }
        }
        .background(AppColors.Background.mainLight)
    }

    // MARK: - iPad Landscape Layout (Two Columns)
    private func iPadLandscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Left: Calendar Section (2/3 width = 66.67%)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 16) {
                    CalendarHeaderView(
                        currentMonth: $currentMonth,
                        filter: $filter,
                        showFilters: true
                    )
                    .frame(maxWidth: 800)

                    CalendarGridView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate,
                        filter: filter
                    ) { date in
                        selectedDate = date
                        showEntryDetail = false
                    }
                    .frame(maxWidth: 800)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .frame(width: geometry.size.width * (2.0 / 3.0))

            // Right: Entry Details Section (1/3 width = 33.33%)
            ScrollView(showsIndicators: false) {
                EntryDetailView(date: selectedDate, autoCreateEntry: true)
                .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .frame(width: geometry.size.width * (1.0 / 3.0))
            .background(AppColors.Background.mainLight)
        }
    }

    // MARK: - Single Column Layout (iPhone / iPad Portrait)
    private var singleColumnLayout: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 16) {
                CalendarHeaderView(
                    currentMonth: $currentMonth,
                    filter: $filter,
                    showFilters: false
                )

                CalendarGridView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    filter: filter
                ) { date in
                    selectedDate = date
                    showEntryDetail = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .navigationDestination(isPresented: $showEntryDetail) {
            EntryDetailView(date: selectedDate)
                .padding(.horizontal, 20)
                .background(AppColors.Background.mainLight)
        }
    }
}

// MARK: - Calendar Header
private struct CalendarHeaderView: View {
    @Binding var currentMonth: Date
    @Binding var filter: CalendarView.CalendarFilter
    let showFilters: Bool

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Month/Year Title
            Text(monthYearString)
                .font(.custom("Georgia", size: isIPad ? 28 : 20))
                .fontWeight(.light)
                .foregroundStyle(AppColors.Text.primary)

            if showFilters {
                Spacer()

                // Filter Buttons
                HStack(spacing: 8) {
                    FilterButton(
                        title: "All",
                        isActive: filter == .all,
                        icon: nil
                    ) {
                        filter = .all
                    }

                    FilterButton(
                        title: "Memories",
                        isActive: filter == .memory,
                        icon: "sparkles",
                        iconColor: AppColors.EntryType.memory
                    ) {
                        filter = .memory
                    }

                    FilterButton(
                        title: "Gratitudes",
                        isActive: filter == .gratitude,
                        icon: "hands.sparkles.fill",
                        iconColor: AppColors.EntryType.gratitude
                    ) {
                        filter = .gratitude
                    }

                    FilterButton(
                        title: "Accomplishments",
                        isActive: filter == .accomplishment,
                        icon: "trophy.fill",
                        iconColor: AppColors.EntryType.accomplishment
                    ) {
                        filter = .accomplishment
                    }
                }
            }

            Spacer()

            // Navigation Buttons
            HStack(spacing: isIPad ? 8 : 4) {
                Button {
                    previousMonth()
                } label: {
                    Text("‹")
                        .font(.system(size: isIPad ? 18 : 16, weight: .bold))
                        .foregroundStyle(AppColors.Text.primary)
                        .frame(width: isIPad ? 30 : 24, height: isIPad ? 30 : 24)
                        .background(AppColors.Background.secondaryDark)
                        .clipShape(RoundedRectangle(cornerRadius: isIPad ? 16 : 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                                .stroke(AppColors.Border.subtle, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    nextMonth()
                } label: {
                    Text("›")
                        .font(.system(size: isIPad ? 18 : 16, weight: .bold))
                        .foregroundStyle(AppColors.Text.primary)
                        .frame(width: isIPad ? 30 : 24, height: isIPad ? 30 : 24)
                        .background(AppColors.Background.secondaryDark)
                        .clipShape(RoundedRectangle(cornerRadius: isIPad ? 16 : 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                                .stroke(AppColors.Border.subtle, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

// MARK: - Filter Button
private struct FilterButton: View {
    let title: String
    let isActive: Bool
    let icon: String?
    var iconColor: Color = AppColors.primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(isActive ? AppColors.Background.secondaryDark : iconColor)
                }
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isActive ? AppColors.Background.secondaryDark : AppColors.Text.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? AppColors.primary : AppColors.Background.secondaryDark)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? AppColors.primary : AppColors.Border.subtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Grid
private struct CalendarGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [Entry]
    @Query private var todos: [Todo]

    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let filter: CalendarView.CalendarFilter
    var onSelect: (Date) -> Void

    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack(spacing: isIPad ? 8 : 4) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: isIPad ? 16 : 11, weight: .semibold))
                        .foregroundStyle(Color(hex: "999999"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isIPad ? 8 : 2)
                }
            }

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: isIPad ? 6 : 4), count: 7), spacing: isIPad ? 8 : 4) {
                ForEach(daysInMonth()) { day in
                    if let actualDate = day.date {
                        DayCellView(
                            date: actualDate,
                            isSelected: Calendar.current.isDate(actualDate, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(actualDate),
                            isCurrentMonth: day.isWithinMonth,
                            entry: entry(for: actualDate),
                            hasTodos: hasTodos(for: actualDate),
                            filter: filter
                        )
                        .onTapGesture {
                            selectedDate = actualDate
                            onSelect(actualDate)
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }

    private func entry(for date: Date) -> Entry? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func hasTodos(for date: Date) -> Bool {
        todos.contains { Calendar.current.isDate($0.date, inSameDayAs: date) && !$0.completed }
    }

    private func daysInMonth() -> [CalendarDay] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [CalendarDay] = []

        for _ in 0..<(firstWeekday - 1) {
            days.append(CalendarDay(date: nil, isWithinMonth: false))
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(CalendarDay(date: date, isWithinMonth: true))
            }
        }

        return days
    }
}

// MARK: - Calendar Day Model
private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let isWithinMonth: Bool
}

// MARK: - Day Cell
private struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let entry: Entry?
    let hasTodos: Bool
    let filter: CalendarView.CalendarFilter

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Day number
            Text(dayString)
                .font(.system(size: isIPad ? 16 : 15, weight: isToday ? .bold : .regular))
                .foregroundStyle(textColor)
                .padding(.top, isIPad ? 8 : 2)

            Spacer(minLength: 0)

            // Indicators or filtered content
            if filter == .all {
                // Show indicator dots
                HStack(spacing: isIPad ? 2 : 2) {
                    if let entry = entry {
                        if !entry.gratitudes.isEmpty {
                            Circle()
                                .fill(AppColors.EntryType.gratitude)
                                .frame(width: isIPad ? 6 : 4, height: isIPad ? 6 : 4)
                        }
                        if entry.memory != nil {
                            Circle()
                                .fill(AppColors.EntryType.memory)
                                .frame(width: isIPad ? 6 : 4, height: isIPad ? 6 : 4)
                        }
                        if !entry.accomplishments.isEmpty {
                            Circle()
                                .fill(AppColors.EntryType.accomplishment)
                                .frame(width: isIPad ? 6 : 4, height: isIPad ? 6 : 4)
                        }
                    }
                    
                    if hasTodos {
                        Circle()
                            .fill(AppColors.Text.secondary)
                            .frame(width: isIPad ? 6 : 4, height: isIPad ? 6 : 4)
                    }
                }
                .padding(.bottom, isIPad ? 4 : 2)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: isIPad ? 16 : 12))
        .overlay(
            RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .opacity(isCurrentMonth ? 1.0 : 0.4)
    }

    private var hasEntry: Bool {
        guard let entry = entry else { return false }
        return !entry.gratitudes.isEmpty || entry.memory != nil || !entry.accomplishments.isEmpty || entry.journal != nil
    }

    private var backgroundColor: Color {
        if isSelected {
            return AppColors.primary
        } else if isToday {
            return AppColors.primary.opacity(0.12)  // hover color
        } else if hasEntry {
            return AppColors.primary.opacity(0.12)  // hover color
        } else {
            return AppColors.Background.secondaryDark
        }
    }

    private var borderColor: Color {
        if isSelected {
            return AppColors.primary
        } else if isToday {
            return AppColors.primary
        } else if hasEntry {
            return AppColors.primary
        } else {
            return AppColors.Border.subtle
        }
    }

    private var borderWidth: CGFloat {
        if isSelected || isToday {
            return isIPad ? 2 : 1.5
        } else if hasEntry {
            return isIPad ? 1 : 0.5
        } else {
            return 1
        }
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return AppColors.primary
        } else if !isCurrentMonth {
            return AppColors.Text.muted
        } else {
            return AppColors.Text.primary
        }
    }

    private var dayString: String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
}

#Preview {
    NavigationStack {
        CalendarView()
            .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
            .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
    }
}
