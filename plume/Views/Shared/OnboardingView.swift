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
    @State private var opacity: Double = 1.0
    var onFinish: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColors.Background.mainLight
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        handleComplete()
                    }
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppColors.Text.secondary)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                // TabView with swipeable slides
                TabView(selection: $currentIndex) {
                    ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                        slideView(for: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentIndex)

                // Navigation controls
                VStack(spacing: 24) {
                    // Dots indicator
                    HStack(spacing: 6) {
                        ForEach(Array(slides.indices), id: \.self) { index in
                            Capsule(style: .continuous)
                                .fill(index == currentIndex ? AppColors.primary : AppColors.Border.subtle)
                                .frame(width: index == currentIndex ? 32 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.25), value: currentIndex)
                                .onTapGesture {
                                    withAnimation {
                                        currentIndex = index
                                    }
                                }
                        }
                    }

                    // Back and Next buttons
                    HStack(spacing: 16) {
                        if currentIndex > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentIndex -= 1
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(AppColors.Text.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }

                        Spacer()

                        Button(action: advance) {
                            Text(currentIndex == slides.count - 1 ? "Get Started" : "Next")
                                .font(.headline)
                                .foregroundStyle(.black.opacity(0.85))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(AppColors.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .opacity(opacity)
    }

    private func handleComplete() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onFinish()
        }
    }

    private func advance() {
        if currentIndex == slides.count - 1 {
            handleComplete()
        } else {
            withAnimation {
                currentIndex += 1
            }
        }
    }

    @ViewBuilder
    private func slideView(for slide: Slide) -> some View {
        VStack(spacing: 0) {
            Spacer()

            illustrationView(for: slide.illustration)
                .frame(height: 200)
                .padding(.bottom, 32)

            Text(slide.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppColors.Text.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)

            Text(slide.subtitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.primary)
                .padding(.bottom, 12)

            Text(slide.description)
                .font(.system(size: 16))
                .lineSpacing(8)
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .frame(maxWidth: 400)

            Spacer()
                .frame(height: 120) // Account for navigation height
        }
    }

    @ViewBuilder
    private func illustrationView(for illustration: Illustration) -> some View {
        switch illustration {
        case .spark:
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(AppColors.Background.secondaryDark)
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        case .prompts:
            // Triangle arrangement matching React Native
            ZStack {
                // Top emoji
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.Background.secondaryDark)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.primary)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .offset(x: 0, y: -50)

                // Bottom left emoji
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.Background.secondaryDark)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.primary)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .offset(x: -50, y: 50)

                // Bottom right emoji
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.Background.secondaryDark)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.primary)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .offset(x: 50, y: 50)
            }
            .frame(width: 180, height: 180)
        case .calendar:
            // 7 columns × 5 rows = 35 days matching React Native
            VStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { column in
                            let index = row * 7 + column
                            let highlightedIndices = [6, 12, 13, 19, 20, 26, 27]
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(highlightedIndices.contains(index) ? AppColors.primary : AppColors.Border.subtle)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .padding(32)
            .background(AppColors.Background.secondaryDark)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
