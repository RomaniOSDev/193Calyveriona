import SwiftUI

struct IntervalTimerView: View {
    @StateObject private var viewModel = IntervalTimerViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.hasConfiguredInterval {
                        EmptyStateView(
                            symbol: "hourglass",
                            title: "Set Your First Interval",
                            subtitle: "Configure work, rest, and rounds below.",
                            actionTitle: "Quick Start",
                            action: { viewModel.incrementWork() }
                        )
                        .padding(.top, 12)
                    }

                    timerPresetsSection

                    VStack(spacing: 10) {
                        SectionHeaderView(title: "Interval Settings", subtitle: "Tap +/- to adjust")
                        TimerControlCell(
                            title: "Work",
                            icon: "bolt.fill",
                            value: viewModel.workDurationSec,
                            suffix: "sec",
                            onDecrement: viewModel.decrementWork,
                            onIncrement: viewModel.incrementWork
                        )
                        TimerControlCell(
                            title: "Rest",
                            icon: "pause.fill",
                            value: viewModel.restDurationSec,
                            suffix: "sec",
                            onDecrement: viewModel.decrementRest,
                            onIncrement: viewModel.incrementRest
                        )
                        TimerControlCell(
                            title: "Rounds",
                            icon: "repeat",
                            value: viewModel.roundsCount,
                            suffix: "",
                            onDecrement: viewModel.decrementRounds,
                            onIncrement: viewModel.incrementRounds
                        )
                    }
                    .padding(.horizontal, 16)

                    AppCard {
                        VStack(spacing: 16) {
                            SectionHeaderView(title: "Session Preview")
                            DurationRingView(
                                totalSeconds: viewModel.totalDurationSec,
                                progress: min(Double(viewModel.totalDurationSec) / 600.0, 1.0)
                            )
                            HStack(spacing: 16) {
                                miniStat(label: "Work", value: "\(viewModel.workDurationSec)s")
                                miniStat(label: "Rest", value: "\(viewModel.restDurationSec)s")
                                miniStat(label: "Rounds", value: "\(viewModel.roundsCount)")
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if let message = viewModel.validationMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                            .padding(.horizontal, 16)
                    }

                    PrimaryButton(title: "Start Session", icon: "play.fill") {
                        viewModel.startSession()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Interval Timer Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .overlay {
                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheck)
            }
            .fullScreenCover(isPresented: $viewModel.isSessionActive) {
                ActiveTimerView(
                    workSec: viewModel.workDurationSec,
                    restSec: viewModel.restDurationSec,
                    rounds: viewModel.roundsCount,
                    scenePhase: scenePhase,
                    onComplete: { minutes in
                        viewModel.completeSession(durationMinutes: minutes)
                    },
                    onCancel: {
                        viewModel.isSessionActive = false
                    }
                )
            }
            .sheet(isPresented: $viewModel.showSessionNotes) {
                SessionNotesSheet(
                    title: "Session Complete",
                    subtitle: "Add optional notes about your workout.",
                    onSave: { notes in viewModel.finalizeSession(notes: notes) },
                    onSkip: { viewModel.skipSessionNotes() }
                )
            }
            .sheet(isPresented: $viewModel.showSavePresetSheet) {
                SaveTimerPresetSheet(
                    presetName: $viewModel.presetName,
                    onSave: { viewModel.saveCurrentAsPreset() }
                )
            }
        }
    }

    private var timerPresetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(
                title: "Timer Presets",
                subtitle: "Quick-load saved configurations",
                actionTitle: "Save New",
                action: { viewModel.showSavePresetSheet = true }
            )

            if viewModel.timerPresets.isEmpty {
                AppCard(padding: 14, showBorder: false) {
                    HStack(spacing: 10) {
                        IconBadge(symbol: "bookmark", size: 36, iconSize: .caption)
                        Text("Save your current settings as a preset for one-tap access.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.timerPresets) { preset in
                            TimerPresetCell(
                                preset: preset,
                                onSelect: { viewModel.applyPreset(preset) },
                                onDelete: { viewModel.deletePreset(preset) }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func miniStat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color("AppBackground").opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct SaveTimerPresetSheet: View {
    @Binding var presetName: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                IconBadge(symbol: "bookmark.fill", size: 56, iconSize: .title2)
                    .padding(.top, 24)

                TextField("Preset name (e.g. Morning HIIT)", text: $presetName)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(14)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 16)

                PrimaryButton(title: "Save Preset", icon: "checkmark") {
                    FeedbackManager.mediumImpact()
                    onSave()
                    dismiss()
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color("AppBackground"))
            .navigationTitle("Save Preset")
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
        .presentationDetents([.medium])
    }
}
