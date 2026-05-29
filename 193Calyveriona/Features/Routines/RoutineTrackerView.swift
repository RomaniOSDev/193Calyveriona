import SwiftUI

struct RoutineTrackerView: View {
    var showNavigation: Bool = true
    @StateObject private var viewModel = RoutineTrackerViewModel()

    var body: some View {
        Group {
            if showNavigation {
                NavigationStack {
                    routineContent
                        .navigationTitle("Routine Tracker")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
            } else {
                routineContent
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            RoutineFormView(mode: .create) { name, exercises in
                viewModel.addRoutine(name: name, exercises: exercises)
            }
        }
        .sheet(item: $viewModel.editingRoutine) { routine in
            RoutineFormView(mode: .edit(routine)) { name, exercises in
                var updated = routine
                updated.name = name
                updated.exercises = exercises
                viewModel.updateRoutine(updated)
            }
        }
        .sheet(isPresented: $viewModel.showTemplates) {
            WorkoutTemplatesView()
        }
        .sheet(isPresented: $viewModel.showSessionNotes) {
            SessionNotesSheet(
                title: "Routine Complete",
                subtitle: "Great job! Add optional notes about this session.",
                onSave: { notes in viewModel.finalizeRoutineSession(notes: notes) },
                onSkip: { viewModel.skipRoutineNotes() }
            )
        }
    }

    private var routineContent: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                toolbarRow
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                if viewModel.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            symbol: "dumbbell",
                            title: "No Routines Yet - Tap to Create Your First Routine!",
                            actionTitle: "Browse Templates",
                            action: { viewModel.showTemplates = true }
                        )
                        .padding(.top, 32)
                        .onTapGesture {
                            FeedbackManager.lightTap()
                            viewModel.showAddSheet = true
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.routines) { routine in
                                NavigationLink {
                                    RoutineDetailView(routine: routine, viewModel: viewModel)
                                } label: {
                                    RoutineCell(
                                        routine: routine,
                                        completedCount: routine.completedCount(
                                            completedIDs: viewModel.completedExerciseIDs
                                        ),
                                        isPulsing: false
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        viewModel.editingRoutine = routine
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button {
                                        viewModel.duplicateRoutine(routine)
                                    } label: {
                                        Label("Duplicate", systemImage: "doc.on.doc")
                                    }
                                    if viewModel.showArchived {
                                        Button {
                                            viewModel.unarchiveRoutine(routine)
                                        } label: {
                                            Label("Restore", systemImage: "arrow.uturn.backward")
                                        }
                                    } else {
                                        Button {
                                            viewModel.archiveRoutine(routine)
                                        } label: {
                                            Label("Archive", systemImage: "archivebox")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }

            HStack(spacing: 12) {
                FloatingActionButton(icon: "doc.on.doc.fill", size: 48) {
                    viewModel.showTemplates = true
                }
                FloatingActionButton(icon: "plus") {
                    viewModel.showAddSheet = true
                }
            }
            .padding(24)
            .opacity(viewModel.isEmpty && !viewModel.showArchived ? 0 : 1)
        }
    }

    private var toolbarRow: some View {
        HStack {
            Button {
                FeedbackManager.lightTap()
                withAnimation { viewModel.showArchived.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.showArchived ? "tray.full.fill" : "tray")
                    Text(viewModel.showArchived ? "Archived" : "Active")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(viewModel.showArchived ? Color("AppPrimary").opacity(0.3) : Color("AppSurface"))
                .clipShape(Capsule())
            }

            Spacer()

            Text("\(viewModel.routines.count) routine\(viewModel.routines.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }
}

struct RoutineDetailView: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutineTrackerViewModel
    @State private var exercises: [Exercise] = []
    @State private var editMode: EditMode = .inactive

    private var completed: Int {
        routine.completedCount(completedIDs: viewModel.completedExerciseIDs)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    HStack(spacing: 16) {
                        ProgressRingView(
                            progress: Double(completed) / Double(max(exercises.count, 1)),
                            lineWidth: 6,
                            size: 64
                        )
                        VStack(alignment: .leading, spacing: 6) {
                            Text(routine.name)
                                .font(.title3.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("\(completed) of \(exercises.count) completed")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            if routine.completionCount > 0 {
                                TagPill(text: "Completed \(routine.completionCount)×", color: Color("AppPrimary"))
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                SectionHeaderView(
                    title: "Exercises",
                    subtitle: "Swipe left on an exercise to mark complete"
                )
                .padding(.horizontal, 16)

                List {
                    ForEach(exercises) { exercise in
                        ExerciseCell(
                            exercise: exercise,
                            isCompleted: viewModel.completedExerciseIDs.contains(exercise.id),
                            isPulsing: viewModel.pulsingExerciseID == exercise.id,
                            showCheckmark: viewModel.showCheckmarkForExercise == exercise.id
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button {
                                if let current = viewModel.fetchRoutine(id: routine.id) {
                                    viewModel.markComplete(exercise: exercise, in: current)
                                }
                            } label: {
                                Label("Done", systemImage: "checkmark")
                            }
                            .tint(Color("AppPrimary"))
                        }
                    }
                    .onMove { source, destination in
                        exercises.move(fromOffsets: source, toOffset: destination)
                        if var updated = viewModel.fetchRoutine(id: routine.id) {
                            updated.exercises = exercises
                            viewModel.updateRoutine(updated)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(minHeight: CGFloat(exercises.count) * 72 + 20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    FeedbackManager.lightTap()
                    editMode = editMode == .active ? .inactive : .active
                } label: {
                    Text(editMode == .active ? "Done" : "Reorder")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .onAppear {
            exercises = viewModel.fetchRoutine(id: routine.id)?.exercises ?? routine.exercises
        }
    }
}

enum RoutineFormMode {
    case create
    case edit(Routine)

    var title: String {
        switch self {
        case .create: return "New Routine"
        case .edit: return "Edit Routine"
        }
    }

    var initialName: String {
        switch self {
        case .create: return ""
        case .edit(let routine): return routine.name
        }
    }

    var initialExercises: [Exercise] {
        switch self {
        case .create: return []
        case .edit(let routine): return routine.exercises
        }
    }
}

struct RoutineFormView: View {
    let mode: RoutineFormMode
    let onSave: (String, [Exercise]) -> Void

    init(mode: RoutineFormMode = .create, onSave: @escaping (String, [Exercise]) -> Void) {
        self.mode = mode
        self.onSave = onSave
    }

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var exerciseName = ""
    @State private var exerciseDetail = ""
    @State private var exercises: [Exercise] = []
    @State private var errorMessage: String?
    @State private var shakeTrigger: CGFloat = 0
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Routine Name")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextSecondary"))
                            TextField("Enter name", text: $name)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Exercise")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextSecondary"))
                            TextField("Exercise name", text: $exerciseName)
                                .foregroundStyle(Color("AppTextPrimary"))
                            TextField("Reps or duration", text: $exerciseDetail)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Button {
                                FeedbackManager.lightTap()
                                addExercise()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Exercise")
                                }
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppPrimary"))
                            }
                        }
                    }

                    if !exercises.isEmpty {
                        SectionHeaderView(title: "Exercises (\(exercises.count))")
                        List {
                            ForEach(exercises) { exercise in
                                ExerciseCell(exercise: exercise, isCompleted: false)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                            .onDelete { indexSet in
                                exercises.remove(atOffsets: indexSet)
                            }
                            .onMove { source, destination in
                                exercises.move(fromOffsets: source, toOffset: destination)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: CGFloat(exercises.count) * 68 + 20)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .modifier(ShakeEffect(animatableData: shakeTrigger))
                    }

                    PrimaryButton(title: "Save Routine", icon: "checkmark") {
                        saveRoutine()
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                }
                if !exercises.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(editMode == .active ? "Done" : "Reorder") {
                            editMode = editMode == .active ? .inactive : .active
                        }
                        .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .onAppear {
                name = mode.initialName
                exercises = mode.initialExercises
            }
        }
    }

    private func addExercise() {
        guard !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Enter an exercise name.")
            return
        }
        exercises.append(Exercise(
            name: exerciseName.trimmingCharacters(in: .whitespaces),
            repsOrDuration: exerciseDetail.isEmpty ? "—" : exerciseDetail
        ))
        exerciseName = ""
        exerciseDetail = ""
        FeedbackManager.lightTap()
    }

    private func saveRoutine() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Routine name is required.")
            return
        }
        guard !exercises.isEmpty else {
            showError("Add at least one exercise.")
            return
        }
        FeedbackManager.success()
        onSave(name, exercises)
        dismiss()
    }

    private func showError(_ message: String) {
        errorMessage = message
        shakeTrigger += 1
        FeedbackManager.warning()
    }
}
