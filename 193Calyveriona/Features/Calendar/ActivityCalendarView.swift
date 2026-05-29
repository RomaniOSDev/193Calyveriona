import SwiftUI

struct ActivityCalendarView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                monthHeader
                AppCard(padding: 14) {
                    VStack(spacing: 10) {
                        weekdayHeader
                        daysGrid
                    }
                }
                legend
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Activity Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var monthHeader: some View {
        AppCard(padding: 12, showBorder: false) {
            HStack {
                Button {
                    FeedbackManager.lightTap()
                    shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 36, height: 36)
                        .background(Color("AppBackground").opacity(0.5))
                        .clipShape(Circle())
                }
                .foregroundStyle(Color("AppPrimary"))

                Spacer()

                VStack(spacing: 2) {
                    Text(monthTitle)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(activeDaysCount) active days")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                Spacer()

                Button {
                    FeedbackManager.lightTap()
                    shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 36, height: 36)
                        .background(Color("AppBackground").opacity(0.5))
                        .clipShape(Circle())
                }
                .foregroundStyle(canGoForward ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3))
                .disabled(!canGoForward)
            }
        }
    }

    private var activeDaysCount: Int {
        store.activityDates(in: displayedMonth).count
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol.prefix(2).uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                if let day {
                    DayCell(date: day, level: store.activityLevel(on: day))
                } else {
                    Color.clear.frame(height: 38)
                }
            }
        }
    }

    private var legend: some View {
        AppCard(padding: 12, showBorder: false) {
            HStack(spacing: 0) {
                legendItem(level: 0, label: "None")
                legendItem(level: 1, label: "Light")
                legendItem(level: 2, label: "Moderate")
                legendItem(level: 3, label: "Intense")
            }
        }
    }

    private func legendItem(level: Int, label: String) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(heatColor(for: level))
                .frame(width: 20, height: 20)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var canGoForward: Bool {
        guard let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return false }
        return next <= Date()
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leadingEmpty)
        var date = monthInterval.start
        while date < monthInterval.end {
            days.append(date)
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return days
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation { displayedMonth = newMonth }
        }
    }

    private func heatColor(for level: Int) -> Color {
        switch level {
        case 0: return Color("AppTextSecondary").opacity(0.12)
        case 1: return Color("AppAccent").opacity(0.35)
        case 2: return Color("AppAccent").opacity(0.65)
        default: return Color("AppPrimary")
        }
    }
}

private struct DayCell: View {
    let date: Date
    let level: Int

    private var dayNumber: String {
        String(Calendar.current.component(.day, from: date))
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(heatColor)
            Text(dayNumber)
                .font(.caption2.bold())
                .foregroundStyle(level > 0 ? Color("AppTextPrimary") : Color("AppTextSecondary"))
        }
        .frame(height: 38)
        .overlay {
            if isToday {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("AppAccent"), lineWidth: 2)
            }
        }
    }

    private var heatColor: Color {
        switch level {
        case 0: return Color("AppTextSecondary").opacity(0.1)
        case 1: return Color("AppAccent").opacity(0.35)
        case 2: return Color("AppAccent").opacity(0.6)
        default: return Color("AppPrimary")
        }
    }
}
