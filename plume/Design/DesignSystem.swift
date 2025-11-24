import SwiftUI

struct AppColors {
    static let primary = Color(hex: "F2C550")
    static let accent = Color(hex: "F4B740")
    
    struct Background {
        static let mainLight = Color(hex: "0B0B0F")
        static let mainDark = Color(hex: "050506")
        static let secondaryLight = Color(hex: "14141A")
        static let secondaryDark = Color(hex: "1C1C24")
        static let elevated = Color(hex: "1F1F29")
    }
    
    struct Text {
        static let primary = Color(hex: "F5F6F9")
        static let secondary = Color(hex: "A1A1B4")
        static let muted = Color(hex: "6B6B7B")
    }
    
    struct Border {
        static let subtle = Color(hex: "2B2B35")
        static let strong = Color(hex: "3C3C46")
    }
    
    struct EntryType {
        static let gratitude = Color(hex: "F4C15D")
        static let memory = Color(hex: "3CDAB6")
        static let accomplishment = Color(hex: "F87171")
        static let journal = Color(hex: "A78BFA")
    }
}

struct CardBackgroundModifier: ViewModifier {
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppColors.Background.secondaryDark)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppColors.Border.subtle, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.35), radius: 25, x: 0, y: 18)
    }
}

extension View {
    func plumeCard(padding: CGFloat = 20) -> some View {
        modifier(CardBackgroundModifier(padding: padding))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
