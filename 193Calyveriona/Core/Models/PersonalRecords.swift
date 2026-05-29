import Foundation

struct PersonalRecords: Equatable {
    let longestSession: Int
    let mostSessionsInWeek: Int
    let longestStreak: Int
    let totalSessions: Int
    let totalMinutes: Int
}

struct WeekSummary: Equatable {
    let sessions: Int
    let minutes: Int
}

struct WeekComparison: Equatable {
    let current: WeekSummary
    let previous: WeekSummary

    var sessionsDelta: Int { current.sessions - previous.sessions }
    var minutesDelta: Int { current.minutes - previous.minutes }
}
