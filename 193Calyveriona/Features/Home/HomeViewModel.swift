import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
        store.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var motivationalLine: String {
        if store.streakDays >= 7 {
            return "You're on fire — \(store.streakDays)-day streak!"
        }
        if store.totalSessionsCompleted == 0 {
            return "Ready to start your fitness journey?"
        }
        if store.weeklyGoalSessionsProgress >= 1 {
            return "Weekly session goal reached. Keep going!"
        }
        return "Every session counts. Let's move today."
    }

    var recentSession: WorkoutSession? {
        store.sessionHistory.first
    }

    var unlockedAchievements: Int {
        AchievementDefinition.all.filter { store.isAchievementUnlocked($0.id) }.count
    }

    var nextAchievement: AchievementDefinition? {
        AchievementDefinition.all.first { !store.isAchievementUnlocked($0.id) }
    }

    var sessionsGoalProgress: Double {
        store.weeklyGoalSessionsProgress
    }

    var minutesGoalProgress: Double {
        store.weeklyGoalMinutesProgress
    }

    var weekComparison: WeekComparison {
        store.weekComparison
    }
}
