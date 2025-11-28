import SwiftUI
import SwiftData

enum FilterType: String, CaseIterable {
    case all = "All"
    case gratitude = "Gratitude"
    case memory = "Memories"
    case accomplishments = "Achievements"
    case journal = "Journal"

    var emoji: String {
        switch self {
        case .all: return "📚"
        case .gratitude: return "heart.fill"
        case .memory: return "sparkles"
        case .accomplishments: return "trophy.fill"
        case .journal: return "book.fill"
        }
    }
}

enum SortType: String, CaseIterable {
    case dateDesc = "Newest"
    case dateAsc = "Oldest"
    case contentLength = "Content"

    var emoji: String {
        switch self {
        case .dateDesc: return "calendar"
        case .dateAsc: return "arrow.counterclockwise"
        case .contentLength: return "chart.bar.fill"
        }
    }
}

enum DateFilterType: String, CaseIterable {
    case allTime = "All Time"
    case lastWeek = "Last Week"
    case lastMonth = "Last Month"
    case last3Months = "Last 3 Months"
}

struct ExploreView: View {
    @EnvironmentObject private var journalService: JournalService
    @Query(sort: \Entry.date, order: .reverse) private var allEntries: [Entry]

    @State private var motivationalQuote: String = ""
    @State private var filterType: FilterType = .all
    @State private var sortType: SortType = .dateDesc
    @State private var dateFilterType: DateFilterType = .allTime
    @State private var isLoading = true

    // Computed properties for filtering and statistics
    private var dateFilteredEntries: [Entry] {
        let now = Date()
        let calendar = Calendar.current

        switch dateFilterType {
        case .allTime:
            return allEntries
        case .lastWeek:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return allEntries.filter { $0.date >= weekAgo }
        case .lastMonth:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return allEntries.filter { $0.date >= monthAgo }
        case .last3Months:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!
            return allEntries.filter { $0.date >= threeMonthsAgo }
        }
    }

    private var filteredEntries: [Entry] {
        var entries = dateFilteredEntries

        // Apply content filter
        switch filterType {
        case .all:
            break
        case .gratitude:
            entries = entries.filter { !$0.gratitudes.isEmpty }
        case .memory:
            entries = entries.filter { $0.memory != nil && !$0.memory!.isEmpty }
        case .accomplishments:
            entries = entries.filter { !$0.accomplishments.isEmpty }
        case .journal:
            entries = entries.filter { $0.journal != nil && !$0.journal!.isEmpty }
        }

        // Apply sort
        switch sortType {
        case .dateDesc:
            entries = entries.sorted { $0.date > $1.date }
        case .dateAsc:
            entries = entries.sorted { $0.date < $1.date }
        case .contentLength:
            entries = entries.sorted { $0.wordCount > $1.wordCount }
        }

        return entries
    }

    private var statistics: (totalEntries: Int, totalGratitudes: Int, memoriesCount: Int, totalAccomplishments: Int, avgWordsPerJournal: Int) {
        let entries = dateFilteredEntries
        let totalEntries = entries.count
        let totalGratitudes = entries.reduce(0) { $0 + $1.gratitudes.count }
        let memoriesCount = entries.filter { $0.memory != nil && !$0.memory!.isEmpty }.count
        let totalAccomplishments = entries.reduce(0) { $0 + $1.accomplishments.count }

        let journalEntries = entries.filter { $0.journal != nil && !$0.journal!.isEmpty }
        let totalWords = journalEntries.reduce(0) { $0 + $1.wordCount }
        let avgWords = journalEntries.isEmpty ? 0 : totalWords / journalEntries.count

        return (totalEntries, totalGratitudes, memoriesCount, totalAccomplishments, avgWords)
    }

    var body: some View {
        GeometryReader { geometry in
            let isIPad = isIPadDevice(geometry)
            let columns = isIPad ? 2 : 1

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerView

                    // Statistics
                    statisticsView(isIPad: isIPad)

                    // Word Cloud
                    if !filteredEntries.isEmpty {
                        WordCloudView(entries: filteredEntries)
                    }

                    // Date Filter
                    dateFilterView(isIPad: isIPad)

                    // Content Filters and Sort
                    filtersAndSortView(isIPad: isIPad)

                    // Results count
                    Text("\(filteredEntries.count) \(filteredEntries.count == 1 ? "entry" : "entries")")
                        .font(.caption)
                        .foregroundStyle(AppColors.Text.muted)
                        .padding(.bottom, 8)

                    // Entry Cards
                    if filteredEntries.isEmpty {
                        emptyStateView
                    } else {
                        entryCardsView(isIPad: isIPad, columns: columns)
                    }
                }
                .padding(isIPad ? 24 : 20)
                .padding(.bottom, 100)
            }
            .frame(maxWidth: isIPad ? 1200 : .infinity)
            .frame(maxWidth: .infinity)
            .background(AppColors.Background.mainLight)
            .overlay(alignment: .bottom) {
                if !filteredEntries.isEmpty {
                    copyButton(isIPad: isIPad)
                }
            }
        }
        .onAppear {
            motivationalQuote = QuoteService.shared.randomMotivationalQuote()
            isLoading = false
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Explore Your Journey")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(AppColors.Text.primary)
                .multilineTextAlignment(.center)

            Text("\"\(motivationalQuote)\"")
                .font(.callout)
                .italic()
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Statistics

    private func statisticsView(isIPad: Bool) -> some View {
        let stats = statistics

        return Group {
            if isIPad {
                HStack(spacing: 12) {
                    StatCard(title: "Total Entries", value: "\(stats.totalEntries)", emoji: "📔", color: AppColors.EntryType.journal)
                    StatCard(title: "Gratitudes", value: "\(stats.totalGratitudes)", emoji: "🙏", color: AppColors.EntryType.gratitude)
                    StatCard(title: "Memories", value: "\(stats.memoriesCount)", emoji: "💫", color: AppColors.EntryType.memory)
                    StatCard(title: "Achievements", value: "\(stats.totalAccomplishments)", emoji: "🏆", color: AppColors.EntryType.accomplishment)
                    StatCard(title: "Avg. Words", value: stats.avgWordsPerJournal > 0 ? "\(stats.avgWordsPerJournal)" : "—", emoji: "✍️", color: AppColors.primary)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatCard(title: "Total Entries", value: "\(stats.totalEntries)", emoji: "📔", color: AppColors.EntryType.journal)
                        StatCard(title: "Gratitudes", value: "\(stats.totalGratitudes)", emoji: "🙏", color: AppColors.EntryType.gratitude)
                        StatCard(title: "Memories", value: "\(stats.memoriesCount)", emoji: "💫", color: AppColors.EntryType.memory)
                        StatCard(title: "Achievements", value: "\(stats.totalAccomplishments)", emoji: "🏆", color: AppColors.EntryType.accomplishment)
                        StatCard(title: "Avg. Words", value: stats.avgWordsPerJournal > 0 ? "\(stats.avgWordsPerJournal)" : "—", emoji: "✍️", color: AppColors.primary)
                    }
                }
            }
        }
    }

    // MARK: - Date Filter

    private func dateFilterView(isIPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time Period")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.Text.primary)

            if isIPad {
                HStack(spacing: 12) {
                    ForEach(DateFilterType.allCases, id: \.self) { type in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dateFilterType = type
                            }
                        } label: {
                            Text(type.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(dateFilterType == type ? AppColors.Background.secondaryDark : AppColors.Text.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(dateFilterType == type ? AppColors.primary : AppColors.Background.elevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(dateFilterType == type ? AppColors.primary : AppColors.Border.subtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(DateFilterType.allCases, id: \.self) { type in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dateFilterType = type
                            }
                        } label: {
                            Text(type.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(dateFilterType == type ? AppColors.Background.secondaryDark : AppColors.Text.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(dateFilterType == type ? AppColors.primary : AppColors.Background.elevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(dateFilterType == type ? AppColors.primary : AppColors.Border.subtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    // MARK: - Filters and Sort

    private func filtersAndSortView(isIPad: Bool) -> some View {
        VStack(spacing: 12) {
            if isIPad {
                HStack(spacing: 12) {
                    ForEach(FilterType.allCases, id: \.self) { type in
                        filterButton(type: type)
                    }

                    Spacer()

                    sortButton
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterType.allCases, id: \.self) { type in
                            filterButton(type: type)
                        }
                    }
                }

                sortButton
            }
        }
    }

    private func filterButton(type: FilterType) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                filterType = type
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: type.emoji)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(filterType == type ? AppColors.Background.secondaryDark : AppColors.Text.secondary)

                Text(type.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(filterType == type ? AppColors.Background.secondaryDark : AppColors.Text.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(filterType == type ? AppColors.primary : AppColors.Background.elevated)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(filterType == type ? AppColors.primary : AppColors.Border.subtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var sortButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let currentIndex = SortType.allCases.firstIndex(of: sortType) ?? 0
                let nextIndex = (currentIndex + 1) % SortType.allCases.count
                sortType = SortType.allCases[nextIndex]
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: sortType.emoji)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.Text.secondary)

                Text(sortType.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.Text.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppColors.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColors.Border.subtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Entry Cards

    private func entryCardsView(isIPad: Bool, columns: Int) -> some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: columns)

        return LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(filteredEntries) { entry in
                EntryCard(entry: entry)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.Text.muted)

            Text("No entries found")
                .font(.headline)
                .foregroundStyle(AppColors.Text.primary)

            Text("No entries match the selected filter")
                .font(.subheadline)
                .foregroundStyle(AppColors.Text.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Copy Button

    private func copyButton(isIPad: Bool) -> some View {
        Button {
            copyFilteredEntries()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 16, weight: .semibold))

                Text("Copy \(filteredEntries.count) \(filteredEntries.count == 1 ? "Entry" : "Entries")")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(AppColors.Background.secondaryDark)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(AppColors.primary)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.bottom, isIPad ? 32 : 24)
    }

    // MARK: - Helpers

    private func isIPadDevice(_ geometry: GeometryProxy) -> Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return geometry.size.width > 768
        #endif
    }

    private func copyFilteredEntries() {
        var exportText = ""

        for entry in filteredEntries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let formattedDate = dateFormatter.string(from: entry.date)

            exportText += "=== \(formattedDate) ===\n\n"

            if let journal = entry.journal, !journal.isEmpty {
                exportText += "Journal:\n\(journal)\n\n"
            }

            if !entry.gratitudes.isEmpty {
                exportText += "Gratitude:\n\(entry.gratitudes.map { "• \($0)" }.joined(separator: "\n"))\n\n"
            }

            if let memory = entry.memory, !memory.isEmpty {
                exportText += "Memory:\n\(memory)\n\n"
            }

            if !entry.accomplishments.isEmpty {
                exportText += "Accomplishments:\n\(entry.accomplishments.map { "• \($0)" }.joined(separator: "\n"))\n\n"
            }

            exportText += "---\n\n"
        }

        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(exportText, forType: .string)
        #else
        UIPasteboard.general.string = exportText
        #endif
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let emoji: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 28))

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColors.Text.primary)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 120, height: 110)
        .padding()
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct EntryCard: View {
    let entry: Entry

    private var contentSections: [(type: String, emoji: String, title: String, content: Any)] {
        var sections: [(String, String, String, Any)] = []

        if !entry.gratitudes.isEmpty {
            sections.append(("gratitudes", "heart.fill", "Gratitude", entry.gratitudes))
        }
        if let memory = entry.memory, !memory.isEmpty {
            sections.append(("memory", "sparkles", "Memory", memory))
        }
        if !entry.accomplishments.isEmpty {
            sections.append(("accomplishments", "trophy.fill", "Accomplishments", entry.accomplishments))
        }
        if let journal = entry.journal, !journal.isEmpty {
            sections.append(("journal", "book.fill", "Journal", journal))
        }

        return sections
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.Text.primary)

                    Text(timeAgo(from: entry.date))
                        .font(.caption)
                        .foregroundStyle(AppColors.Text.muted)
                }

                Spacer()

                HStack(spacing: 6) {
                    ForEach(contentSections, id: \.type) { section in
                        Image(systemName: section.emoji)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.Text.muted)
                            .padding(6)
                            .background(AppColors.Background.elevated.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
            .padding(16)
            .background(AppColors.Background.elevated)

            Divider()
                .background(AppColors.Border.subtle)

            // Content
            VStack(alignment: .leading, spacing: 16) {
                ForEach(contentSections, id: \.type) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: section.emoji)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.primary)

                            Text(section.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.Text.primary)
                        }

                        if let items = section.content as? [String] {
                            ForEach(items, id: \.self) { item in
                                Text("• \(item)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.Text.secondary)
                                    .lineLimit(2)
                            }
                        } else if let text = section.content as? String {
                            Text(text)
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.Text.secondary)
                                .lineLimit(3)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(16)
        }
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    ExploreView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
}
