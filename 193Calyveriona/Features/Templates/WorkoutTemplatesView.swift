import SwiftUI

struct WorkoutTemplatesView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var customName = ""
    @State private var showSaveSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    AppCard(padding: 14, showBorder: false) {
                        HStack(spacing: 12) {
                            IconBadge(symbol: "sparkles", size: 40, iconSize: .body)
                            Text("Pick a template to jump-start your training. Save it as a routine or apply timer settings instantly.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    LazyVStack(spacing: 12) {
                        ForEach(WorkoutTemplate.builtIn) { template in
                            TemplateCell(template: template) {
                                FeedbackManager.lightTap()
                                selectedTemplate = template
                                customName = template.name
                                showSaveSheet = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color("AppBackground"))
            .navigationTitle("Workout Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSaveSheet) {
                if let template = selectedTemplate {
                    SaveTemplateSheet(
                        template: template,
                        customName: $customName,
                        onSaveAsRoutine: {
                            store.addRoutineFromTemplate(template, customName: customName)
                            FeedbackManager.success()
                            showSaveSheet = false
                        },
                        onApplyTimer: {
                            store.applyTemplateTimer(template)
                            FeedbackManager.success()
                            showSaveSheet = false
                        }
                    )
                }
            }
        }
    }
}

private struct SaveTemplateSheet: View {
    let template: WorkoutTemplate
    @Binding var customName: String
    let onSaveAsRoutine: () -> Void
    let onApplyTimer: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    IconBadge(symbol: template.systemImage, size: 64, iconSize: .title)
                        .padding(.top, 16)

                    AppCard {
                        TextField("Routine name", text: $customName)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }

                    AppCard(padding: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderView(title: "Included Exercises")
                            ForEach(template.exercises) { exercise in
                                HStack {
                                    Circle()
                                        .fill(Color("AppAccent").opacity(0.2))
                                        .frame(width: 6, height: 6)
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Spacer()
                                    Text(exercise.repsOrDuration)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                    }

                    if template.timerWorkSec != nil {
                        AppCard(padding: 14, showBorder: false) {
                            HStack {
                                IconBadge(symbol: "timer", size: 36, iconSize: .caption)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Timer Settings")
                                        .font(.caption.bold())
                                        .foregroundStyle(Color("AppTextSecondary"))
                                    Text("Work \(template.timerWorkSec ?? 0)s · Rest \(template.timerRestSec ?? 0)s · \(template.timerRounds ?? 0) rounds")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                                Spacer()
                            }
                        }

                        PrimaryButton(title: "Apply Timer Settings", icon: "timer") {
                            onApplyTimer()
                            dismiss()
                        }
                    }

                    PrimaryButton(title: "Save as My Routine", icon: "bookmark.fill") {
                        onSaveAsRoutine()
                        dismiss()
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle(template.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                }
            }
        }
    }
}
