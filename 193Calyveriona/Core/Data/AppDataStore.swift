import Combine
import Foundation

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let workDurationSec = "workDurationSec"
        static let restDurationSec = "restDurationSec"
        static let roundsCount = "roundsCount"
        static let routines = "routines"
        static let completedExerciseIDs = "completedExerciseIDs"
        static let roundsCompleted = "roundsCompleted"
        static let longestSession = "longestSession"
        static let weeklyData = "weeklyData"
        static let routinesCreated = "routinesCreated"
        static let hasCustomizedTimer = "hasCustomizedTimer"
        static let sessionHistory = "sessionHistory"
        static let timerPresets = "timerPresets"
        static let weeklyGoalSessions = "weeklyGoalSessions"
        static let weeklyGoalMinutes = "weeklyGoalMinutes"
        static let longestStreakEver = "longestStreakEver"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet {
            defaults.set(streakDays, forKey: Keys.streakDays)
            if streakDays > longestStreakEver {
                longestStreakEver = streakDays
            }
        }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, forKey: Keys.achievementsUnlocked) }
    }

    @Published var workDurationSec: Int {
        didSet { defaults.set(workDurationSec, forKey: Keys.workDurationSec) }
    }

    @Published var restDurationSec: Int {
        didSet { defaults.set(restDurationSec, forKey: Keys.restDurationSec) }
    }

    @Published var roundsCount: Int {
        didSet { defaults.set(roundsCount, forKey: Keys.roundsCount) }
    }

    @Published var routines: [Routine] {
        didSet { saveCodable(routines, forKey: Keys.routines) }
    }

    @Published var completedExerciseIDs: Set<UUID> {
        didSet { saveUUIDSet(completedExerciseIDs, forKey: Keys.completedExerciseIDs) }
    }

    @Published var roundsCompleted: Int {
        didSet { defaults.set(roundsCompleted, forKey: Keys.roundsCompleted) }
    }

    @Published var longestSession: Int {
        didSet { defaults.set(longestSession, forKey: Keys.longestSession) }
    }

    @Published var weeklyData: [WeeklyStat] {
        didSet { saveCodable(weeklyData, forKey: Keys.weeklyData) }
    }

    @Published var routinesCreated: Int {
        didSet { defaults.set(routinesCreated, forKey: Keys.routinesCreated) }
    }

    @Published var hasCustomizedTimer: Bool {
        didSet { defaults.set(hasCustomizedTimer, forKey: Keys.hasCustomizedTimer) }
    }

    @Published var sessionHistory: [WorkoutSession] {
        didSet { saveCodable(sessionHistory, forKey: Keys.sessionHistory) }
    }

    @Published var timerPresets: [TimerPreset] {
        didSet { saveCodable(timerPresets, forKey: Keys.timerPresets) }
    }

    @Published var weeklyGoalSessions: Int {
        didSet { defaults.set(weeklyGoalSessions, forKey: Keys.weeklyGoalSessions) }
    }

    @Published var weeklyGoalMinutes: Int {
        didSet { defaults.set(weeklyGoalMinutes, forKey: Keys.weeklyGoalMinutes) }
    }

    @Published var longestStreakEver: Int {
        didSet { defaults.set(longestStreakEver, forKey: Keys.longestStreakEver) }
    }

    @Published var pendingAchievementBanner: AchievementDefinition?

    private var achievementQueue: [AchievementDefinition] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(from: defaults, key: Keys.achievementsUnlocked)
        workDurationSec = defaults.object(forKey: Keys.workDurationSec) as? Int ?? 30
        restDurationSec = defaults.object(forKey: Keys.restDurationSec) as? Int ?? 15
        roundsCount = defaults.object(forKey: Keys.roundsCount) as? Int ?? 5
        routines = Self.loadCodable(from: defaults, key: Keys.routines, decoder: decoder) ?? []
        completedExerciseIDs = Self.loadUUIDSet(from: defaults, key: Keys.completedExerciseIDs)
        roundsCompleted = defaults.integer(forKey: Keys.roundsCompleted)
        longestSession = defaults.integer(forKey: Keys.longestSession)
        weeklyData = Self.loadCodable(from: defaults, key: Keys.weeklyData, decoder: decoder) ?? []
        routinesCreated = defaults.integer(forKey: Keys.routinesCreated)
        hasCustomizedTimer = defaults.bool(forKey: Keys.hasCustomizedTimer)
        sessionHistory = Self.loadCodable(from: defaults, key: Keys.sessionHistory, decoder: decoder) ?? []
        timerPresets = Self.loadCodable(from: defaults, key: Keys.timerPresets, decoder: decoder) ?? []
        weeklyGoalSessions = defaults.object(forKey: Keys.weeklyGoalSessions) as? Int ?? 3
        weeklyGoalMinutes = defaults.object(forKey: Keys.weeklyGoalMinutes) as? Int ?? 90
        longestStreakEver = defaults.integer(forKey: Keys.longestStreakEver)
        if longestStreakEver == 0 {
            longestStreakEver = streakDays
        }
    }

    var activeRoutines: [Routine] {
        routines.filter { !$0.isArchived }
    }

    var archivedRoutines: [Routine] {
        routines.filter(\.isArchived)
    }

    var totalSessionDurationSec: Int {
        workDurationSec * roundsCount + restDurationSec * max(roundsCount - 1, 0)
    }

    var averageSessionMinutes: Int {
        guard totalSessionsCompleted > 0 else { return 0 }
        return totalMinutesUsed / totalSessionsCompleted
    }

    var currentWeekProgress: WeekSummary {
        weekSummary(forWeekOffset: 0)
    }

    var weeklyGoalSessionsProgress: Double {
        guard weeklyGoalSessions > 0 else { return 0 }
        return min(Double(currentWeekProgress.sessions) / Double(weeklyGoalSessions), 1)
    }

    var weeklyGoalMinutesProgress: Double {
        guard weeklyGoalMinutes > 0 else { return 0 }
        return min(Double(currentWeekProgress.minutes) / Double(weeklyGoalMinutes), 1)
    }

    var weekComparison: WeekComparison {
        WeekComparison(
            current: weekSummary(forWeekOffset: 0),
            previous: weekSummary(forWeekOffset: 1)
        )
    }

    var personalRecords: PersonalRecords {
        PersonalRecords(
            longestSession: longestSession,
            mostSessionsInWeek: mostSessionsInAnyWeek(),
            longestStreak: max(longestStreakEver, streakDays),
            totalSessions: totalSessionsCompleted,
            totalMinutes: totalMinutesUsed
        )
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func recordActivity(minutes: Int, sessionMinutes: Int) {
        recordSession(minutes: minutes, type: .timer)
    }

    func recordSession(
        minutes: Int,
        type: SessionType,
        routineID: UUID? = nil,
        routineName: String? = nil,
        notes: String = ""
    ) {
        registerStreak()
        totalSessionsCompleted += 1
        totalMinutesUsed += minutes
        if minutes > longestSession {
            longestSession = minutes
        }
        addWeeklyEntry(minutes: minutes)

        let session = WorkoutSession(
            durationMinutes: minutes,
            type: type,
            routineID: routineID,
            routineName: routineName,
            notes: notes
        )
        sessionHistory.insert(session, at: 0)
        evaluateAchievements()
    }

    func finalizeRoutineSession(_ routine: Routine, notes: String) {
        roundsCompleted += 1
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].completionCount += 1
        }
        recordSession(
            minutes: routine.estimatedMinutes,
            type: .routine,
            routineID: routine.id,
            routineName: routine.name,
            notes: notes
        )
    }

    func recordRoutineCompletion(_ routine: Routine) {
        registerStreak()
        roundsCompleted += 1
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].completionCount += 1
        }
        evaluateAchievements()
    }

    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        routinesCreated += 1
        registerStreak()
        evaluateAchievements()
    }

    func addRoutineFromTemplate(_ template: WorkoutTemplate, customName: String? = nil) {
        let routine = Routine(
            name: customName ?? template.name,
            exercises: template.exercises.map {
                Exercise(name: $0.name, repsOrDuration: $0.repsOrDuration)
            }
        )
        addRoutine(routine)
    }

    func updateRoutine(_ routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index] = routine
    }

    func duplicateRoutine(_ routine: Routine) {
        let copy = Routine(
            name: "\(routine.name) Copy",
            exercises: routine.exercises.map {
                Exercise(name: $0.name, repsOrDuration: $0.repsOrDuration)
            }
        )
        addRoutine(copy)
    }

    func archiveRoutine(_ routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].isArchived = true
    }

    func unarchiveRoutine(_ routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index].isArchived = false
    }

    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        let exerciseIDs = Set(routine.exercises.map(\.id))
        completedExerciseIDs.subtract(exerciseIDs)
    }

    func reorderExercises(in routineID: UUID, from source: IndexSet, to destination: Int) {
        guard let index = routines.firstIndex(where: { $0.id == routineID }),
              let fromIndex = source.first else { return }
        var items = routines[index].exercises
        let item = items.remove(at: fromIndex)
        let insertIndex = fromIndex < destination ? destination - 1 : destination
        items.insert(item, at: min(max(insertIndex, 0), items.count))
        routines[index].exercises = items
    }

    func toggleExerciseCompletion(_ exerciseID: UUID, in routine: Routine) -> Bool {
        if completedExerciseIDs.contains(exerciseID) {
            completedExerciseIDs.remove(exerciseID)
            return false
        } else {
            completedExerciseIDs.insert(exerciseID)
            let completed = routine.completedCount(completedIDs: completedExerciseIDs)
            return completed == routine.exercises.count
        }
    }

    func saveTimerPreset(name: String) {
        let preset = TimerPreset(
            name: name,
            workDurationSec: workDurationSec,
            restDurationSec: restDurationSec,
            roundsCount: roundsCount
        )
        timerPresets.append(preset)
    }

    func applyTimerPreset(_ preset: TimerPreset) {
        workDurationSec = preset.workDurationSec
        restDurationSec = preset.restDurationSec
        roundsCount = preset.roundsCount
        hasCustomizedTimer = true
    }

    func deleteTimerPreset(_ preset: TimerPreset) {
        timerPresets.removeAll { $0.id == preset.id }
    }

    func applyTemplateTimer(_ template: WorkoutTemplate) {
        if let work = template.timerWorkSec {
            workDurationSec = work
        }
        if let rest = template.timerRestSec {
            restDurationSec = rest
        }
        if let rounds = template.timerRounds {
            roundsCount = rounds
        }
        hasCustomizedTimer = true
    }

    func filteredSessions(type: SessionType?, routineID: UUID?) -> [WorkoutSession] {
        sessionHistory.filter { session in
            let typeMatch = type == nil || session.type == type
            let routineMatch = routineID == nil || session.routineID == routineID
            return typeMatch && routineMatch
        }
    }

    func filteredDailyStats(forWeekOffset offset: Int, type: SessionType?, routineID: UUID?) -> [DailyStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(byAdding: .day, value: -(6 + offset * 7), to: today) else {
            return []
        }

        return (0..<7).compactMap { dayIndex -> DailyStat? in
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: weekStart) else { return nil }
            let dayStart = calendar.startOfDay(for: date)
            let daySessions = filteredSessions(type: type, routineID: routineID).filter {
                calendar.isDate($0.date, inSameDayAs: dayStart)
            }
            let minutes = daySessions.reduce(0) { $0 + $1.durationMinutes }
            let sessions = daySessions.count
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return DailyStat(
                id: UUID(),
                date: dayStart,
                minutes: minutes,
                sessions: sessions,
                dayLabel: formatter.string(from: dayStart)
            )
        }
    }

    func activityDates(in month: Date) -> Set<Date> {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        var dates = Set<Date>()
        for session in sessionHistory {
            let day = calendar.startOfDay(for: session.date)
            if day >= monthInterval.start && day < monthInterval.end {
                dates.insert(day)
            }
        }
        return dates
    }

    func activityLevel(on date: Date) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let minutes = sessionHistory
            .filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
            .reduce(0) { $0 + $1.durationMinutes }
        if minutes == 0 { return 0 }
        if minutes < 20 { return 1 }
        if minutes < 45 { return 2 }
        return 3
    }

    func updateSessionNotes(_ sessionID: UUID, notes: String) {
        guard let index = sessionHistory.firstIndex(where: { $0.id == sessionID }) else { return }
        sessionHistory[index].notes = notes
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()

        hasSeenOnboarding = false
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        workDurationSec = 30
        restDurationSec = 15
        roundsCount = 5
        routines = []
        completedExerciseIDs = []
        roundsCompleted = 0
        longestSession = 0
        weeklyData = []
        routinesCreated = 0
        hasCustomizedTimer = false
        sessionHistory = []
        timerPresets = []
        weeklyGoalSessions = 3
        weeklyGoalMinutes = 90
        longestStreakEver = 0
        achievementQueue = []
        pendingAchievementBanner = nil

        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func dailyStats(forWeekOffset offset: Int) -> [DailyStat] {
        filteredDailyStats(forWeekOffset: offset, type: nil, routineID: nil)
    }

    func weekSummary(forWeekOffset offset: Int) -> WeekSummary {
        let stats = dailyStats(forWeekOffset: offset)
        return WeekSummary(
            sessions: stats.reduce(0) { $0 + $1.sessions },
            minutes: stats.reduce(0) { $0 + $1.minutes }
        )
    }

    private func mostSessionsInAnyWeek() -> Int {
        let calendar = Calendar.current
        var weekCounts: [Date: Int] = [:]
        for session in sessionHistory {
            let weekStart = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: session.date)
            ) ?? session.date
            weekCounts[weekStart, default: 0] += 1
        }
        return weekCounts.values.max() ?? 0
    }

    private func registerStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                return
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    private func addWeeklyEntry(minutes: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today

        if let index = weeklyData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            weeklyData[index].minutes += minutes
            weeklyData[index].sessions += 1
        } else {
            weeklyData.append(WeeklyStat(weekStart: weekStart, date: today, minutes: minutes, sessions: 1))
        }
    }

    private func evaluateAchievements() {
        let conditions: [(String, Bool)] = [
            ("first_step", totalSessionsCompleted >= 1),
            ("consistency_hero", streakDays >= 3),
            ("endurance_achiever", totalMinutesUsed >= 100),
            ("routine_master", roundsCompleted >= 5),
            ("milestone_marker", longestSession >= 60),
            ("week_streaker", streakDays >= 7),
            ("minute_accumulator", totalMinutesUsed >= 200),
            ("session_enthusiast", totalSessionsCompleted >= 10)
        ]

        for (id, unlocked) in conditions where unlocked && achievementsUnlocked[id] == nil {
            achievementsUnlocked[id] = Date()
            if let achievement = AchievementDefinition.all.first(where: { $0.id == id }) {
                enqueueAchievementBanner(achievement)
            }
        }
    }

    private func enqueueAchievementBanner(_ achievement: AchievementDefinition) {
        if pendingAchievementBanner == nil {
            pendingAchievementBanner = achievement
            FeedbackManager.success()
        } else {
            achievementQueue.append(achievement)
        }
    }

    func dismissAchievementBanner() {
        pendingAchievementBanner = nil
        if !achievementQueue.isEmpty {
            pendingAchievementBanner = achievementQueue.removeFirst()
            FeedbackManager.success()
        }
    }

    private func saveCodable<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadCodable<T: Decodable>(from defaults: UserDefaults, key: String, decoder: JSONDecoder) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private func saveDictionary(_ dict: [String: Date], forKey key: String) {
        let stringKeyed = dict.mapValues { $0.timeIntervalSince1970 }
        defaults.set(stringKeyed, forKey: key)
    }

    private static func loadDictionary(from defaults: UserDefaults, key: String) -> [String: Date] {
        guard let raw = defaults.dictionary(forKey: key) as? [String: Double] else { return [:] }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }

    private func saveUUIDSet(_ set: Set<UUID>, forKey key: String) {
        let strings = set.map(\.uuidString)
        defaults.set(strings, forKey: key)
    }

    private static func loadUUIDSet(from defaults: UserDefaults, key: String) -> Set<UUID> {
        guard let strings = defaults.stringArray(forKey: key) else { return [] }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }
}
