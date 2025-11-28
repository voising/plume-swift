import SwiftUI
import SwiftData

struct TodayHeroView: View {
    let date: Date

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var journalService: JournalService
    @EnvironmentObject private var aiService: AIService

    @State private var entry: Entry?
    @State private var showZenMode = false
    @State private var showPreview = false
    @State private var motivationalQuote: String = ""
    @State private var isProcessingAI = false
    @State private var aiError: String?

    // Helper computed properties for binding
    private var gratitudeBinding: Binding<String> {
        Binding(
            get: { entry?.gratitudes.joined(separator: "\n") ?? "" },
            set: { newValue in
                entry?.gratitudes = newValue
                    .components(separatedBy: "\n")
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            }
        )
    }

    private var memoryBinding: Binding<String> {
        Binding(
            get: { entry?.memory ?? "" },
            set: { entry?.memory = $0 }
        )
    }

    private var accomplishmentsBinding: Binding<String> {
        Binding(
            get: { entry?.accomplishments.joined(separator: "\n") ?? "" },
            set: { newValue in
                entry?.accomplishments = newValue
                    .components(separatedBy: "\n")
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            }
        )
    }

    private var journalBinding: Binding<String> {
        Binding(
            get: { entry?.journal ?? "" },
            set: { entry?.journal = $0 }
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 24) {
                // Header with date and motivational quote
                VStack(spacing: 8) {
                    Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppColors.Text.primary)
                        .multilineTextAlignment(.center)

                    Text(motivationalQuote)
                        .font(.callout)
                        .italic()
                        .foregroundStyle(AppColors.Text.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                if entry != nil {
                    VStack(alignment: .leading, spacing: 24) {
                        // Journal Card - Full Width, Prominent
                        journalCard

                        // Three Field Cards - Horizontal on iPad, Vertical on iPhone
                        fieldsContainer
                    }
                    .padding(.horizontal, contentPadding)
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
                    .padding(.horizontal, contentPadding)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: maxContentWidth)
        .frame(maxWidth: .infinity) // Center the content
        .background(AppColors.Background.mainLight)
        .onAppear {
            loadEntry()
            motivationalQuote = QuoteService.shared.randomMotivationalQuote()
        }
        .onChange(of: date) { _, _ in
            loadEntry()
        }
    }

    // MARK: - Journal Card

    private var journalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Journal Header
            HStack(spacing: 10) {
                Image(systemName: "book.fill")
                    .font(.system(size: isIPad ? 18 : 20, weight: .semibold))
                    .foregroundStyle(AppColors.EntryType.journal)

                Text("Journal")
                    .font(.system(size: isIPad ? 17 : 16, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)

                Spacer()

                if !(entry?.journal ?? "").isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showPreview.toggle()
                        }
                    } label: {
                        Text(showPreview ? "Edit" : "Preview")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.Text.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.Background.elevated.opacity(0.6))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.bottom, 4)

            // Journal Input/Preview
            ZStack(alignment: .topLeading) {
                if showPreview {
                    ScrollView {
                        MarkdownText(entry?.journal ?? "")
                            .padding(.vertical, 8)
                    }
                    .frame(minHeight: journalMinHeight)
                } else {
                    TextEditor(text: journalBinding)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: isIPad ? 15 : 14))
                        .lineSpacing(isIPad ? 22 - 15 : 20 - 14)
                        .foregroundStyle(AppColors.Text.primary)
                        .frame(minHeight: journalMinHeight)
                        .onTapGesture {
                            // Enter zen mode when tapping journal
                            showZenMode = true
                        }

                    if (entry?.journal ?? "").isEmpty {
                        Text("Write about your day, thoughts, feelings...")
                            .font(.system(size: isIPad ? 15 : 14))
                            .foregroundStyle(AppColors.Text.muted)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .padding(isIPad ? 24 : 16)
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: isIPad ? 20 : 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: isIPad ? 20 : 16, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        #if os(iOS)
        .fullScreenCover(isPresented: $showZenMode) {
            ZenModeView(text: journalBinding, isPresented: $showZenMode, date: date)
        }
        #else
        .sheet(isPresented: $showZenMode) {
            ZenModeView(text: journalBinding, isPresented: $showZenMode, date: date)
        }
        #endif
    }

    // MARK: - Fields Container

    private var fieldsContainer: some View {
        Group {
            if isIPad {
                // Horizontal layout on iPad
                HStack(alignment: .top, spacing: 16) {
                    FieldCard(
                        label: "Gratitude",
                        icon: "heart.fill",
                        color: AppColors.EntryType.gratitude,
                        placeholder: "What are you grateful for today?",
                        value: gratitudeBinding,
                        initiallyExpanded: true
                    )

                    FieldCard(
                        label: "Memory",
                        icon: "sparkles",
                        color: AppColors.EntryType.memory,
                        placeholder: "A moment worth remembering?",
                        value: memoryBinding,
                        initiallyExpanded: true
                    )

                    FieldCard(
                        label: "Accomplishments",
                        icon: "trophy.fill",
                        color: AppColors.EntryType.accomplishment,
                        placeholder: "What did you accomplish today?",
                        value: accomplishmentsBinding,
                        initiallyExpanded: true
                    )
                }
            } else {
                // Vertical layout on iPhone
                VStack(alignment: .leading, spacing: 12) {
                    FieldCard(
                        label: "Gratitude",
                        icon: "heart.fill",
                        color: AppColors.EntryType.gratitude,
                        placeholder: "What are you grateful for today?",
                        value: gratitudeBinding
                    )

                    FieldCard(
                        label: "Memory",
                        icon: "sparkles",
                        color: AppColors.EntryType.memory,
                        placeholder: "A moment worth remembering?",
                        value: memoryBinding
                    )

                    FieldCard(
                        label: "Accomplishments",
                        icon: "trophy.fill",
                        color: AppColors.EntryType.accomplishment,
                        placeholder: "What did you accomplish today?",
                        value: accomplishmentsBinding
                    )
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var isIPad: Bool {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad
        #else
        false
        #endif
    }

    private var contentPadding: CGFloat {
        isIPad ? 24 : 20
    }

    private var maxContentWidth: CGFloat {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 900
        }
        #endif
        return 800
    }

    private var journalMinHeight: CGFloat {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 200
        }
        #endif
        return 120
    }

    // MARK: - Data Methods

    private func loadEntry() {
        if let existing = journalService.getEntry(for: date) {
            entry = existing
        } else {
            entry = journalService.createEntry(date: date)
        }
    }

    private func createEntry() {
        entry = journalService.createEntry(date: date)
    }
}

// MARK: - Markdown Text View

private struct MarkdownText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(.init(text))
            .font(.system(size: 15))
            .foregroundStyle(AppColors.Text.primary)
    }
}

#Preview {
    TodayHeroView(date: Date())
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
        .environmentObject(AIService())
}
