import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = HomeViewModel()

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroSection
                    statsWidget
                    quickActionsGrid
                    weeklyGoalsWidget
                    HStack(spacing: 12) {
                        weekDeltaWidget
                        achievementsWidget
                    }
                    .padding(.horizontal, 16)
                    recentSessionWidget
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.85), Color("AppBackground")],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.greeting)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                        Text(viewModel.motivationalLine)
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                    streakBadge
                }
            }
            .padding(16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppGradients.borderStroke(), lineWidth: 1)
        }
        .appElevation(.floating)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var streakBadge: some View {
        VStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color("AppAccent"))
            Text("\(store.streakDays)")
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text("day streak")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppGradients.surfaceFill())
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppGradients.borderStroke(), lineWidth: 1)
                }
        }
        .appElevation(.raised)
    }

    // MARK: - Stats widget

    private var statsWidget: some View {
        SummaryStripCell(items: [
            ("Sessions", "\(store.totalSessionsCompleted)", "figure.run"),
            ("Minutes", "\(store.totalMinutesUsed)", "clock.fill"),
            ("This Week", "\(store.currentWeekProgress.sessions)", "calendar")
        ])
        .padding(.horizontal, 16)
    }

    // MARK: - Quick actions

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions", subtitle: "Jump into your workout")
                .padding(.horizontal, 16)

            LazyVGrid(columns: widgetColumns, spacing: 12) {
                QuickActionWidget(
                    imageName: "WidgetTimer",
                    title: "Start Timer",
                    subtitle: formatTimerHint(),
                    accent: Color("AppPrimary")
                ) {
                    selectedTab = .timer
                }

                QuickActionWidget(
                    imageName: "WidgetRoutines",
                    title: "Routines",
                    subtitle: "\(store.activeRoutines.count) active",
                    accent: Color("AppAccent")
                ) {
                    selectedTab = .training
                }

                QuickActionWidget(
                    imageName: "WidgetProgress",
                    title: "Performance",
                    subtitle: "View stats",
                    accent: Color("AppAccent")
                ) {
                    selectedTab = .training
                }

                QuickActionWidget(
                    imageName: "HomeHero",
                    title: "Achievements",
                    subtitle: "\(viewModel.unlockedAchievements)/\(AchievementDefinition.all.count)",
                    accent: Color("AppPrimary")
                ) {
                    selectedTab = .achievements
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Weekly goals

    private var weeklyGoalsWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(
                    title: "Weekly Goals",
                    subtitle: "\(store.currentWeekProgress.sessions) sessions · \(store.currentWeekProgress.minutes) min"
                )

                goalBar(
                    icon: "figure.run",
                    label: "Sessions",
                    current: store.currentWeekProgress.sessions,
                    target: store.weeklyGoalSessions,
                    progress: viewModel.sessionsGoalProgress
                )
                goalBar(
                    icon: "clock.fill",
                    label: "Minutes",
                    current: store.currentWeekProgress.minutes,
                    target: store.weeklyGoalMinutes,
                    progress: viewModel.minutesGoalProgress
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private func goalBar(icon: String, label: String, current: Int, target: Int, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                IconBadge(symbol: icon, size: 26, iconSize: .caption2)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("\(current)/\(target)")
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(Color("AppAccent"))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("AppBackground").opacity(0.6))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppAccent"), Color("AppPrimary")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Week delta + achievements

    private var weekDeltaWidget: some View {
        AppCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                IconBadge(symbol: "chart.line.uptrend.xyaxis", size: 32, iconSize: .caption2)
                Text("This Week")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(formatDelta(viewModel.weekComparison.sessionsDelta))
                    .font(.title3.bold())
                    .foregroundStyle(viewModel.weekComparison.sessionsDelta >= 0 ? Color("AppAccent") : Color("AppTextSecondary"))
                Text("sessions vs last week")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var achievementsWidget: some View {
        Button {
            FeedbackManager.lightTap()
            selectedTab = .achievements
        } label: {
            AppCard(padding: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressRingView(
                        progress: Double(viewModel.unlockedAchievements) / Double(AchievementDefinition.all.count),
                        lineWidth: 4,
                        size: 36
                    )
                    Text("Achievements")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("\(viewModel.unlockedAchievements) unlocked")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let next = viewModel.nextAchievement {
                        Text("Next: \(next.title)")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent session

    private var recentSessionWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(
                title: "Recent Activity",
                subtitle: "Your latest session",
                actionTitle: store.sessionHistory.isEmpty ? nil : "See All",
                action: store.sessionHistory.isEmpty ? nil : { selectedTab = .training }
            )
            .padding(.horizontal, 16)

            if let session = viewModel.recentSession {
                SessionHistoryCell(session: session)
                    .padding(.horizontal, 16)
            } else {
                AppCard(padding: 20, showBorder: false) {
                    HStack(spacing: 14) {
                        Image("WidgetProgress")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No sessions yet")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Start a timer or complete a routine.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                        Button {
                            selectedTab = .timer
                        } label: {
                            Text("Go")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color("AppPrimary"))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Helpers

    private func formatTimerHint() -> String {
        let sec = store.totalSessionDurationSec
        return String(format: "%d:%02d ready", sec / 60, sec % 60)
    }

    private func formatDelta(_ delta: Int) -> String {
        delta > 0 ? "+\(delta)" : "\(delta)"
    }
}

// MARK: - Quick action widget cell

private struct QuickActionWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let accent: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 72)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [.clear, Color("AppSurface").opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppGradients.surfaceFill())
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(accent.opacity(0.3), lineWidth: 1)
            }
            .appElevation(.raised)
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}
