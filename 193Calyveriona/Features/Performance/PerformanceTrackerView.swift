import SwiftUI

struct PerformanceTrackerView: View {
    var showNavigation: Bool = true
    @StateObject private var viewModel = PerformanceTrackerViewModel()
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        Group {
            if showNavigation {
                NavigationStack {
                    performanceContent
                        .navigationTitle("Your Performance")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
            } else {
                performanceContent
            }
        }
        .sheet(item: $viewModel.selectedStat) { stat in
            StatDetailView(
                title: stat.title,
                icon: stat.icon,
                detail: viewModel.detailText(for: stat)
            )
        }
    }

    private var performanceContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                filterSection

                WeeklyGoalsCard()
                    .padding(.horizontal, 16)

                WeekComparisonCard()
                    .padding(.horizontal, 16)

                weekChartSection

                navigationLinks

                VStack(spacing: 12) {
                    ForEach([
                        PerformanceTrackerViewModel.StatType.sessions,
                        .minutes,
                        .average
                    ]) { stat in
                        Button {
                            FeedbackManager.lightTap()
                            viewModel.selectedStat = stat
                        } label: {
                            StatRowCell(
                                icon: stat.icon,
                                title: stat.title,
                                value: viewModel.value(for: stat),
                                subtitle: "Tap for details"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private var filterSection: some View {
        AppCard(padding: 12, showBorder: false) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Filters")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChipCell(title: "All", isSelected: viewModel.filterType == nil && viewModel.filterRoutineID == nil) {
                            viewModel.filterType = nil
                            viewModel.filterRoutineID = nil
                        }
                        ForEach(SessionType.allCases, id: \.self) { type in
                            FilterChipCell(title: type.label, isSelected: viewModel.filterType == type && viewModel.filterRoutineID == nil) {
                                viewModel.filterType = type
                                viewModel.filterRoutineID = nil
                            }
                        }
                    }
                }
                if !store.activeRoutines.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.activeRoutines) { routine in
                                FilterChipCell(title: routine.name, isSelected: viewModel.filterRoutineID == routine.id) {
                                    viewModel.filterRoutineID = routine.id
                                    viewModel.filterType = .routine
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var navigationLinks: some View {
        VStack(spacing: 10) {
            NavigationLink {
                SessionHistoryView()
            } label: {
                NavLinkCell(
                    icon: "clock.arrow.circlepath",
                    title: "Session History",
                    subtitle: "All completed workouts",
                    badge: store.sessionHistory.isEmpty ? nil : "\(store.sessionHistory.count)"
                )
            }
            NavigationLink {
                ActivityCalendarView()
            } label: {
                NavLinkCell(
                    icon: "calendar",
                    title: "Activity Calendar",
                    subtitle: "Monthly heatmap view"
                )
            }
            NavigationLink {
                RecordsView()
            } label: {
                NavLinkCell(
                    icon: "trophy.fill",
                    title: "Personal Records",
                    subtitle: "Your all-time bests"
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private var weekChartSection: some View {
        AppCard {
            VStack(spacing: 14) {
                HStack {
                    Button {
                        viewModel.shiftWeek(forward: false)
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 36, height: 36)
                            .background(Color("AppBackground").opacity(0.5))
                            .clipShape(Circle())
                    }
                    .foregroundStyle(Color("AppPrimary"))

                    Spacer()

                    VStack(spacing: 2) {
                        Text(weekLabel)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Activity chart")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Spacer()

                    Button {
                        viewModel.shiftWeek(forward: true)
                    } label: {
                        Image(systemName: "chevron.right")
                            .frame(width: 36, height: 36)
                            .background(Color("AppBackground").opacity(0.5))
                            .clipShape(Circle())
                    }
                    .foregroundStyle(viewModel.weekOffset > 0 ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3))
                    .disabled(viewModel.weekOffset == 0)
                }

                if viewModel.hasData {
                    WeeklyBarChartView(
                        stats: viewModel.dailyStats,
                        maxMinutes: viewModel.maxMinutes
                    )
                    .frame(height: 180)
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if value.translation.width < -40 {
                                    viewModel.shiftWeek(forward: false)
                                } else if value.translation.width > 40, viewModel.weekOffset > 0 {
                                    viewModel.shiftWeek(forward: true)
                                }
                            }
                    )
                } else {
                    EmptyStateView(
                        symbol: "chart.bar.fill",
                        title: "Start your journey today!",
                        subtitle: "Start exercising to see your progress here!"
                    )
                    .frame(height: 160)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var weekLabel: String {
        if viewModel.weekOffset == 0 {
            return "This Week"
        }
        return "\(viewModel.weekOffset) week\(viewModel.weekOffset == 1 ? "" : "s") ago"
    }
}

struct WeeklyBarChartView: View {
    let stats: [DailyStat]
    let maxMinutes: Int

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let barCount = CGFloat(max(stats.count, 1))
                let spacing: CGFloat = 8
                let barWidth = (size.width - spacing * (barCount - 1)) / barCount

                for (index, stat) in stats.enumerated() {
                    let barHeight = size.height * 0.7 * CGFloat(stat.minutes) / CGFloat(maxMinutes)
                    let x = CGFloat(index) * (barWidth + spacing)
                    let y = size.height * 0.75 - barHeight
                    let rect = CGRect(x: x, y: y, width: barWidth, height: max(barHeight, 4))
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 4),
                        with: .color(stat.minutes > 0 ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.3))
                    )

                    let label = Text(stat.dayLabel)
                        .font(.caption2)
                        .foregroundColor(Color("AppTextSecondary"))
                    context.draw(label, at: CGPoint(x: x + barWidth / 2, y: size.height * 0.92))
                }
            }
        }
    }
}

struct StatDetailView: View {
    let title: String
    let icon: String
    let detail: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    IconBadge(symbol: icon, size: 72, iconSize: .largeTitle)
                        .padding(.top, 32)

                    AppCard {
                        Text(detail)
                            .font(.body)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(Color("AppBackground"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                }
            }
        }
    }
}
