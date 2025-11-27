import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var journalService: JournalService
    @EnvironmentObject private var aiService: AIService
    
    let date: Date
    var showHeroHeader: Bool = true
    var autoCreateEntry: Bool = false
    
    @State private var entry: Entry?
    @State private var newGratitude = ""
    @State private var newAccomplishment = ""
    @State private var showZenMode = false
    @State private var isProcessingAI = false
    @State private var aiError: String?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if showHeroHeader {
                    header
                }
                
                if let _ = entry {
                    journalCard
                    gratitudeCard
                    memoryCard
                    accomplishmentsCard
                    TodoListView(date: date)
                } else {
                    Button {
                        createEntry()
                    } label: {
                        Text("Create Entry")
                            .font(.headline)
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            }
            .padding(.vertical, 24)
        }
        .padding(.horizontal, 2)
        .background(AppColors.Background.mainLight)
        .onAppear {
            loadEntry()
        }
        .onChange(of: date) { _, _ in
            loadEntry()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppColors.Text.primary)
            
            Text("Every day is a new beginning.")
                .font(.subheadline)
                .foregroundStyle(AppColors.Text.secondary)
        }
    }
    
    private var quoteCard: some View {
        let quote = QuoteService.shared.dailyQuote()
        return HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundStyle(AppColors.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(quote.text)\"")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.Text.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("— \(quote.author)")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.Background.secondaryDark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
    }
    
    private var journalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Journal", icon: "book.fill", color: AppColors.EntryType.journal)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { entry?.journal ?? "" },
                    set: { entry?.journal = $0 }
                ))
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(AppColors.Background.elevated)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppColors.Border.subtle, lineWidth: 1)
                )
                
                if (entry?.journal ?? "").isEmpty {
                    Text("Write about your day, thoughts, feelings...")
                        .foregroundStyle(AppColors.Text.secondary)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 18)
                }
            }
            
            HStack {
                Menu {
                    Button(action: { improveText() }) {
                        Label("Improve Language", systemImage: "wand.and.stars")
                    }
                    Button(action: { summarizeText() }) {
                        Label("Summarize", systemImage: "doc.text.magnifyingglass")
                    }
                    Button(action: { highlightImportant() }) {
                        Label("Highlight Important", systemImage: "star.fill")
                    }
                } label: {
                    Label("AI Tools", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                }
                .disabled(entry?.journal?.isEmpty ?? true)
                
                Divider()
                    .frame(height: 20)
                    .overlay(AppColors.Border.subtle)
                
                Button {
                    showZenMode = true
                } label: {
                    Label("Zen Mode", systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(.subheadline.weight(.semibold))
                }
                
                Spacer()
                
                Text("\(wordCount) words")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            .foregroundStyle(AppColors.Text.primary)
        }
        .plumeCard()
        #if os(iOS)
        .fullScreenCover(isPresented: $showZenMode) {
            ZenModeView(text: Binding(
                get: { entry?.journal ?? "" },
                set: { entry?.journal = $0 }
            ), isPresented: $showZenMode, date: date)
        }
        #else
        .sheet(isPresented: $showZenMode) {
            ZenModeView(text: Binding(
                get: { entry?.journal ?? "" },
                set: { entry?.journal = $0 }
            ), isPresented: $showZenMode, date: date)
        }
        #endif
    }
    
    private var gratitudeCard: some View {
        SectionCard(
            title: "Gratitude",
            icon: "heart.fill",
            color: AppColors.EntryType.gratitude,
            items: entry?.gratitudes ?? [],
            placeholder: "Add gratitude...",
            inputText: $newGratitude,
            onSubmit: addGratitude
        )
    }
    
    private var memoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Daily Memory", icon: "sparkles", color: AppColors.EntryType.memory)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { entry?.memory ?? "" },
                    set: { entry?.memory = $0 }
                ))
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(AppColors.Background.elevated)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppColors.Border.subtle, lineWidth: 1)
                )
                
                if (entry?.memory ?? "").isEmpty {
                    Text("What moment do you want to remember?")
                        .foregroundStyle(AppColors.Text.secondary)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 18)
                }
            }
        }
        .plumeCard()
    }
    
    private var accomplishmentsCard: some View {
        SectionCard(
            title: "Accomplishments",
            icon: "trophy.fill",
            color: AppColors.EntryType.accomplishment,
            items: entry?.accomplishments ?? [],
            placeholder: "Add accomplishment...",
            inputText: $newAccomplishment,
            onSubmit: addAccomplishment
        )
    }
    
    private var wordCount: Int {
        entry?.journal?.split { $0.isWhitespace }.count ?? 0
    }
    
    private func loadEntry() {
        if let existing = journalService.getEntry(for: date) {
            entry = existing
        } else if autoCreateEntry {
            entry = journalService.createEntry(date: date)
        } else {
            entry = nil
        }
    }
    
    private func createEntry() {
        entry = journalService.createEntry(date: date)
    }
    
    private func addGratitude() {
        guard !newGratitude.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        entry?.gratitudes.append(newGratitude)
        newGratitude = ""
    }
    
    private func addAccomplishment() {
        guard !newAccomplishment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        entry?.accomplishments.append(newAccomplishment)
        newAccomplishment = ""
    }
    
    private func improveText() {
        guard let journal = entry?.journal, !journal.isEmpty else { return }
        
        Task {
            isProcessingAI = true
            aiError = nil
            
            do {
                let improved = try await aiService.improveText(journal)
                await MainActor.run {
                    entry?.journal = improved
                    isProcessingAI = false
                }
            } catch {
                await MainActor.run {
                    aiError = "Failed to improve text: \(error.localizedDescription)"
                    isProcessingAI = false
                }
            }
        }
    }
    
    private func summarizeText() {
        guard let journal = entry?.journal, !journal.isEmpty else { return }
        
        Task {
            isProcessingAI = true
            aiError = nil
            
            do {
                let summary = try await aiService.summarize(journal)
                await MainActor.run {
                    entry?.journal = (entry?.journal ?? "") + "\n\n---\n**Summary:**\n" + summary
                    isProcessingAI = false
                }
            } catch {
                await MainActor.run {
                    aiError = "Failed to summarize: \(error.localizedDescription)"
                    isProcessingAI = false
                }
            }
        }
    }
    
    private func highlightImportant() {
        guard let journal = entry?.journal, !journal.isEmpty else { return }
        
        Task {
            isProcessingAI = true
            aiError = nil
            
            do {
                let highlighted = try await aiService.generateResponse(prompt: "Extract and highlight the most important points from this journal entry:\n\n\(journal)")
                await MainActor.run {
                    entry?.journal = (entry?.journal ?? "") + "\n\n---\n**Key Points:**\n" + highlighted
                    isProcessingAI = false
                }
            } catch {
                await MainActor.run {
                    aiError = "Failed to highlight: \(error.localizedDescription)"
                    isProcessingAI = false
                }
            }
        }
    }
}

private struct SectionHeader: View {
    var title: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.system(size: 18, weight: .semibold))
                )
            
            Text(title)
                .font(.headline)
                .foregroundStyle(AppColors.Text.primary)
            
            Spacer()
        }
    }
}

private struct SectionCard: View {
    var title: String
    var icon: String
    var color: Color
    var items: [String]
    var placeholder: String
    @Binding var inputText: String
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: title, icon: icon, color: color)
            
            if items.isEmpty {
                Text("Tap + to capture a moment.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Text.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(color)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            
                            Text(item)
                                .foregroundStyle(AppColors.Text.primary)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                TextField(placeholder, text: $inputText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppColors.Text.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.Background.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                Button(action: onSubmit) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
                        .frame(width: 44, height: 44)
                        .background(color)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
            }
        }
        .plumeCard()
    }
}
