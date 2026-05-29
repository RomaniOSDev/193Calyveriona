import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_step",
            title: "First Step",
            description: "Completed your very first workout session.",
            systemImage: "figure.walk"
        ),
        AchievementDefinition(
            id: "consistency_hero",
            title: "Consistency Hero",
            description: "Worked out three days in a row.",
            systemImage: "flame.fill"
        ),
        AchievementDefinition(
            id: "endurance_achiever",
            title: "Endurance Achiever",
            description: "Total workout time reached 100 minutes.",
            systemImage: "clock.fill"
        ),
        AchievementDefinition(
            id: "routine_master",
            title: "Routine Master",
            description: "Completed a custom routine five times.",
            systemImage: "list.bullet.clipboard.fill"
        ),
        AchievementDefinition(
            id: "milestone_marker",
            title: "Milestone Marker",
            description: "Reached your longest session ever at one hour.",
            systemImage: "star.fill"
        ),
        AchievementDefinition(
            id: "week_streaker",
            title: "Week Streaker",
            description: "Worked out every day for a week.",
            systemImage: "calendar"
        ),
        AchievementDefinition(
            id: "minute_accumulator",
            title: "Minute Accumulator",
            description: "Logged over two hundred total minutes of workouts.",
            systemImage: "timer"
        ),
        AchievementDefinition(
            id: "session_enthusiast",
            title: "Session Enthusiast",
            description: "Completed ten distinct workouts.",
            systemImage: "bolt.fill"
        )
    ]
}
