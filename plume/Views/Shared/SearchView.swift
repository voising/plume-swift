import SwiftUI
import SwiftData

struct SearchResult: Identifiable {
    let id: String
    let type: SearchResultType
    let date: Date
    let title: String
    let content: String
    let matchedText: String

    enum SearchResultType: String {
        case gratitude = "Gratitude"
        case memory = "Memory"
        case accomplishment = "Accomplishment"
        case journal = "Journal"

        var icon: String {
            switch self {
            case .gratitude: return "heart.fill"
            case .memory: return "sparkles"
            case .accomplishment: return "trophy.fill"
            case .journal: return "book.fill"
            }
        }

        var emoji: String {
            switch self {
            case .gratitude: return "🙏"
            case .memory: return "💫"
            case .accomplishment: return "🏆"
            case .journal: return "📔"
            }
        }
    }
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Entry.date, order: .reverse) private var allEntries: [Entry]

    @State private var searchQuery = ""
    @State private var isLoading = false
    @FocusState private var searchFieldFocused: Bool

    private var searchResults: [SearchResult] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }

        let searchTerm = searchQuery.lowercased()
        var results: [SearchResult] = []

        for entry in allEntries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let formattedDate = dateFormatter.string(from: entry.date)

            // Search gratitudes
            for (index, gratitude) in entry.gratitudes.enumerated() {
                if gratitude.lowercased().contains(searchTerm) {
                    results.append(SearchResult(
                        id: "\(entry.id.uuidString)-gratitude-\(index)",
                        type: .gratitude,
                        date: entry.date,
                        title: "Gratitude • \(formattedDate)",
                        content: gratitude,
                        matchedText: gratitude
                    ))
                }
            }

            // Search memory
            if let memory = entry.memory, !memory.isEmpty,
               memory.lowercased().contains(searchTerm) {
                results.append(SearchResult(
                    id: "\(entry.id.uuidString)-memory",
                    type: .memory,
                    date: entry.date,
                    title: "Memory • \(formattedDate)",
                    content: memory,
                    matchedText: memory
                ))
            }

            // Search accomplishments
            for (index, accomplishment) in entry.accomplishments.enumerated() {
                if accomplishment.lowercased().contains(searchTerm) {
                    results.append(SearchResult(
                        id: "\(entry.id.uuidString)-accomplishment-\(index)",
                        type: .accomplishment,
                        date: entry.date,
                        title: "Accomplishment • \(formattedDate)",
                        content: accomplishment,
                        matchedText: accomplishment
                    ))
                }
            }

            // Search journal
            if let journal = entry.journal, !journal.isEmpty,
               journal.lowercased().contains(searchTerm) {
                // Find the sentence containing the match
                let sentences = journal.components(separatedBy: CharacterSet(charactersIn: ".!?"))
                let matchingSentence = sentences.first { $0.lowercased().contains(searchTerm) }
                let preview = matchingSentence?.trimmingCharacters(in: .whitespaces).prefix(100) ?? journal.prefix(100)

                results.append(SearchResult(
                    id: "\(entry.id.uuidString)-journal",
                    type: .journal,
                    date: entry.date,
                    title: "Journal • \(formattedDate)",
                    content: journal,
                    matchedText: String(preview) + (preview.count < journal.count ? "..." : "")
                ))
            }
        }

        // Sort by date (newest first), with exact matches prioritized
        return results.sorted { a, b in
            let aExact = a.content.lowercased() == searchTerm
            let bExact = b.content.lowercased() == searchTerm

            if aExact && !bExact { return true }
            if !aExact && bExact { return false }

            return a.date > b.date
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.Text.muted)

                    TextField("Search your journal entries...", text: $searchQuery)
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.Text.primary)
                        .focused($searchFieldFocused)
                        .submitLabel(.search)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.Background.elevated)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColors.Border.subtle, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Result count
                if !searchQuery.isEmpty {
                    Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(AppColors.Text.secondary)
                        .padding(.bottom, 12)
                }

                Divider()
                    .background(AppColors.Border.subtle)

                // Content
                if isLoading {
                    loadingState
                } else if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                    emptySearchState
                } else if searchResults.isEmpty {
                    noResultsState
                } else {
                    resultsListView
                }
            }
            .background(AppColors.Background.mainLight)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }
            .onAppear {
                searchFieldFocused = true
            }
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(AppColors.primary)

            Text("Loading entries...")
                .font(.body)
                .foregroundStyle(AppColors.Text.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty Search State

    private var emptySearchState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.Text.muted)
                .opacity(0.5)

            Text("Search your journal")
                .font(.headline)
                .foregroundStyle(AppColors.Text.primary)

            Text("Find entries by searching gratitudes, memories, accomplishments, and journal text")
                .font(.caption)
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - No Results State

    private var noResultsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.Text.muted)
                .opacity(0.5)

            Text("No results found")
                .font(.headline)
                .foregroundStyle(AppColors.Text.primary)

            Text("Try different keywords or check your spelling")
                .font(.caption)
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Results List

    private var resultsListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(searchResults) { result in
                    SearchResultRow(result: result, searchQuery: searchQuery)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let result: SearchResult
    let searchQuery: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack(spacing: 12) {
                Image(systemName: result.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.Text.primary)

                    Text(result.type.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppColors.Text.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.Background.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }

                Spacer()
            }

            // Content with highlighted text
            highlightedText(result.matchedText, query: searchQuery)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.Text.secondary)
                .lineLimit(3)
        }
        .padding(12)
        .background(AppColors.Background.secondaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }

    // MARK: - Text Highlighting

    @ViewBuilder
    private func highlightedText(_ text: String, query: String) -> some View {
        if query.isEmpty {
            Text(text)
        } else {
            let parts = splitTextByQuery(text, query: query)
            parts.reduce(Text("")) { result, part in
                if part.lowercased() == query.lowercased() {
                    result + Text(part)
                        .fontWeight(.semibold)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "FEF08A"))
                                .padding(.horizontal, -2)
                        )
                } else {
                    result + Text(part)
                }
            }
        }
    }

    private func splitTextByQuery(_ text: String, query: String) -> [String] {
        guard !query.isEmpty else { return [text] }

        var parts: [String] = []
        var remainingText = text
        let queryLower = query.lowercased()

        while !remainingText.isEmpty {
            if let range = remainingText.lowercased().range(of: queryLower) {
                // Add text before match
                let beforeMatch = String(remainingText[..<range.lowerBound])
                if !beforeMatch.isEmpty {
                    parts.append(beforeMatch)
                }

                // Add matched text
                let match = String(remainingText[range])
                parts.append(match)

                // Continue with remaining text
                remainingText = String(remainingText[range.upperBound...])
            } else {
                // No more matches, add remaining text
                parts.append(remainingText)
                break
            }
        }

        return parts
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
}
