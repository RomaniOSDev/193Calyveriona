import Foundation

struct TimerPreset: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var workDurationSec: Int
    var restDurationSec: Int
    var roundsCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        workDurationSec: Int,
        restDurationSec: Int,
        roundsCount: Int
    ) {
        self.id = id
        self.name = name
        self.workDurationSec = workDurationSec
        self.restDurationSec = restDurationSec
        self.roundsCount = roundsCount
    }

    var totalDurationSec: Int {
        workDurationSec * roundsCount + restDurationSec * max(roundsCount - 1, 0)
    }
}
