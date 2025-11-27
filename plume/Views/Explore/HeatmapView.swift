import SwiftUI
import SwiftData

struct HeatmapView: View {
    let entries: [Entry]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Grid configuration
    private let rows = 7
    private let spacing: CGFloat = 4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Writing Activity")
                    .font(.headline)
                    .foregroundStyle(AppColors.Text.primary)
                
                Spacer()
                
                Text("Less")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color(for: level))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Text("More")
                    .font(.caption)
                    .foregroundStyle(AppColors.Text.secondary)
            }
            
            // Heatmap Grid
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(12), spacing: spacing), count: rows), spacing: spacing) {
                    ForEach(daysInYear(), id: \.self) { date in
                        if let date = date {
                            let count = wordCount(for: date)
                            let level = activityLevel(for: count)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(color(for: level))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                                )
                                .help("\(date.formatted(date: .abbreviated, time: .omitted)): \(count) words")
                        } else {
                            Color.clear
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .plumeCard()
    }
    
    // MARK: - Data Helpers
    
    private func daysInYear() -> [Date?] {
        let today = Date()
        // Get start of 52 weeks ago
        guard let oneYearAgo = calendar.date(byAdding: .weekOfYear, value: -52, to: today),
              let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: oneYearAgo)) else {
            return []
        }
        
        var days: [Date?] = []
        
        // Calculate total days to show (53 weeks * 7 days)
        let totalDays = 53 * 7
        
        for i in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                if date > today {
                    // Don't show future days? Or show empty. 
                    // GitHub shows empty squares for future days in the current week.
                    // Let's stop at today for a cleaner look, or fill with nil if we want full grid.
                    // Actually, GitHub grid is fixed size. Let's fill up to today.
                    days.append(date)
                } else {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    private func wordCount(for date: Date) -> Int {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }?.wordCount ?? 0
    }
    
    private func activityLevel(for count: Int) -> Int {
        if count == 0 { return 0 }
        if count < 50 { return 1 }
        if count < 200 { return 2 }
        if count < 500 { return 3 }
        return 4
    }
    
    private func color(for level: Int) -> Color {
        switch level {
        case 0: return AppColors.Background.secondaryDark
        case 1: return AppColors.primary.opacity(0.3)
        case 2: return AppColors.primary.opacity(0.5)
        case 3: return AppColors.primary.opacity(0.7)
        case 4: return AppColors.primary
        default: return AppColors.Background.secondaryDark
        }
    }
}
