import Combine
import Foundation

final class RoutineTrackerViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showTemplates = false
    @Published var showArchived = false
    @Published var editingRoutine: Routine?
    @Published var pulsingExerciseID: UUID?
    @Published var showCheckmarkForExercise: UUID?
    @Published var routineAwaitingNotes: Routine?
    @Published var showSessionNotes = false

    let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    var routines: [Routine] {
        showArchived ? store.archivedRoutines : store.activeRoutines
    }

    var completedExerciseIDs: Set<UUID> {
        store.completedExerciseIDs
    }

    var isEmpty: Bool {
        routines.isEmpty && !showArchived
    }

    func fetchRoutine(id: UUID) -> Routine? {
        store.routines.first { $0.id == id }
    }

    func markComplete(exercise: Exercise, in routine: Routine) {
        let wasCompleted = store.completedExerciseIDs.contains(exercise.id)
        let allDone = store.toggleExerciseCompletion(exercise.id, in: routine)
        if !wasCompleted {
            FeedbackManager.completeItem()
            showCheckmarkForExercise = exercise.id
            pulsingExerciseID = exercise.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.pulsingExerciseID = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.showCheckmarkForExercise == exercise.id {
                    self.showCheckmarkForExercise = nil
                }
            }
            if allDone, let current = fetchRoutine(id: routine.id) {
                routineAwaitingNotes = current
                showSessionNotes = true
            }
        }
    }

    func finalizeRoutineSession(notes: String) {
        guard let routine = routineAwaitingNotes else { return }
        store.finalizeRoutineSession(routine, notes: notes)
        FeedbackManager.success()
        routineAwaitingNotes = nil
    }

    func skipRoutineNotes() {
        finalizeRoutineSession(notes: "")
    }

    func addRoutine(name: String, exercises: [Exercise]) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty, !exercises.isEmpty else { return }
        let routine = Routine(name: name.trimmingCharacters(in: .whitespaces), exercises: exercises)
        store.addRoutine(routine)
        FeedbackManager.success()
        showAddSheet = false
    }

    func updateRoutine(_ routine: Routine) {
        store.updateRoutine(routine)
        FeedbackManager.success()
        editingRoutine = nil
    }

    func duplicateRoutine(_ routine: Routine) {
        store.duplicateRoutine(routine)
        FeedbackManager.success()
    }

    func archiveRoutine(_ routine: Routine) {
        store.archiveRoutine(routine)
        FeedbackManager.lightTap()
    }

    func unarchiveRoutine(_ routine: Routine) {
        store.unarchiveRoutine(routine)
        FeedbackManager.lightTap()
    }

    func deleteRoutine(_ routine: Routine) {
        store.deleteRoutine(routine)
        FeedbackManager.warning()
    }

    func reorderExercises(in routineID: UUID, from source: IndexSet, to destination: Int) {
        store.reorderExercises(in: routineID, from: source, to: destination)
    }
}
