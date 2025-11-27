import SwiftUI
import SwiftData

struct TodayHeroView: View {
    let date: Date

    @EnvironmentObject private var journalService: JournalService

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                EntryDetailView(date: date, autoCreateEntry: true)
            }
            .padding(.horizontal, 20)
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
