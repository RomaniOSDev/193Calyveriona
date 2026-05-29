import SwiftUI

struct StatsAchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { store.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SummaryStripCell(items: [
                        ("Sessions", "\(store.totalSessionsCompleted)", "figure.run"),
                        ("Minutes", "\(store.totalMinutesUsed)", "clock.fill"),
                        ("Streak", "\(store.streakDays)d", "flame.fill")
                    ])
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    AppCard(padding: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Achievement Progress")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("\(unlockedCount) of \(AchievementDefinition.all.count) unlocked")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            Spacer()
                            ProgressRingView(
                                progress: Double(unlockedCount) / Double(AchievementDefinition.all.count),
                                lineWidth: 5,
                                size: 48
                            )
                        }
                    }
                    .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementDefinition.all) { achievement in
                            AchievementCell(
                                achievement: achievement,
                                isUnlocked: store.isAchievementUnlocked(achievement.id)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
