import Foundation

struct Exercise: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var repsOrDuration: String

    init(id: UUID = UUID(), name: String, repsOrDuration: String) {
        self.id = id
        self.name = name
        self.repsOrDuration = repsOrDuration
    }
}

struct Routine: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var exercises: [Exercise]
    var completionCount: Int
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        exercises: [Exercise],
        completionCount: Int = 0,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.completionCount = completionCount
        self.isArchived = isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([Exercise].self, forKey: .exercises)
        completionCount = try container.decodeIfPresent(Int.self, forKey: .completionCount) ?? 0
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }

    func completedCount(completedIDs: Set<UUID>) -> Int {
        exercises.filter { completedIDs.contains($0.id) }.count
    }

    var estimatedMinutes: Int {
        max(exercises.count * 3, 5)
    }
}
