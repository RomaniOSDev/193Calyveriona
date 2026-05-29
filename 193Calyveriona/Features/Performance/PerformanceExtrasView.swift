import SwiftUI

struct RecordsView: View {
    @EnvironmentObject private var store: AppDataStore

    private var records: PersonalRecords {
        store.personalRecords
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                RecordCell(icon: "clock.fill", title: "Longest Session", value: "\(records.longestSession) min", subtitle: "Your longest single workout", rank: 1)
                RecordCell(icon: "calendar.badge.clock", title: "Most Sessions in a Week", value: "\(records.mostSessionsInWeek)", subtitle: "Peak weekly activity", rank: 2)
                RecordCell(icon: "flame.fill", title: "Longest Streak", value: "\(records.longestStreak) days", subtitle: "Consecutive active days", rank: 3)
                RecordCell(icon: "figure.run", title: "Total Sessions", value: "\(records.totalSessions)", subtitle: "All-time completed workouts")
                RecordCell(icon: "timer", title: "Total Minutes", value: "\(records.totalMinutes) min", subtitle: "All-time exercise time")
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Personal Records")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WeeklyGoalsCard: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showEditGoals = false

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(
                    title: "Weekly Goals",
                    subtitle: "Track your progress this week",
                    actionTitle: "Edit",
                    action: { showEditGoals = true }
                )

                goalRow(
                    icon: "figure.run",
                    title: "Sessions",
                    current: store.currentWeekProgress.sessions,
                    target: store.weeklyGoalSessions,
                    progress: store.weeklyGoalSessionsProgress
                )
                goalRow(
                    icon: "clock.fill",
                    title: "Minutes",
                    current: store.currentWeekProgress.minutes,
                    target: store.weeklyGoalMinutes,
                    progress: store.weeklyGoalMinutesProgress
                )
            }
        }
        .sheet(isPresented: $showEditGoals) {
            EditWeeklyGoalsSheet()
        }
    }

    private func goalRow(icon: String, title: String, current: Int, target: Int, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                IconBadge(symbol: icon, size: 28, iconSize: .caption2)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("\(current) / \(target)")
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundStyle(Color("AppAccent"))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("AppBackground").opacity(0.5))
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
}

struct WeekComparisonCard: View {
    @EnvironmentObject private var store: AppDataStore

    private var comparison: WeekComparison {
        store.weekComparison
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: "This Week vs Last Week", subtitle: "Week-over-week change")

                HStack(spacing: 12) {
                    comparisonTile(
                        icon: "figure.run",
                        title: "Sessions",
                        delta: comparison.sessionsDelta,
                        current: comparison.current.sessions,
                        previous: comparison.previous.sessions
                    )
                    comparisonTile(
                        icon: "clock.fill",
                        title: "Minutes",
                        delta: comparison.minutesDelta,
                        current: comparison.current.minutes,
                        previous: comparison.previous.minutes
                    )
                }
            }
        }
    }

    private func comparisonTile(icon: String, title: String, delta: Int, current: Int, previous: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            IconBadge(symbol: icon, size: 32, iconSize: .caption2)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatDelta(delta))
                    .font(.title2.bold())
                    .foregroundStyle(delta >= 0 ? Color("AppAccent") : Color("AppTextSecondary"))
                Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption.bold())
                    .foregroundStyle(delta >= 0 ? Color("AppAccent") : Color("AppTextSecondary"))
            }
            Text("\(current) vs \(previous) last week")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("AppBackground").opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatDelta(_ delta: Int) -> String {
        if delta > 0 { return "+\(delta)" }
        return "\(delta)"
    }
}

private struct EditWeeklyGoalsSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var sessions: Int = 3
    @State private var minutes: Int = 90

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AppCard {
                    VStack(spacing: 16) {
                        HStack {
                            IconBadge(symbol: "figure.run", size: 36, iconSize: .caption)
                            Text("Sessions per week")
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                            HStack(spacing: 12) {
                                CircleButton(symbol: "minus") { sessions = max(sessions - 1, 1) }
                                Text("\(sessions)")
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .frame(width: 30)
                                CircleButton(symbol: "plus") { sessions = min(sessions + 1, 20) }
                            }
                        }
                        HStack {
                            IconBadge(symbol: "clock.fill", size: 36, iconSize: .caption)
                            Text("Minutes per week")
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                            HStack(spacing: 12) {
                                CircleButton(symbol: "minus") { minutes = max(minutes - 15, 15) }
                                Text("\(minutes)")
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .frame(width: 40)
                                CircleButton(symbol: "plus") { minutes = min(minutes + 15, 600) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                PrimaryButton(title: "Save Goals", icon: "checkmark") {
                    FeedbackManager.success()
                    store.weeklyGoalSessions = sessions
                    store.weeklyGoalMinutes = minutes
                    dismiss()
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color("AppBackground"))
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                }
            }
            .onAppear {
                sessions = store.weeklyGoalSessions
                minutes = store.weeklyGoalMinutes
            }
        }
        .presentationDetents([.medium])
    }
}
