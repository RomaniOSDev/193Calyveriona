import SwiftUI

// MARK: - Card shell

struct AppCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 18
    var showBorder: Bool = true
    var elevation: AppElevation = .raised
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                AppSurfaceShape(
                    cornerRadius: cornerRadius,
                    showBorder: showBorder,
                    showSheen: true
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .appElevation(elevation)
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: {
                    FeedbackManager.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}

// MARK: - Icon badge

struct IconBadge: View {
    let symbol: String
    var size: CGFloat = 44
    var iconSize: Font = .title3
    var tint: Color = Color("AppAccent")
    var background: Color = Color("AppPrimary")

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            background.opacity(0.55),
                            background.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .stroke(AppGradients.borderStroke(), lineWidth: 0.8)
            Image(systemName: symbol)
                .font(iconSize.weight(.semibold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .shadow(color: Color("AppPrimary").opacity(0.22), radius: 4, y: 2)
    }
}

// MARK: - Metric tile

struct MetricTileCell: View {
    let icon: String
    let title: String
    let value: String
    var delta: String?
    var accent: Color = Color("AppAccent")

    var body: some View {
        AppCard(padding: 14, showBorder: false) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    IconBadge(symbol: icon, size: 38, iconSize: .body, tint: accent, background: Color("AppPrimary"))
                    Spacer()
                    if let delta {
                        Text(delta)
                            .font(.caption.bold())
                            .foregroundStyle(accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(accent.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}

// MARK: - Stat row (tappable)

struct StatRowCell: View {
    let icon: String
    let title: String
    let value: String
    var subtitle: String?

    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 14) {
                IconBadge(symbol: icon, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(value)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
                    .padding(8)
                    .background(Color("AppBackground").opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Navigation link cell

struct NavLinkCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var badge: String?

    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 14) {
                IconBadge(symbol: icon, size: 42, iconSize: .body)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("AppPrimary").opacity(0.35))
                        .clipShape(Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
            }
        }
    }
}

// MARK: - Settings cell

struct SettingsRowCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(
                symbol: icon,
                size: 40,
                iconSize: .body,
                tint: isDestructive ? .red : Color("AppAccent"),
                background: isDestructive ? .red : Color("AppPrimary")
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

// MARK: - Filter chip

struct FilterChipCell: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(AppGradients.primaryFill())
                            .overlay {
                                Capsule().fill(AppGradients.topSheen())
                            }
                    } else {
                        Capsule()
                            .fill(AppGradients.surfaceFill())
                            .overlay {
                                Capsule()
                                    .stroke(Color("AppTextSecondary").opacity(0.18), lineWidth: 1)
                            }
                    }
                }
                .compositingGroup()
                .shadow(
                    color: isSelected ? Color("AppPrimary").opacity(0.35) : .clear,
                    radius: isSelected ? 6 : 0,
                    y: isSelected ? 2 : 0
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Routine cell

struct RoutineCell: View {
    let routine: Routine
    let completedCount: Int
    var isPulsing: Bool = false

    private var progress: Double {
        guard !routine.exercises.isEmpty else { return 0 }
        return Double(completedCount) / Double(routine.exercises.count)
    }

    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 14) {
                ProgressRingView(progress: progress, lineWidth: 5, size: 52)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(routine.name)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                        if routine.isArchived {
                            TagPill(text: "Archived", color: Color("AppTextSecondary"))
                        }
                    }

                    if let first = routine.exercises.first {
                        Text("\(first.name) · \(first.repsOrDuration)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        TagPill(text: "\(routine.exercises.count) exercises", color: Color("AppAccent"))
                        if routine.completionCount > 0 {
                            TagPill(text: "\(routine.completionCount)× done", color: Color("AppPrimary"))
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
            }
        }
        .overlay {
            if isPulsing {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color("AppAccent"), lineWidth: 2)
                    .opacity(0.6)
            }
        }
    }
}

struct TagPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background {
                Capsule()
                    .fill(color.opacity(0.14))
                    .overlay {
                        Capsule()
                            .stroke(color.opacity(0.28), lineWidth: 0.8)
                    }
            }
    }
}

struct ProgressRingView: View {
    let progress: Double
    var lineWidth: CGFloat = 6
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppTextSecondary").opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1))
                .stroke(
                    LinearGradient(
                        colors: [Color("AppAccent"), Color("AppPrimary")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption2.bold().monospacedDigit())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Exercise cell

struct ExerciseCell: View {
    let exercise: Exercise
    let isCompleted: Bool
    var isPulsing: Bool = false
    var showCheckmark: Bool = false

    var body: some View {
        AppCard(padding: 12, showBorder: isCompleted) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color("AppAccent").opacity(0.2) : Color("AppBackground").opacity(0.6))
                        .frame(width: 32, height: 32)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                    } else {
                        Circle()
                            .stroke(Color("AppTextSecondary").opacity(0.4), lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isCompleted ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                        .strikethrough(isCompleted, color: Color("AppTextSecondary"))
                    Text(exercise.repsOrDuration)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                Spacer()

                if showCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppAccent"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .overlay {
            if isPulsing {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppAccent").opacity(0.12))
            }
        }
    }
}

// MARK: - Session history cell

struct SessionHistoryCell: View {
    let session: WorkoutSession

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }

    private var relativeDay: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(session.date) { return "Today" }
        if calendar.isDateInYesterday(session.date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: session.date)
    }

    var body: some View {
        AppCard(padding: 14) {
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 0) {
                    IconBadge(
                        symbol: session.type.systemImage,
                        size: 46,
                        iconSize: .body,
                        tint: session.type == .timer ? Color("AppAccent") : Color("AppPrimary"),
                        background: Color("AppPrimary")
                    )
                    Rectangle()
                        .fill(Color("AppTextSecondary").opacity(0.15))
                        .frame(width: 2, height: 20)
                        .padding(.top, 4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(relativeDay)
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppPrimary"))
                        Spacer()
                        DurationBadge(minutes: session.durationMinutes)
                    }

                    Text(session.routineName ?? session.type.label)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)

                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))

                    if !session.notes.isEmpty {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "quote.opening")
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent").opacity(0.7))
                            Text(session.notes)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextPrimary").opacity(0.85))
                                .lineLimit(3)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("AppBackground").opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }
}

struct DurationBadge: View {
    let minutes: Int

    var body: some View {
        Text("\(minutes) min")
            .font(.caption.bold())
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(AppGradients.primaryFill())
                    .overlay { Capsule().fill(AppGradients.topSheen()) }
            }
            .compositingGroup()
            .shadow(color: Color("AppPrimary").opacity(0.3), radius: 4, y: 2)
    }
}

// MARK: - Timer control cell

struct TimerControlCell: View {
    let title: String
    let icon: String
    let value: Int
    let suffix: String
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        AppCard(padding: 12, showBorder: false) {
            HStack(spacing: 12) {
                IconBadge(symbol: icon, size: 36, iconSize: .caption)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))

                Spacer()

                HStack(spacing: 4) {
                    CircleButton(symbol: "minus", action: onDecrement)
                    Text("\(value)\(suffix.isEmpty ? "" : " \(suffix)")")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(minWidth: 72)
                        .multilineTextAlignment(.center)
                    CircleButton(symbol: "plus", action: onIncrement)
                }
            }
        }
    }
}

struct CircleButton: View {
    let symbol: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.body.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 36, height: 36)
                .background(
            Circle()
                .fill(
                    isPressed
                        ? Color("AppPrimary").opacity(0.55)
                        : Color("AppPrimary").opacity(0.9)
                )
                .overlay {
                    Circle().fill(AppGradients.topSheen())
                }
                )
                .scaleEffect(isPressed ? 0.92 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Timer preset chip

struct TimerPresetCell: View {
    let preset: TimerPreset
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Menu {
            Button("Apply", action: onSelect)
            Button("Delete", role: .destructive, action: onDelete)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(preset.name)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                }
                Text(formatDuration(preset.totalDurationSec))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(Color("AppTextSecondary"))
                Text("\(preset.workDurationSec)s / \(preset.restDurationSec)s · \(preset.roundsCount) rnd")
                    .font(.system(size: 9))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.8))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("AppPrimary").opacity(0.18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.3), lineWidth: 1)
                    }
            )
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Template cell

struct TemplateCell: View {
    let template: WorkoutTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            AppCard(padding: 14) {
                HStack(spacing: 14) {
                    IconBadge(
                        symbol: template.systemImage,
                        size: 52,
                        iconSize: .title3,
                        tint: Color("AppAccent"),
                        background: Color("AppPrimary")
                    )

                    VStack(alignment: .leading, spacing: 5) {
                        Text(template.name)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(template.description)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 6) {
                            TagPill(text: "\(template.exercises.count) exercises", color: Color("AppAccent"))
                            if template.timerWorkSec != nil {
                                TagPill(text: "Timer included", color: Color("AppPrimary"))
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Achievement cell

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        AppCard(padding: 14, showBorder: isUnlocked, elevation: isUnlocked ? .floating : .raised) {
            VStack(spacing: 10) {
                ZStack {
                    if isUnlocked {
                        Circle()
                            .fill(Color("AppAccent").opacity(0.2))
                            .frame(width: 56, height: 56)
                    }
                    IconBadge(
                        symbol: achievement.systemImage,
                        size: 50,
                        iconSize: .title3,
                        tint: isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.35),
                        background: isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary")
                    )
                }

                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)

                if isUnlocked {
                    TagPill(text: "Unlocked", color: Color("AppAccent"))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 150)
        }
        .opacity(isUnlocked ? 1 : 0.72)
    }
}

// MARK: - Record cell

struct RecordCell: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    var rank: Int?

    var body: some View {
        AppCard(padding: 14) {
            HStack(spacing: 14) {
                IconBadge(symbol: icon, size: 48, iconSize: .title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(value)
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                if let rank {
                    Text("#\(rank)")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .padding(8)
                        .background(Color("AppAccent").opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Primary button

struct PrimaryButton: View {
    let title: String
    var icon: String?
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .appPrimaryButtonBackground(cornerRadius: 16)
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}

// MARK: - FAB

struct FloatingActionButton: View {
    let icon: String
    var size: CGFloat = 56
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .fill(AppGradients.primaryFill())
                        .overlay { Circle().fill(AppGradients.topSheen()) }
                }
                .appElevation(.floating)
                .scaleEffect(isPressed ? 0.93 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Segmented pill toggle

struct PillSegmentControl: View {
    let options: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = index
                    }
                } label: {
                    Text(options[index])
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(selection == index ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selection == index {
                                Capsule()
                                    .fill(AppGradients.primaryFill())
                                    .overlay { Capsule().fill(AppGradients.topSheen()) }
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(AppGradients.surfaceFill())
                .overlay { Capsule().stroke(AppGradients.borderStroke(), lineWidth: 1) }
        }
        .appElevation(.raised)
    }
}

// MARK: - Duration ring (timer display)

struct DurationRingView: View {
    let totalSeconds: Int
    var progress: Double = 1

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppTextSecondary").opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text(formatDuration(totalSeconds))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .monospacedDigit()
                Text("total duration")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .frame(width: 140, height: 140)
    }

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Summary strip

struct SummaryStripCell: View {
    let items: [(String, String, String)]

    var body: some View {
        AppCard(padding: 0, showBorder: true) {
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 6) {
                        IconBadge(symbol: item.2, size: 32, iconSize: .caption2)
                        Text(item.1)
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(item.0)
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)

                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Color("AppTextSecondary").opacity(0.15))
                            .frame(width: 1, height: 50)
                    }
                }
            }
        }
    }
}
