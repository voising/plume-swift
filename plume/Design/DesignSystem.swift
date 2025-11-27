import SwiftUI

struct AppColors {
    // Primary colors - matching React Native dark theme
    static let primary = Color(hex: "D4AF37")        // Brighter gold for dark mode
    static let primaryLight = Color(hex: "F4E4BC")   // Very light gold
    static let accent = Color(hex: "8FBC8F")         // Lighter sage for dark mode

    struct Background {
        // Warm off-black backgrounds matching React Native
        static let mainLight = Color(hex: "1A1A1A")       // Warm off-black
        static let mainDark = Color(hex: "050506")        // Keep for special cases
        static let secondaryLight = Color(hex: "242424")  // Slightly lighter surface
        static let secondaryDark = Color(hex: "2A2A2A")   // Card background
        static let elevated = Color(hex: "2A2A2A")        // Card background
    }

    struct Text {
        // Cream tones matching React Native
        static let primary = Color(hex: "F5F5DC")    // Cream text
        static let secondary = Color(hex: "D3D3D3")  // Light gray
        static let muted = Color(hex: "A0A0A0")      // Muted gray
    }

    struct Border {
        // Dark gray borders matching React Native
        static let subtle = Color(hex: "404040")     // Dark gray
        static let strong = Color(hex: "353535")     // Darker gray
    }

    struct EntryType {
        // Enhanced pill colors for better visibility in dark mode
        static let gratitude = Color(hex: "FFD700")  // Bright gold for gratitude
        static let memory = Color(hex: "00CED1")     // Bright turquoise for memory
        static let accomplishment = Color(hex: "FF6B6B")  // Bright coral for accomplishment
        static let journal = Color(hex: "A78BFA")    // Keep the purple
    }

    struct Status {
        static let success = Color(hex: "66BB6A")
        static let warning = Color(hex: "FFB74D")
        static let error = Color(hex: "EF5350")
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
