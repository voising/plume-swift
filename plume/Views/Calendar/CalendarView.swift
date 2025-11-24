import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        #if os(macOS)
        HSplitView {
            CalendarGridView(selectedDate: $selectedDate)
                .frame(minWidth: 400)
                .layoutPriority(1)
            
            EntryDetailView(date: selectedDate)
                .frame(minWidth: 300)
        }
        #else
        NavigationStack {
            CalendarGridView(selectedDate: $selectedDate)
                .navigationDestination(isPresented: Binding(
                    get: { true }, // This is tricky, we want to navigate on tap. 
                    // Better to use NavigationLink in the grid or .navigationDestination(for:)
                    set: { _ in }
                )) {
                    EntryDetailView(date: selectedDate)
                }
        }
        #endif
    }
}

struct CalendarGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [Entry]
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    @State private var selectedFilter: EntryFilter = .all
    
    enum EntryFilter: String, CaseIterable {
        case all = "All"
        case gratitude = "Gratitude"
        case memory = "Memory"
        case accomplishment = "Accomplishment"
    }
    
    // Grid configuration
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Text(currentMonth, format: .dateTime.month(.wide).year())
                    .font(.title2)
                    .bold()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
                
                Spacer()
                
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(EntryFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                
                Spacer()
                
                Button("Today") {
                    currentMonth = Date()
                    selectedDate = Date()
                }
            }
            .padding()
            
            // Days of week
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        // For iOS, we want navigation
                        #if os(iOS)
                        NavigationLink(value: date) {
                            DayCell(date: date, isSelected: isSelected(date), entry: entry(for: date), filter: selectedFilter)
                        }
                        .buttonStyle(.plain)
                        #else
                        DayCell(date: date, isSelected: isSelected(date), entry: entry(for: date), filter: selectedFilter)
                            .onTapGesture {
                                selectedDate = date
                            }
                        #endif
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding()
            #if os(iOS)
            .navigationDestination(for: Date.self) { date in
                EntryDetailView(date: date)
            }
            #endif
            
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isSelected(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func entry(for date: Date) -> Entry? {
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let entry: Entry?
    let filter: CalendarGridView.EntryFilter
    
    var matchesFilter: Bool {
        guard let entry = entry else { return false }
        
        switch filter {
        case .all:
            return true
        case .gratitude:
            return !entry.gratitudes.isEmpty
        case .memory:
            return entry.memory != nil
        case .accomplishment:
            return !entry.accomplishments.isEmpty
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.body)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? AppColors.primary : .primary)
                .frame(width: 30, height: 30)
                .background(isSelected ? AppColors.primary.opacity(0.2) : Color.clear)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.primary, lineWidth: isSelected ? 2 : 0)
                )
            
            // Indicators
            HStack(spacing: 2) {
                if let entry = entry {
                    if !entry.gratitudes.isEmpty {
                        Circle().fill(AppColors.EntryType.gratitude).frame(width: 4, height: 4)
                    }
                    if entry.memory != nil {
                        Circle().fill(AppColors.EntryType.memory).frame(width: 4, height: 4)
                    }
                    if !entry.accomplishments.isEmpty {
                        Circle().fill(AppColors.EntryType.accomplishment).frame(width: 4, height: 4)
                    }
                    if entry.journal != nil {
                        Circle().fill(AppColors.EntryType.journal).frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 45)
        .opacity(filter == .all || matchesFilter ? 1.0 : 0.3)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
}
