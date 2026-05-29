import SwiftUI

struct AppBackgroundView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            AppDecorBackground()
            content()
        }
    }
}

struct EmptyStateView: View {
    let symbol: String
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(AppGradients.borderStroke(), lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .scaleEffect(appeared ? 1 : 0.6)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppPrimary").opacity(0.18), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 90)
                Image(systemName: symbol)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppGradients.accentFill())
            }
            .compositingGroup()
            .shadow(color: Color("AppPrimary").opacity(0.2), radius: 8, y: 3)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.7)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle, let action {
                Button {
                    FeedbackManager.lightTap()
                    action()
                } label: {
                    Text(actionTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color("AppPrimary").opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(28)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool
    @State private var scale: CGFloat = 0.5

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.25).ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("AppAccent"))
                        .scaleEffect(scale)
                    Text("Saved!")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .padding(32)
                .appSurfaceBackground(cornerRadius: 24, elevation: .floating)
            }
            .transition(.opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -140

    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 14) {
                IconBadge(symbol: achievement.systemImage, size: 44, iconSize: .body)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Achievement Unlocked")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -140
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}

// Legacy aliases — keep StatCard for minimal diff
struct StatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        StatRowCell(icon: icon, title: title, value: value)
    }
}

struct StepperRow: View {
    let title: String
    let value: Int
    let suffix: String
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        TimerControlCell(
            title: title,
            icon: "slider.horizontal.3",
            value: value,
            suffix: suffix,
            onDecrement: onDecrement,
            onIncrement: onIncrement
        )
    }
}

typealias FilterChip = FilterChipCell
