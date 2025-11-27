import SwiftUI
import SwiftData

struct TodayHeroView: View {
    let date: Date

    @EnvironmentObject private var journalService: JournalService

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Quote Section
                VStack(alignment: .center, spacing: 16) {
                    let quote = QuoteService.shared.dailyQuote()
                    
                    Image(systemName: "quote.opening")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.primary.opacity(0.6))
                    
                    Text(quote.text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.Text.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("— \(quote.author)")
                        .font(.callout)
                        .foregroundStyle(AppColors.Text.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .padding(.horizontal, 24)
                
                // Date Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColors.Text.primary)
                    
                    Text("Today's Entry")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.Text.secondary)
                }
                .padding(.horizontal, 20)
                
                // Entry Content
                EntryDetailView(date: date, showHeroHeader: false, autoCreateEntry: true)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(AppColors.Background.mainLight)
    }
}

#Preview {
    TodayHeroView(date: Date())
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
}
