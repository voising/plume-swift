import SwiftUI

struct FieldCard: View {
    let label: String
    let icon: String
    let color: Color
    let placeholder: String
    @Binding var value: String

    @State private var isExpanded: Bool
    @FocusState private var isFocused: Bool

    var initiallyExpanded: Bool
    var completed: Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(label: String, icon: String, color: Color, placeholder: String, value: Binding<String>, initiallyExpanded: Bool = false) {
        self.label = label
        self.icon = icon
        self.color = color
        self.placeholder = placeholder
        self._value = value
        self.initiallyExpanded = initiallyExpanded
        self._isExpanded = State(initialValue: initiallyExpanded || !value.wrappedValue.isEmpty)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header - tappable to expand
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded = true
                    isFocused = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)

                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.Text.secondary)

                    Spacer()

                    if completed {
                        Circle()
                            .fill(color)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }

                    if !isExpanded {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(AppColors.Text.muted)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .background(AppColors.Border.subtle.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $value)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.Text.primary)
                        .frame(minHeight: 50)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .focused($isFocused)

                    if value.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.Text.muted)
                            .padding(.horizontal, 17)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColors.Background.secondaryDark.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.Border.subtle.opacity(0.6), lineWidth: 1)
        )
        .scaleEffect(completed ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: completed)
        .onChange(of: value) { _, newValue in
            if !newValue.isEmpty {
                isExpanded = true
            }
        }
        .onChange(of: isFocused) { _, focused in
            if focused {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded = true
                }
            } else if value.isEmpty {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded = false
                }
            }
        }
    }
}
