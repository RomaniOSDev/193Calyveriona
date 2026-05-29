import Combine
import Foundation

final class PerformanceTrackerViewModel: ObservableObject {
    @Published var weekOffset = 0
    @Published var selectedStat: StatType?
    @Published var filterType: SessionType?
    @Published var filterRoutineID: UUID?

    let store: AppDataStore

    enum StatType: String, Identifiable {
        case sessions
        case minutes
        case average

        var id: String { rawValue }

        var title: String {
            switch self {
            case .sessions: return "Total Sessions"
            case .minutes: return "Total Minutes"
            case .average: return "Average Duration"
            }
        }

        var icon: String {
            switch self {
            case .sessions: return "figure.run"
            case .minutes: return "clock.fill"
            case .average: return "chart.line.uptrend.xyaxis"
            }
        }
    }

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    var hasData: Bool {
        !filteredSessions.isEmpty || store.totalSessionsCompleted > 0
    }

    var filteredSessions: [WorkoutSession] {
        store.filteredSessions(type: filterType, routineID: filterRoutineID)
    }

    var dailyStats: [DailyStat] {
        store.filteredDailyStats(
            forWeekOffset: weekOffset,
            type: filterType,
            routineID: filterRoutineID
        )
    }

    var maxMinutes: Int {
        max(dailyStats.map(\.minutes).max() ?? 0, 1)
    }

    func shiftWeek(forward: Bool) {
        FeedbackManager.lightTap()
        if forward {
            weekOffset = max(weekOffset - 1, 0)
        } else {
            weekOffset += 1
        }
    }

    func value(for type: StatType) -> String {
        let sessions = filteredSessions
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        switch type {
        case .sessions:
            return filterActive ? "\(sessions.count)" : "\(store.totalSessionsCompleted)"
        case .minutes:
            return filterActive ? "\(totalMinutes) min" : "\(store.totalMinutesUsed) min"
        case .average:
            let count = filterActive ? sessions.count : store.totalSessionsCompleted
            let minutes = filterActive ? totalMinutes : store.totalMinutesUsed
            guard count > 0 else { return "0 min" }
            return "\(minutes / count) min"
        }
    }

    func detailText(for type: StatType) -> String {
        switch type {
        case .sessions:
            return "You have completed \(value(for: .sessions)) workout sessions\(filterSuffix)."
        case .minutes:
            return "You have logged \(value(for: .minutes).replacingOccurrences(of: " min", with: "")) minutes of exercise\(filterSuffix)."
        case .average:
            return "Your average session lasts \(value(for: .average))\(filterSuffix)."
        }
    }

    private var filterActive: Bool {
        filterType != nil || filterRoutineID != nil
    }

    private var filterSuffix: String {
        if let routineID = filterRoutineID,
           let name = store.routines.first(where: { $0.id == routineID })?.name {
            return " for \(name)"
        }
        if let type = filterType {
            return " from \(type.label.lowercased()) workouts"
        }
        return " in total"
    }
}
