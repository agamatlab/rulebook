import SwiftUI

// MARK: - Monthly Calendar View
// 7-column grid calendar with three visual states:
// - completed: filled accent circle
// - missed: thin outline circle
// - not scheduled: no circle, muted numeral
// Today gets outer halo ring, future days are reduced opacity
// Animations: toggle scales 0.88→1.0, month change slides + fades

struct MonthlyCalendarView: View {
    let month: Int
    let year: Int
    let rule: String?
    let category: String?
    let onDayTap: (Date) -> Void
    
    @State private var dayStates: [Int: DayState] = [:]
    @State private var animatingDay: Int?
    @State private var monthTransition: Bool = false
    
    // Access theme colors if available, fallback to defaults
    private var accentColor: Color {
        Color.accentColor
    }
    
    enum DayState {
        case completed
        case missed
        case notScheduled
    }
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 16) {
            weekdayHeader
            
            calendarGrid
                .opacity(monthTransition ? 0 : 1)
                .offset(x: monthTransition ? 30 : 0)
        }
        .padding(16)
        .onChange(of: month) { newValue in
            // Month change animation: fade out and slide
            withAnimation(.easeInOut(duration: 0.35)) {
                monthTransition = true
            }
            
            // Fade back in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    monthTransition = false
                }
            }
        }
    }
    
    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(daysInMonth, id: \.self) { day in
                if day == 0 {
                    // Empty cell for padding before first day
                    Color.clear
                        .frame(height: 44)
                } else {
                    dayCell(for: day)
                }
            }
        }
    }
    
    private func dayCell(for day: Int) -> some View {
        let date = dateForDay(day)
        let isToday = Calendar.current.isDateInToday(date)
        let isFuture = date > Date()
        let state = dayStates[day] ?? .notScheduled
        let isAnimating = animatingDay == day
        
        return ZStack {
            // Today's outer halo ring
            if isToday {
                Circle()
                    .strokeBorder(accentColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 44, height: 44)
            }
            
            // Day circle (filled for completed, outline for missed, none for not scheduled)
            Circle()
                .fill(circleBackground(for: state))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .strokeBorder(circleStroke(for: state), lineWidth: 1.5)
                )
            
            // Day number
            Text("\(day)")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(textColor(for: state, isFuture: isFuture))
        }
        .opacity(isFuture ? 0.4 : 1.0)
        .scaleEffect(isAnimating ? 1.0 : 0.88)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAnimating)
        .contentShape(Circle())
        .onTapGesture {
            handleDayTap(day: day, date: date)
        }
    }
    
    private func handleDayTap(day: Int, date: Date) {
        guard date <= Date() else { return }
        
        // Trigger scale animation
        animatingDay = day
        
        // Toggle state: notScheduled → completed → missed → notScheduled
        let currentState = dayStates[day] ?? .notScheduled
        let newState: DayState = switch currentState {
        case .notScheduled: .completed
        case .completed: .missed
        case .missed: .notScheduled
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dayStates[day] = newState
        }
        
        // Reset animation state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animatingDay = nil
        }
        
        onDayTap(date)
    }
    
    private func circleBackground(for state: DayState) -> Color {
        switch state {
        case .completed:
            // Filled accent circle
            return accentColor
        case .missed, .notScheduled:
            return .clear
        }
    }
    
    private func circleStroke(for state: DayState) -> Color {
        switch state {
        case .completed:
            return .clear
        case .missed:
            // Thin outline circle
            return .secondary.opacity(0.5)
        case .notScheduled:
            return .clear
        }
    }
    
    private func textColor(for state: DayState, isFuture: Bool) -> Color {
        if isFuture {
            // Future days: reduced opacity
            return .secondary.opacity(0.6)
        }
        
        switch state {
        case .completed:
            // White text on filled circle for contrast
            return .white
        case .missed:
            // Muted for missed days
            return .secondary
        case .notScheduled:
            // Muted numeral for not scheduled
            return .secondary.opacity(0.7)
        }
    }
    
    // MARK: - Calendar Calculations
    
    private var daysInMonth: [Int] {
        guard let firstWeekday = firstWeekdayOfMonth,
              let daysCount = numberOfDaysInMonth else {
            return []
        }
        
        var days: [Int] = []
        
        // Add empty cells for days before the first of the month
        for _ in 1..<firstWeekday {
            days.append(0)
        }
        
        // Add actual days
        for day in 1...daysCount {
            days.append(day)
        }
        
        return days
    }
    
    private var firstWeekdayOfMonth: Int? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let date = Calendar.current.date(from: components) else {
            return nil
        }
        
        return Calendar.current.component(.weekday, from: date)
    }
    
    private var numberOfDaysInMonth: Int? {
        var components = DateComponents()
        components.year = year
        components.month = month
        
        guard let date = Calendar.current.date(from: components),
              let range = Calendar.current.range(of: .day, in: .month, for: date) else {
            return nil
        }
        
        return range.count
    }
    
    private func dateForDay(_ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Previews

#Preview {
    MonthlyCalendarView(
        month: 3,
        year: 2026,
        rule: "Morning Exercise",
        category: .none
    ) { date in
        print("Tapped: \(date)")
    }
}

#Preview("Alternative View") {
    MonthlyCalendarView(
        month: 3,
        year: 2026,
        rule: .none,
        category: "Health"
    ) { date in
        print("Tapped: \(date)")
    }
}

#Preview("With States") {
    struct PreviewWrapper: View {
        @State private var states: [Int: MonthlyCalendarView.DayState] = [
            5: .completed,
            6: .completed,
            7: .missed,
            10: .completed,
            12: .completed,
            13: .completed,
            14: .missed
        ]
        
        var body: some View {
            MonthlyCalendarView(
                month: 3,
                year: 2026,
                rule: "Daily Meditation",
                category: .none
            ) { date in
                print("Tapped: \(date)")
            }
        }
    }
    
    return PreviewWrapper()
}
