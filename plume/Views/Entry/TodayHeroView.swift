import SwiftUI
import SwiftData

struct TodayHeroView: View {
    let date: Date
    @Binding var showSettings: Bool
    
    @EnvironmentObject private var journalService: JournalService
    @State private var showSearch = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header
                
                EntryDetailView(date: date, autoCreateEntry: true)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.Background.mainLight)
        .sheet(isPresented: $showSearch) {
            NavigationStack {
                ExploreView()
                    .navigationTitle("Search")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                showSearch = false
                            }
                        }
                    }
            }
        }
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Plume")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(AppColors.Text.primary)
                
                Text("Reflect, grow, and track your journey")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            Spacer()
            
            HStack(spacing: 12) {
                HeaderActionButton(icon: "magnifyingglass") {
                    showSearch = true
                }
                HeaderActionButton(icon: "gearshape.fill") {
                    showSettings = true
                }
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    TodayHeroView(date: Date(), showSettings: .constant(false))
        .modelContainer(for: [Entry.self, Todo.self], inMemory: true)
        .environmentObject(JournalService(modelContext: try! ModelContainer(for: Entry.self, Todo.self).mainContext))
}
