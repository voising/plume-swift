import SwiftUI
import SwiftData
import Charts

struct ExploreView: View {
    @EnvironmentObject private var journalService: JournalService
    @Query(sort: \Entry.date, order: .reverse) private var entries: [Entry]
    
    @State private var searchText = ""
    
var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.Text.secondary)
                    TextField("Search your memories...", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(AppColors.Text.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppColors.Background.secondaryDark)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                if searchText.isEmpty {
                    HStack(spacing: 16) {
                        StatCard(title: "Total Entries", value: "\(entries.count)", icon: "doc.text.fill", color: AppColors.EntryType.journal)
                        StatCard(title: "Current Streak", value: "\(journalService.calculateStreak())", icon: "flame.fill", color: AppColors.EntryType.accomplishment)
                        StatCard(title: "Words Written", value: "\(journalService.totalWordCount())", icon: "text.justify", color: AppColors.EntryType.memory)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity")
                            .font(.headline)
                            .foregroundStyle(AppColors.Text.primary)
                        
                        Chart {
                            ForEach(entries) { entry in
                                BarMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Words", entry.wordCount)
                                )
                                .foregroundStyle(AppColors.primary)
                            }
                        }
                        .frame(height: 220)
                        .chartXScale(domain: .automatic(includesZero: false))
                    }
                    .plumeCard()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breakdown")
                            .font(.headline)
                            .foregroundStyle(AppColors.Text.primary)
                        
                        Chart {
                            SectorMark(
                                angle: .value("Count", entries.filter { !$0.gratitudes.isEmpty }.count),
                                innerRadius: .ratio(0.55),
                                angularInset: 2
                            )
                            .foregroundStyle(AppColors.EntryType.gratitude)
                            .cornerRadius(6)
                            
                            SectorMark(
                                angle: .value("Count", entries.filter { $0.memory != nil }.count),
                                innerRadius: .ratio(0.55),
                                angularInset: 2
                            )
                            .foregroundStyle(AppColors.EntryType.memory)
                            
                            SectorMark(
                                angle: .value("Count", entries.filter { !$0.accomplishments.isEmpty }.count),
                                innerRadius: .ratio(0.55),
                                angularInset: 2
                            )
                            .foregroundStyle(AppColors.EntryType.accomplishment)
                        }
                        .frame(height: 220)
                    }
                    .plumeCard()
                    
                } else {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(searchResults) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.Text.secondary)
                                
                                if let memory = entry.memory, memory.localizedCaseInsensitiveContains(searchText) {
                                    Text(memory)
                                        .foregroundStyle(AppColors.Text.primary)
                                        .lineLimit(2)
                                }
                                if let journal = entry.journal, journal.localizedCaseInsensitiveContains(searchText) {
                                    Text(journal)
                                        .foregroundStyle(AppColors.Text.primary)
                                        .lineLimit(2)
                                }
                            }
                            .padding()
                            .background(AppColors.Background.secondaryDark)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(AppColors.Border.subtle, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var searchResults: [Entry] {
        entries.filter { entry in
            (entry.memory?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (entry.journal?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            entry.gratitudes.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            entry.accomplishments.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
    }
}

#Preview {
    ExploreView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
}
