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
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search your memories...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(AppColors.Background.secondaryLight)
                .cornerRadius(12)
                
                if searchText.isEmpty {
                    // Statistics Cards
                    HStack(spacing: 16) {
                        StatCard(title: "Total Entries", value: "\(entries.count)", icon: "doc.text.fill", color: .blue)
                        StatCard(title: "Current Streak", value: "\(journalService.calculateStreak())", icon: "flame.fill", color: .orange)
                        StatCard(title: "Words Written", value: "\(journalService.totalWordCount())", icon: "text.quote", color: .purple)
                    }
                    
                    // Charts
                    VStack(alignment: .leading) {
                        Text("Activity")
                            .font(.headline)
                        
                        Chart {
                            ForEach(entries) { entry in
                                BarMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Words", entry.wordCount)
                                )
                                .foregroundStyle(AppColors.primary)
                            }
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(AppColors.Background.secondaryLight)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text("Breakdown")
                            .font(.headline)
                        
                        Chart {
                            SectorMark(
                                angle: .value("Count", entries.filter { !$0.gratitudes.isEmpty }.count),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(AppColors.EntryType.gratitude)
                            .annotation(position: .overlay) { Text("Gratitude").font(.caption) }
                            
                            SectorMark(
                                angle: .value("Count", entries.filter { $0.memory != nil }.count),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(AppColors.EntryType.memory)
                            .annotation(position: .overlay) { Text("Memory").font(.caption) }
                            
                            SectorMark(
                                angle: .value("Count", entries.filter { !$0.accomplishments.isEmpty }.count),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(AppColors.EntryType.accomplishment)
                            .annotation(position: .overlay) { Text("Wins").font(.caption) }
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(AppColors.Background.secondaryLight)
                    .cornerRadius(12)
                    
                } else {
                    // Search Results
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(searchResults) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                if let memory = entry.memory, memory.localizedCaseInsensitiveContains(searchText) {
                                    Text(memory)
                                        .lineLimit(2)
                                }
                                if let journal = entry.journal, journal.localizedCaseInsensitiveContains(searchText) {
                                    Text(journal)
                                        .lineLimit(2)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.Background.secondaryLight)
                            .cornerRadius(8)
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
        .background(AppColors.Background.secondaryLight)
        .cornerRadius(12)
    }
}

#Preview {
    ExploreView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
}
