import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showEntryDetail = false
    @State private var showSettings = false
    @State private var showSearch = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header
                monthHeader
                CalendarGrid(currentMonth: $currentMonth, selectedDate: $selectedDate) { date in
                    selectedDate = date
                    showEntryDetail = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.Background.mainLight)
        .navigationDestination(isPresented: $showEntryDetail) {
            EntryDetailView(date: selectedDate)
                .padding(.horizontal, 20)
                .background(AppColors.Background.mainLight)
        }
        .sheet(isPresented: $showSearch) {
            NavigationStack {
                ExploreView()
                    .navigationTitle("Search")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                showSearch = false
                            }
                        }
                    }
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showSettings = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Plume")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)
                
                Text("Reflect, grow, and track your journey")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            Spacer()
            HStack(spacing: 12) {
                HeaderActionButton(icon: "magnifyingglass") {
                    showSearch = true
                }
                HeaderActionButton(icon: "gearshape.fill") {
                    showSettings = true
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)
                    .padding(10)
                    .background(AppColors.Background.secondaryDark)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(currentMonth, format: .dateTime.month(.wide).year())
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)
                Text("Tap any day to open your entry")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)
                    .padding(10)
                    .background(AppColors.Background.secondaryDark)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

private struct CalendarGrid: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [Entry]
    
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    var onSelect: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.Text.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(daysInMonth()) { day in
                    if let actualDate = day.date {
                        DayCellView(
                            date: actualDate,
                            isSelected: Calendar.current.isDate(actualDate, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(actualDate),
                            isCurrentMonth: day.isWithinMonth,
                            entry: entry(for: actualDate)
                        )
                        .onTapGesture {
                            selectedDate = actualDate
                            onSelect(actualDate)
                        }
                    } else {
                        Color.clear
                            .frame(height: 64)
                    }
                }
            }
        }
    }
    
    private func entry(for date: Date) -> Entry? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
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

private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let isWithinMonth: Bool
}

private struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let entry: Entry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dayString)
                .font(.body.weight(isToday ? .semibold : .regular))
                .foregroundStyle(isToday ? .black.opacity(0.85) : AppColors.Text.primary)

            Spacer()

            HStack(spacing: 4) {
                if let entry, !isToday {
                    if !entry.gratitudes.isEmpty {
                        dot(color: AppColors.EntryType.gratitude)
                    }
                    if entry.memory != nil {
                        dot(color: AppColors.EntryType.memory)
                    }
                    if !entry.accomplishments.isEmpty {
                        dot(color: AppColors.EntryType.accomplishment)
                    }
                    if entry.journal != nil {
                        dot(color: AppColors.EntryType.journal)
                    }
                }
            }
        }
        .padding(12)
        .frame(height: 64, alignment: .topLeading)
        .background(isToday ? AppColors.primary : AppColors.Background.secondaryDark)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(hasEntry && !isToday ? AppColors.primary : AppColors.Border.subtle, lineWidth: hasEntry && !isToday ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(isCurrentMonth ? 1.0 : 0.35)
    }

    private var hasEntry: Bool {
        guard let entry else { return false }
        return !entry.gratitudes.isEmpty || entry.memory != nil || !entry.accomplishments.isEmpty || entry.journal != nil
    }
    
    private func dot(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
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
