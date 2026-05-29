import Combine
import SwiftUI

enum TimerPhase: String {
    case work
    case rest
    case finished
}

struct ActiveTimerView: View {
    let workSec: Int
    let restSec: Int
    let rounds: Int
    let scenePhase: ScenePhase
    let onComplete: (Int) -> Void
    let onCancel: () -> Void

    @State private var currentRound = 1
    @State private var phase: TimerPhase = .work
    @State private var remainingSec: Int
    @State private var sessionStart = Date()
    @State private var isPaused = false
    @State private var timerActive = true
    @Environment(\.dismiss) private var dismiss

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        workSec: Int,
        restSec: Int,
        rounds: Int,
        scenePhase: ScenePhase,
        onComplete: @escaping (Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.workSec = workSec
        self.restSec = restSec
        self.rounds = rounds
        self.scenePhase = scenePhase
        self.onComplete = onComplete
        self.onCancel = onCancel
        _remainingSec = State(initialValue: workSec)
    }

    private var phaseProgress: Double {
        let total = progressTotal
        guard total > 0 else { return 0 }
        return Double(total - remainingSec) / Double(total)
    }

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        FeedbackManager.lightTap()
                        timerActive = false
                        onCancel()
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Cancel")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color("AppSurface"))
                        .clipShape(Capsule())
                    }
                    Spacer()
                    if isPaused {
                        TagPill(text: "Paused", color: Color("AppTextSecondary"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 28) {
                    TagPill(
                        text: phase == .work ? "WORK" : phase == .rest ? "REST" : "COMPLETE",
                        color: phase == .work ? Color("AppAccent") : phase == .rest ? Color("AppPrimary") : Color("AppAccent")
                    )

                    ZStack {
                        Circle()
                            .stroke(Color("AppTextSecondary").opacity(0.1), lineWidth: 14)
                            .frame(width: 220, height: 220)
                        Circle()
                            .trim(from: 0, to: phaseProgress)
                            .stroke(
                                AngularGradient(
                                    colors: phase == .work
                                        ? [Color("AppAccent"), Color("AppPrimary"), Color("AppAccent")]
                                        : [Color("AppPrimary").opacity(0.7), Color("AppAccent"), Color("AppPrimary").opacity(0.7)],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: phaseProgress)

                        VStack(spacing: 8) {
                            Text(formatTime(remainingSec))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .monospacedDigit()
                            Text("Round \(min(currentRound, rounds)) / \(rounds)")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .compositingGroup()
                    .shadow(color: Color("AppPrimary").opacity(0.25), radius: 16, y: 6)

                    HStack(spacing: 20) {
                        roundIndicator(label: "Work", value: workSec, active: phase == .work)
                        roundIndicator(label: "Rest", value: restSec, active: phase == .rest)
                    }
                }

                Spacer()

                if phase == .finished {
                    PrimaryButton(title: "Finish Session", icon: "checkmark.circle.fill") {
                        FeedbackManager.success()
                        timerActive = false
                        let elapsed = Int(Date().timeIntervalSince(sessionStart) / 60)
                        let minutes = max(elapsed, 1)
                        onComplete(minutes)
                        dismiss()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                } else {
                    Text("Stay focused — you've got this")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.bottom, 32)
                }
            }
        }
        .onReceive(timer) { _ in
            guard timerActive, !isPaused, phase != .finished else { return }
            if remainingSec > 1 {
                remainingSec -= 1
            } else {
                advancePhase()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            isPaused = newPhase != .active
        }
        .onAppear {
            sessionStart = Date()
        }
    }

    private var progressTotal: Int {
        switch phase {
        case .work: return workSec
        case .rest: return restSec
        case .finished: return 1
        }
    }

    private func roundIndicator(label: String, value: Int, active: Bool) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(active ? Color("AppAccent") : Color("AppTextSecondary"))
            Text("\(value)s")
                .font(.caption.monospacedDigit())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(
                    active
                        ? LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : AppGradients.surfaceFill()
                )
                .overlay {
                    Capsule()
                        .stroke(active ? Color("AppAccent").opacity(0.5) : Color("AppTextSecondary").opacity(0.15), lineWidth: 1)
                }
        }
    }

    private func advancePhase() {
        FeedbackManager.tick()
        switch phase {
        case .work:
            if currentRound >= rounds {
                phase = .finished
                remainingSec = 0
                FeedbackManager.sessionEntryComplete()
            } else if restSec > 0 {
                phase = .rest
                remainingSec = restSec
            } else {
                currentRound += 1
                phase = .work
                remainingSec = workSec
            }
        case .rest:
            currentRound += 1
            phase = .work
            remainingSec = workSec
        case .finished:
            break
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
