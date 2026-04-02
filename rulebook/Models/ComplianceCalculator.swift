import Foundation

/// Calculates compliance metrics and patterns for rules
struct ComplianceCalculator {
    
    // MARK: - Monthly Compliance
    
    struct MonthlyCompliance {
        let totalScheduledDays: Int
        let completedDays: Int
        let missedDays: Int
        
        var percentage: Double {
            guard totalScheduledDays > 0 else { return 0 }
            return Double(completedDays) / Double(totalScheduledDays) * 100
        }
    }
    
    /// Calculate monthly compliance for a single rule
    /// - Parameters:
    ///   - rule: The rule to analyze
    ///   - schedule: The schedule for this rule
    ///   - month: The month to analyze
    ///   - calendar: Calendar to use for calculations
    /// - Returns: Monthly compliance metrics
    static func calculateMonthlyCompliance(
        for rule: NewRule,
        schedule: Schedule,
        month: Date,
        calendar: Calendar = .current
    ) -> MonthlyCompliance {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        
        var totalScheduled = 0
        var completed = 0
        var missed = 0
        
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
            
            let calendarDay = CalendarDay(date: date)
            let state = calendarDay.calculateState(for: rule, schedule: schedule, calendar: calendar)
            
            switch state {
            case .completed:
                totalScheduled += 1
                completed += 1
            case .missed:
                totalScheduled += 1
                missed += 1
            case .notScheduled:
                break
            }
        }
        
        return MonthlyCompliance(
            totalScheduledDays: totalScheduled,
            completedDays: completed,
            missedDays: missed
        )
    }
    
    // MARK: - Category Day Completion
    
    /// Calculate if all scheduled rules in a category were completed on a specific day
    /// Binary logic: ALL scheduled rules must be complete for the day to count as complete
    /// - Parameters:
    ///   - rules: Array of rules in the category
    ///   - schedules: Dictionary mapping rule IDs to their schedules
    ///   - date: The date to check
    ///   - calendar: Calendar to use for calculations
    /// - Returns: True if all scheduled rules were completed
    static func calculateCategoryDayCompletion(
        for rules: [NewRule],
        schedules: [UUID: Schedule],
        date: Date,
        calendar: Calendar = .current
    ) -> Bool {
        let scheduledRules = rules.filter { rule in
            guard let schedule = schedules[rule.id] else { return false }
            return schedule.appliesOn(date: date)
        }
        
        guard !scheduledRules.isEmpty else { return false }
        
        return scheduledRules.allSatisfy { rule in
            rule.checkIns.contains { checkIn in
                calendar.isDate(checkIn.date, inSameDayAs: date) && checkIn.kept
            }
        }
    }
    
    // MARK: - Pattern Detection
    
    struct DayPattern {
        let weekday: Int
        let completionRate: Double
        
        var weekdayName: String {
            let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            return dayNames[weekday - 1]
        }
    }
    
    /// Detect which days of the week have the strongest/weakest completion rates
    /// - Parameters:
    ///   - rule: The rule to analyze
    ///   - schedule: The schedule for this rule
    ///   - month: The month to analyze
    ///   - calendar: Calendar to use for calculations
    /// - Returns: Array of day patterns sorted by completion rate (highest first)
    static func detectPatterns(
        for rule: NewRule,
        schedule: Schedule,
        month: Date,
        calendar: Calendar = .current
    ) -> [DayPattern] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        
        var weekdayStats: [Int: (completed: Int, total: Int)] = [:]
        
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
            
            let calendarDay = CalendarDay(date: date)
            let state = calendarDay.calculateState(for: rule, schedule: schedule, calendar: calendar)
            
            guard state != .notScheduled else { continue }
            
            let weekday = calendar.component(.weekday, from: date)
            let current = weekdayStats[weekday] ?? (completed: 0, total: 0)
            
            weekdayStats[weekday] = (
                completed: current.completed + (state == .completed ? 1 : 0),
                total: current.total + 1
            )
        }
        
        return weekdayStats.map { weekday, stats in
            let rate = stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0
            return DayPattern(weekday: weekday, completionRate: rate)
        }.sorted { $0.completionRate > $1.completionRate }
    }
}
