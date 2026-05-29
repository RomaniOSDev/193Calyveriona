import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView {
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                        case .timer:
                            IntervalTimerView()
                        case .training:
                            TrainingHubView()
                        case .achievements:
                            StatsAchievementsView()
                        case .settings:
                            SettingsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    CustomTabBar(selectedTab: $selectedTab)
                }
            }

            if let banner = store.pendingAchievementBanner {
                AchievementBannerView(achievement: banner) {
                    store.dismissAchievementBanner()
                }
                .padding(.top, 8)
                .zIndex(1)
            }
        }
    }
}

struct TrainingHubView: View {
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PillSegmentControl(options: ["Routines", "Performance"], selection: $segment)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                if segment == 0 {
                    RoutineTrackerView(showNavigation: false)
                } else {
                    PerformanceTrackerView(showNavigation: false)
                }
            }
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
