import SwiftUI

struct HeaderActionButton: View {
    let icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.Text.primary)
                .frame(width: 40, height: 40)
                .background(AppColors.Background.secondaryDark)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColors.Border.subtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
