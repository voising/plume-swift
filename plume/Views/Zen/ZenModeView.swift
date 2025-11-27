import SwiftUI

struct ZenModeView: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    var date: Date
    
    @State private var fontSize: Double = 18
    @State private var selectedTheme: Int = 1
    @State private var selectedFontColor: Int = 0
    
    private let themes: [Color] = [
        Color(hex: "0E0E10"),
        Color(hex: "15151C"),
        Color(hex: "1F1C17")
    ]
    
    private let fontColors: [Color] = [
        Color(hex: "F9FAFB"),  // White/Light gray
        Color(hex: "FCD34D"),  // Warm yellow
        Color(hex: "A78BFA"),  // Purple
        Color(hex: "60A5FA"),  // Blue
        Color(hex: "34D399")   // Green
    ]
    
    var body: some View {
        ZStack {
            themes[selectedTheme]
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                        .font(.callout.weight(.medium))
                        .foregroundStyle(AppColors.Text.secondary)
                    Spacer()
                    
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.Text.primary)
                            .padding(12)
                            .background(AppColors.Background.secondaryDark.opacity(0.9))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 24)
                
                TextEditor(text: $text)
                    .font(.system(size: fontSize, weight: .regular, design: .serif))
                    .foregroundColor(fontColors[selectedFontColor])
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .frame(maxWidth: 700)
                    .tint(AppColors.primary)
                
                toolbar
            }
        }
    }
    
    private var toolbar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                pillButton(icon: "calendar.badge.clock", title: "Time")
                
                HStack(spacing: 10) {
                    ForEach(Array(themes.enumerated()), id: \.offset) { index, color in
                        Circle()
                            .fill(color)
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.primary, lineWidth: selectedTheme == index ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedTheme = index
                            }
                    }
                }
                
                HStack(spacing: 10) {
                    ForEach(Array(fontColors.enumerated()), id: \.offset) { index, color in
                        Circle()
                            .fill(color)
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.primary, lineWidth: selectedFontColor == index ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedFontColor = index
                            }
                    }
                }
                
                Spacer()
                
                pillButton(title: "\(wordCount) words")
                
                fontSizeControl
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.clear)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    private func pillButton(icon: String? = nil, title: String) -> some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
            }
            Text(title)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(AppColors.Text.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColors.Background.elevated.opacity(0.8))
        .clipShape(Capsule())
    }
    
    private var fontSizeControl: some View {
        HStack(spacing: 8) {
            Text("A")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.Text.secondary)
            Text("\(Int(fontSize))")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.Text.primary)
                .frame(width: 24)
            Text("A")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.Text.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.Background.elevated.opacity(0.8))
        .clipShape(Capsule())
        .onTapGesture {
            if fontSize < 30 {
                fontSize += 2
            } else {
                fontSize = 14
            }
        }
    }
    
    private var wordCount: Int {
        text.split { $0.isWhitespace }.count
    }
}

#Preview {
    ZenModeView(text: .constant("Let your thoughts flow..."), isPresented: .constant(true), date: Date())
}
