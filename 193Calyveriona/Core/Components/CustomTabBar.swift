import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case timer
    case training
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .timer: return "Timer"
        case .training: return "Training"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .timer: return "timer"
        case .training: return "figure.strengthtraining.traditional"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @State private var pressedTab: AppTab?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            if selectedTab == tab {
                                Circle()
                                    .fill(Color("AppPrimary").opacity(0.2))
                                    .frame(width: 36, height: 36)
                            }
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(selectedTab == tab ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        }
                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(selectedTab == tab ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppGradients.primaryFill())
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppGradients.topSheen())
                                }
                        }
                    }
                    .scaleEffect(pressedTab == tab ? 0.94 : 1)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in pressedTab = tab }
                        .onEnded { _ in pressedTab = nil }
                )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(AppGradients.surfaceFill())
                Rectangle()
                    .fill(AppGradients.topSheen())
                    .frame(height: 1)
            }
        }
        .appElevation(.raised)
    }
}
