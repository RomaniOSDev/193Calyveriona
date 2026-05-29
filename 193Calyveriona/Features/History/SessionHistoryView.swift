import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var filterType: SessionType?
    @State private var filterRoutineID: UUID?

    private var sessions: [WorkoutSession] {
        store.filteredSessions(type: filterType, routineID: filterRoutineID)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                filterSection
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if sessions.isEmpty {
                    EmptyStateView(
                        symbol: "clock.arrow.circlepath",
                        title: "No Sessions Yet",
                        subtitle: "Complete a timer or routine workout to see history here."
                    )
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(sessions) { session in
                            SessionHistoryCell(session: session)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Session History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filterSection: some View {
        AppCard(padding: 12, showBorder: false) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Filter")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChipCell(title: "All", isSelected: filterType == nil && filterRoutineID == nil) {
                            filterType = nil
                            filterRoutineID = nil
                        }
                        ForEach(SessionType.allCases, id: \.self) { type in
                            FilterChipCell(title: type.label, isSelected: filterType == type && filterRoutineID == nil) {
                                filterType = type
                                if type == .timer { filterRoutineID = nil }
                            }
                        }
                    }
                }
                if filterType != .timer {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChipCell(title: "All Routines", isSelected: filterRoutineID == nil) {
                                filterRoutineID = nil
                            }
                            ForEach(store.activeRoutines) { routine in
                                FilterChipCell(title: routine.name, isSelected: filterRoutineID == routine.id) {
                                    filterRoutineID = routine.id
                                    filterType = .routine
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
