import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var journalService: JournalService
    @EnvironmentObject private var aiService: AIService
    
    let date: Date
    @State private var entry: Entry?
    
    // Form states
    @State private var newGratitude = ""
    @State private var newAccomplishment = ""
    @State private var showZenMode = false
    @State private var isProcessingAI = false
    @State private var aiError: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Motivational Quote (only for today)
                if Calendar.current.isDateInToday(date) {
                    let quote = QuoteService.shared.dailyQuote()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\"\(quote.text)\"")
                            .font(.callout)
                            .italic()
                            .foregroundStyle(.secondary)
                        Text("— \(quote.author)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(AppColors.primary.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Header
                Text(date, format: .dateTime.weekday(.wide).month().day())
                    .font(.largeTitle)
                    .bold()
                
                if let entry = entry {
                    // Gratitude Section
                    VStack(alignment: .leading) {
                        Label("I am grateful for...", systemImage: "sun.max.fill")
                            .font(.headline)
                            .foregroundStyle(AppColors.EntryType.gratitude)
                        
                        ForEach(entry.gratitudes, id: \.self) { item in
                            Text("• \(item)")
                        }
                        
                        HStack {
                            TextField("Add gratitude...", text: $newGratitude)
                                .onSubmit {
                                    addGratitude()
                                }
                            Button(action: addGratitude) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newGratitude.isEmpty)
                        }
                    }
                    .padding()
                    .background(AppColors.Background.secondaryLight) // Should adapt to color scheme
                    .cornerRadius(12)
                    
                    // Memory Section
                    VStack(alignment: .leading) {
                        Label("Daily Memory", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(AppColors.EntryType.memory)
                        
                        TextField("What do you want to remember?", text: Binding(
                            get: { entry.memory ?? "" },
                            set: { entry.memory = $0 }
                        ), axis: .vertical)
                        .lineLimit(3...6)
                    }
                    .padding()
                    .background(AppColors.Background.secondaryLight)
                    .cornerRadius(12)
                    
                    // Accomplishments Section
                    VStack(alignment: .leading) {
                        Label("Accomplishments", systemImage: "rosette")
                            .font(.headline)
                            .foregroundStyle(AppColors.EntryType.accomplishment)
                        
                        ForEach(entry.accomplishments, id: \.self) { item in
                            Text("• \(item)")
                        }
                        
                        HStack {
                            TextField("Add accomplishment...", text: $newAccomplishment)
                                .onSubmit {
                                    addAccomplishment()
                                }
                            Button(action: addAccomplishment) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newAccomplishment.isEmpty)
                        }
                    }
                    .padding()
                    .background(AppColors.Background.secondaryLight)
                    .cornerRadius(12)
                    
                    // Journal Section
                    VStack(alignment: .leading) {
                        HStack {
                            Label("Journal", systemImage: "book.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.EntryType.journal)
                            
                            Spacer()
                            
                            // AI Tools Menu
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
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                            .disabled(entry.journal?.isEmpty ?? true)
                            
                            Button(action: { showZenMode = true }) {
                                Label("Zen Mode", systemImage: "arrow.up.left.and.arrow.down.right")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        MarkdownEditorView(text: Binding(
                            get: { entry.journal ?? "" },
                            set: { entry.journal = $0 }
                        ))
                    }
                    .padding()
                    .background(AppColors.Background.secondaryLight)
                    .cornerRadius(12)
                    #if os(iOS)
                    .fullScreenCover(isPresented: $showZenMode) {
                        ZenModeView(text: Binding(
                            get: { entry.journal ?? "" },
                            set: { entry.journal = $0 }
                        ), isPresented: $showZenMode)
                    }
                    #else
                    .sheet(isPresented: $showZenMode) {
                        ZenModeView(text: Binding(
                            get: { entry.journal ?? "" },
                            set: { entry.journal = $0 }
                        ), isPresented: $showZenMode)
                    }
                    #endif
                    
                    // Todos Section
                    TodoListView(date: date)
                    
                } else {
                    Button("Create Entry for Today") {
                        createEntry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .onAppear {
            loadEntry()
        }
        .onChange(of: date) { _, _ in
            loadEntry()
        }
    }
    
    private func loadEntry() {
        entry = journalService.getEntry(for: date)
    }
    
    private func createEntry() {
        entry = journalService.createEntry(date: date)
    }
    
    private func addGratitude() {
        guard !newGratitude.isEmpty else { return }
        entry?.gratitudes.append(newGratitude)
        newGratitude = ""
    }
    
    private func addAccomplishment() {
        guard !newAccomplishment.isEmpty else { return }
        entry?.accomplishments.append(newAccomplishment)
        newAccomplishment = ""
    }
    
    // MARK: - AI Functions
    
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
                    // Append summary at the end
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
                    // Append highlights at the end
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
