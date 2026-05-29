import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let imageName: String
    let icon: String
    let accentLabel: String
    let headline: String
    let description: String
    let highlights: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "WidgetRoutines",
            icon: "list.bullet.rectangle.fill",
            accentLabel: "ROUTINES",
            headline: "Plan Your Workouts",
            description: "Build custom routines from templates or scratch. Reorder exercises and keep your training organized.",
            highlights: ["Templates", "Reorder", "Archive"]
        ),
        OnboardingPage(
            id: 1,
            imageName: "WidgetTimer",
            icon: "timer",
            accentLabel: "INTERVAL TIMER",
            headline: "Train With Precision",
            description: "Configure work and rest intervals, save presets, and stay on track through every round.",
            highlights: ["Presets", "HIIT · Tabata", "Background"]
        ),
        OnboardingPage(
            id: 2,
            imageName: "WidgetProgress",
            icon: "chart.bar.fill",
            accentLabel: "PROGRESS",
            headline: "Track Every Session",
            description: "Monitor streaks, weekly goals, personal records, and achievements as you improve over time.",
            highlights: ["Weekly Goals", "Records", "Achievements"]
        )
    ]

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(
                            page: page,
                            pageNumber: page.id + 1,
                            totalPages: pages.count,
                            isActive: currentPage == page.id
                        )
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Capsule()
                    .fill(
                        page.id <= currentPage
                            ? Color("AppPrimary")
                            : Color("AppTextSecondary").opacity(0.18)
                    )
                    .frame(height: 4)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
            }

            Spacer(minLength: 16)

            Button {
                FeedbackManager.lightTap()
                store.completeOnboarding()
            } label: {
                Text("Skip")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(pages) { page in
                    Capsule()
                        .fill(
                            currentPage == page.id
                                ? Color("AppPrimary")
                                : Color("AppTextSecondary").opacity(0.22)
                        )
                        .frame(width: currentPage == page.id ? 22 : 7, height: 7)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
                }
            }

            HStack(spacing: 12) {
                if currentPage > 0 {
                    Button {
                        FeedbackManager.lightTap()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline.weight(.semibold))
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .appSurfaceBackground(cornerRadius: 16, elevation: .raised)
                    }
                    .buttonStyle(.plain)
                }

                PrimaryButton(
                    title: currentPage < pages.count - 1 ? "Continue" : "Get Started",
                    icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
                ) {
                    FeedbackManager.lightTap()
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        FeedbackManager.success()
                        store.completeOnboarding()
                    }
                }
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageNumber: Int
    let totalPages: Int
    let isActive: Bool

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            heroSection
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .scaleEffect(appeared ? 1 : 0.94)
                .opacity(appeared ? 1 : 0)

            contentSection
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .offset(y: appeared ? 0 : 18)
                .opacity(appeared ? 1 : 0)

            Spacer(minLength: 12)
        }
        .onAppear { animateIn() }
        .onChange(of: isActive) { active in
            if active {
                appeared = false
                animateIn()
            }
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image(page.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()

            LinearGradient(
                colors: [
                    .clear,
                    Color("AppBackground").opacity(0.35),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom) {
                IconBadge(symbol: page.icon, size: 52, iconSize: .title2)
                Spacer()
                Text("\(pageNumber)/\(totalPages)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(Color("AppSurface").opacity(0.85))
                            .overlay {
                                Capsule()
                                    .stroke(AppGradients.borderStroke(), lineWidth: 0.8)
                            }
                    }
            }
            .padding(16)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppGradients.borderStroke(), lineWidth: 1)
        }
        .appElevation(.floating)
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(page.accentLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
                .tracking(0.6)

            Text(page.headline)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .fixedSize(horizontal: false, vertical: true)

            Text(page.description)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(page.highlights, id: \.self) { highlight in
                    TagPill(text: highlight, color: Color("AppPrimary"))
                }
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            appeared = true
        }
    }
}
