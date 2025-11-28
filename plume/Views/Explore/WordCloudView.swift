import SwiftUI

struct WordCloudItem: Identifiable {
    let id = UUID()
    let text: String
    let count: Int
    let weight: Double
}

struct WordCloudView: View {
    let entries: [Entry]
    let maxWords: Int = 30

    private var wordCloudItems: [WordCloudItem] {
        generateWordCloud(from: entries, maxWords: maxWords)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .center, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.primary)

                    Text("Word Cloud")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.Text.primary)
                }

                Text("Most frequent words from \(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            // Word Cloud
            if wordCloudItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "pencil")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.Text.muted)

                    Text("No words to display")
                        .font(.headline)
                        .foregroundStyle(AppColors.Text.primary)

                    Text("Start writing to see your word patterns!")
                        .font(.caption)
                        .foregroundStyle(AppColors.Text.muted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                FlexibleWordCloudLayout(spacing: 12) {
                    ForEach(wordCloudItems) { item in
                        let fontSize = max(14, min(32, 14 + item.weight * 18))
                        let fontWeight: Font.Weight = {
                            if item.weight > 0.8 { return .heavy }
                            if item.weight > 0.6 { return .bold }
                            if item.weight > 0.4 { return .semibold }
                            return .medium
                        }()
                        let opacity = 0.4 + item.weight * 0.6

                        Text(item.text)
                            .font(.system(size: fontSize, weight: fontWeight))
                            .foregroundStyle(AppColors.primary)
                            .opacity(opacity)
                    }
                }
                .frame(minHeight: 200)
                .padding()

                Divider()
                    .background(AppColors.Border.subtle)

                Text("Word size and opacity reflect frequency")
                    .font(.caption2)
                    .foregroundStyle(AppColors.Text.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
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

    // MARK: - Word Cloud Generation

    private func generateWordCloud(from entries: [Entry], maxWords: Int) -> [WordCloudItem] {
        let excludeWords = Set([
            "a", "an", "and", "are", "as", "at", "be", "by", "for", "from",
            "has", "he", "in", "is", "it", "its", "of", "on", "that", "the",
            "to", "was", "will", "with", "i", "me", "my", "myself", "we", "our",
            "you", "your", "today", "yesterday", "really", "very", "just", "so",
            "also", "then", "than", "only", "even", "much", "more", "most",
            "some", "any", "many", "few", "good", "well", "better", "best"
        ])

        var wordCount: [String: Int] = [:]

        // Extract and count words
        for entry in entries {
            var allText: [String] = []

            if let journal = entry.journal {
                allText.append(journal)
            }
            if let memory = entry.memory {
                allText.append(memory)
            }
            allText.append(contentsOf: entry.gratitudes)
            allText.append(contentsOf: entry.accomplishments)

            for text in allText {
                let words = text
                    .lowercased()
                    .components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { word in
                        word.count >= 3 && !excludeWords.contains(word)
                    }

                for word in words {
                    wordCount[word, default: 0] += 1
                }
            }
        }

        // Sort by count and take top words
        let sortedWords = wordCount
            .sorted { $0.value > $1.value }
            .prefix(maxWords)
            .map { (text: $0.key, count: $0.value) }
            .shuffled() // Randomize for visual variety

        // Calculate weights
        guard let maxCount = sortedWords.map({ $0.count }).max(),
              let minCount = sortedWords.map({ $0.count }).min() else {
            return []
        }

        let countRange = Double(maxCount - minCount)
        let normalizedRange = countRange == 0 ? 1.0 : countRange

        return sortedWords.map { word in
            let weight = (Double(word.count - minCount)) / normalizedRange
            return WordCloudItem(text: word.text, count: word.count, weight: weight)
        }
    }
}

// MARK: - Flexible Word Cloud Layout

struct FlexibleWordCloudLayout: Layout {
    var spacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(
            proposal: proposal,
            subviews: subviews
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(
            proposal: proposal,
            subviews: subviews
        )

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let width = proposal.width ?? 300
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > width && currentX > 0 {
                // Move to next line
                currentX = 0
                currentY += maxHeight + spacing
                totalHeight = currentY
                maxHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }

        totalHeight += maxHeight

        return (CGSize(width: width, height: totalHeight), positions)
    }
}
