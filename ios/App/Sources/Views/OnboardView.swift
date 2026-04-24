import SwiftUI

// MARK: - Onboard slide data

private struct OnboardSlide {
    let icon: String
    let title: String
    let body: String
}

private let slides: [OnboardSlide] = [
    OnboardSlide(
        icon: "sparkles",
        title: "Welcome to\n__APP_NAME__",
        body: "Your next great app starts here.\nLet's get you set up."
    ),
    OnboardSlide(
        icon: "bolt.fill",
        title: "Powerful Features",
        body: "Everything you need to build fast,\nship confidently, and scale easily."
    ),
    OnboardSlide(
        icon: "checkmark.seal.fill",
        title: "Ready to Go",
        body: "Create your account and start\nexploring in seconds."
    ),
]

// MARK: - OnboardView

struct OnboardView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var currentIndex = 0

    private var isFirst: Bool { currentIndex == 0 }
    private var isLast:  Bool { currentIndex == slides.count - 1 }

    var body: some View {
        ZStack {
            // Slide content
            TabView(selection: $currentIndex) {
                ForEach(slides.indices, id: \.self) { i in
                    SlideView(slide: slides[i])
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentIndex)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top) {
            HStack {
                Button {
                    withAnimation { currentIndex -= 1 }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                .opacity(isFirst ? 0 : 1)

                Spacer()

                // Page dots
                HStack(spacing: 8) {
                    ForEach(slides.indices, id: \.self) { i in
                        Circle()
                            .fill(i == currentIndex ? Color.accentColor : Color.secondary.opacity(0.4))
                            .frame(width: i == currentIndex ? 10 : 6, height: i == currentIndex ? 10 : 6)
                            .animation(.spring(response: 0.3), value: currentIndex)
                    }
                }

                Spacer()

                // Skip on non-last slides
                Button("Skip") {
                    hasCompleted = true
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
                .opacity(isLast ? 0 : 1)
            }
            .padding(.horizontal, UISize.screenXPadding)
        }
        .safeAreaInset(edge: .bottom) {
            ButtonBasic(
                title: isLast ? "Get Started" : "Continue",
                backgroundColor: isLast ? .accentColor.opacity(0.18) : .clear,
                foregroundColor: isLast ? .accentColor : .primary,
                height: 64
            ) {
                if isLast {
                    hasCompleted = true
                } else {
                    withAnimation { currentIndex += 1 }
                }
            }
            .padding(.horizontal, UISize.screenXPadding)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Individual slide

private struct SlideView: View {
    let slide: OnboardSlide

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: slide.icon)
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(.tint)
                .padding(.bottom, 8)

            VStack(spacing: 12) {
                Text(slide.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(slide.body)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, UISize.screenXPadding)
    }
}

#Preview {
    OnboardView()
}
