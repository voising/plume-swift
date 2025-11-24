import SwiftUI

struct OnboardingView: View {
    struct Slide: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let description: String
        let illustration: Illustration
    }
    
    enum Illustration {
        case spark
        case prompts
        case calendar
    }
    
    private let slides: [Slide] = [
        .init(
            title: "Welcome to Plume",
            subtitle: "Your personal space for daily reflection",
            description: "Capture what matters most—gratitudes, memories, and accomplishments—all in one beautiful, private journal.",
            illustration: .spark
        ),
        .init(
            title: "Track What Makes You Happy",
            subtitle: "Three simple daily prompts",
            description: "Start each day with gratitude, capture a special memory, and celebrate your wins—no matter how small.",
            illustration: .prompts
        ),
        .init(
            title: "Your Journey at a Glance",
            subtitle: "Beautiful calendar view",
            description: "Every entry lives in your personal calendar. Look back on any day, see your progress, and watch your story unfold over time.",
            illustration: .calendar
        )
    ]
    
    @State private var currentIndex = 0
    var onFinish: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColors.Background.mainLight
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        onFinish()
                    }
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppColors.Text.secondary)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                Spacer()
                
                illustrationView(for: slides[currentIndex].illustration)
                    .padding(.bottom, 32)
                
                Text(slides[currentIndex].title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.Text.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                
                Text(slides[currentIndex].subtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .padding(.bottom, 12)
                
                Text(slides[currentIndex].description)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                HStack(spacing: 6) {
                    ForEach(Array(slides.indices), id: \.self) { index in
                        Capsule(style: .continuous)
                            .fill(index == currentIndex ? AppColors.primary : AppColors.Border.subtle)
                            .frame(width: index == currentIndex ? 32 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: currentIndex)
                    }
                }
                .padding(.bottom, 24)
                
                HStack(spacing: 16) {
                    if currentIndex > 0 {
                        Button("Back") {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(AppColors.Text.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: advance) {
                        Text(currentIndex == slides.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func advance() {
        if currentIndex == slides.count - 1 {
            onFinish()
        } else {
            withAnimation {
                currentIndex += 1
            }
        }
    }
    
    @ViewBuilder
    private func illustrationView(for illustration: Illustration) -> some View {
        switch illustration {
        case .spark:
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(AppColors.Background.secondaryDark)
                .frame(width: 140, height: 140)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                )
        case .prompts:
            HStack(spacing: 24) {
                VStack(spacing: 16) {
                    onboardingIcon(systemName: "heart.fill")
                    onboardingIcon(systemName: "sparkles")
                }
                onboardingIcon(systemName: "trophy.fill")
            }
            .padding(24)
            .background(AppColors.Background.secondaryDark)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        case .calendar:
            VStack(spacing: 12) {
                let columns = 5
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<columns, id: \.self) { column in
                            let index = row * columns + column
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(index >= 10 && index <= 13 ? AppColors.primary : AppColors.Background.secondaryLight)
                                .frame(width: 18, height: 18)
                        }
                    }
                }
            }
            .padding(32)
            .background(AppColors.Background.secondaryDark)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
    }
    
    private func onboardingIcon(systemName: String) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(AppColors.Background.secondaryLight)
            .frame(width: 70, height: 70)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.primary)
            )
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
