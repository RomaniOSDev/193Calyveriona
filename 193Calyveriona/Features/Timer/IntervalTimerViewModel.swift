import SwiftUI
import Combine

final class IntervalTimerViewModel: ObservableObject {
    @Published var workDurationSec: Int
    @Published var restDurationSec: Int
    @Published var roundsCount: Int
    @Published var isSessionActive = false
    @Published var validationMessage: String?
    @Published var shakeTrigger: CGFloat = 0
    @Published var startButtonScale: CGFloat = 1
    @Published var showSuccessCheck = false
    @Published var showSessionNotes = false
    @Published var pendingSessionMinutes: Int?
    @Published var showSavePresetSheet = false
    @Published var presetName = ""

    private let store: AppDataStore
    private var cancellables = Set<AnyCancellable>()

    init(store: AppDataStore = .shared) {
        self.store = store
        workDurationSec = store.workDurationSec
        restDurationSec = store.restDurationSec
        roundsCount = store.roundsCount

        $workDurationSec
            .dropFirst()
            .sink { [weak self] value in self?.store.workDurationSec = value }
            .store(in: &cancellables)

        $restDurationSec
            .dropFirst()
            .sink { [weak self] value in self?.store.restDurationSec = value }
            .store(in: &cancellables)

        $roundsCount
            .dropFirst()
            .sink { [weak self] value in self?.store.roundsCount = value }
            .store(in: &cancellables)
    }

    var timerPresets: [TimerPreset] {
        store.timerPresets
    }

    var totalDurationSec: Int {
        workDurationSec * roundsCount + restDurationSec * max(roundsCount - 1, 0)
    }

    var hasConfiguredInterval: Bool {
        store.hasCustomizedTimer
    }

    func markTimerConfigured() {
        store.hasCustomizedTimer = true
    }

    func incrementWork() {
        markTimerConfigured()
        workDurationSec = min(workDurationSec + 5, 600)
    }

    func decrementWork() {
        markTimerConfigured()
        workDurationSec = max(workDurationSec - 5, 5)
    }

    func incrementRest() {
        markTimerConfigured()
        restDurationSec = min(restDurationSec + 5, 300)
    }

    func decrementRest() {
        markTimerConfigured()
        restDurationSec = max(restDurationSec - 5, 0)
    }

    func incrementRounds() {
        markTimerConfigured()
        roundsCount = min(roundsCount + 1, 50)
    }

    func decrementRounds() {
        markTimerConfigured()
        roundsCount = max(roundsCount - 1, 1)
    }

    func applyPreset(_ preset: TimerPreset) {
        FeedbackManager.lightTap()
        store.applyTimerPreset(preset)
        workDurationSec = preset.workDurationSec
        restDurationSec = preset.restDurationSec
        roundsCount = preset.roundsCount
    }

    func saveCurrentAsPreset() {
        let trimmed = presetName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            validationMessage = "Preset name is required."
            shakeTrigger += 1
            FeedbackManager.warning()
            return
        }
        store.saveTimerPreset(name: trimmed)
        FeedbackManager.success()
        presetName = ""
        showSavePresetSheet = false
    }

    func deletePreset(_ preset: TimerPreset) {
        FeedbackManager.lightTap()
        store.deleteTimerPreset(preset)
    }

    func startSession() {
        guard workDurationSec >= 5, roundsCount >= 1 else {
            validationMessage = "Work must be at least 5 sec and rounds at least 1."
            shakeTrigger += 1
            FeedbackManager.warning()
            return
        }
        validationMessage = nil
        markTimerConfigured()
        FeedbackManager.startSession()
        startButtonScale = 1.08
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.startButtonScale = 1
        }
        isSessionActive = true
    }

    func completeSession(durationMinutes: Int) {
        pendingSessionMinutes = durationMinutes
        showSessionNotes = true
        isSessionActive = false
    }

    func finalizeSession(notes: String) {
        guard let minutes = pendingSessionMinutes else { return }
        store.recordSession(minutes: minutes, type: .timer, notes: notes)
        FeedbackManager.success()
        showSuccessCheck = true
        pendingSessionMinutes = nil
    }

    func skipSessionNotes() {
        finalizeSession(notes: "")
    }
}
