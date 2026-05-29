import Foundation

enum SessionType: String, Codable, CaseIterable {
    case timer
    case routine

    var label: String {
        switch self {
        case .timer: return "Timer"
        case .routine: return "Routine"
        }
    }

    var systemImage: String {
        switch self {
        case .timer: return "timer"
        case .routine: return "list.bullet"
        }
    }
}

struct WorkoutSession: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let durationMinutes: Int
    let type: SessionType
    var routineID: UUID?
    var routineName: String?
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        durationMinutes: Int,
        type: SessionType,
        routineID: UUID? = nil,
        routineName: String? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.type = type
        self.routineID = routineID
        self.routineName = routineName
        self.notes = notes
    }
}
