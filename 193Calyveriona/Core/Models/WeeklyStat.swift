import Foundation

struct WeeklyStat: Codable, Identifiable, Equatable {
    let id: UUID
    var weekStart: Date
    var date: Date
    var minutes: Int
    var sessions: Int

    init(id: UUID = UUID(), weekStart: Date, date: Date, minutes: Int, sessions: Int) {
        self.id = id
        self.weekStart = weekStart
        self.date = date
        self.minutes = minutes
        self.sessions = sessions
    }
}

struct DailyStat: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let minutes: Int
    let sessions: Int
    let dayLabel: String
}
