import Foundation

/// Represents the visual state of a rule on a specific calendar day
/// Supports 3-state visual logic for UI display
enum CalendarDayState: Equatable, Hashable {
    case completed      // Rule was scheduled and completed (binary: 1)
    case missed         // Rule was scheduled but not completed (binary: 0)
    case notScheduled   // Rule was not scheduled for this day (not tracked)
    
    /// Visual indicator for UI display
    var displaySymbol: String {
        switch self {
        case .completed:
            return "✓"
        case .missed:
            return "✗"
        case .notScheduled:
            return "·"
        }
    }
    
    /// Color indicator for UI
    var colorName: String {
        switch self {
        case .completed:
            return "green"
        case .missed:
            return "red"
        case .notScheduled:
            return "gray"
        }
    }
}

/// Calculates the state of a rule on a specific calendar day
struct CalendarDay {
    let date: Date
    
    /// Calculate the state for a rule on this specific day
    /// Binary tracking: scheduled days are either completed (1) or missed (0)
    /// Visual display: 3 states (completed/missed/notScheduled)
    /// - Parameters:
    ///   - rule: The rule to check
    ///   - schedule: The schedule for this rule
    ///   - calendar: Calendar to use for date calculations
    /// - Returns: The visual state for this day
    func calculateState(
        for rule: NewRule,
        schedule: Schedule,
        calendar: Calendar = .current
    ) -> CalendarDayState {
        // First check if the rule is scheduled for this day
        guard schedule.appliesOn(date: date) else {
            return .notScheduled
        }
        
        // Rule is scheduled - check if it was completed (binary check)
        let isCompleted = rule.checkIns.contains { checkIn in
            calendar.isDate(checkIn.date, inSameDayAs: date) && checkIn.kept
        }
        
        return isCompleted ? .completed : .missed
    }
    
    /// Calculate state with explicit completions set
    /// - Parameters:
    ///   - schedule: The schedule to check
    ///   - completions: Set of dates when the rule was completed
    ///   - calendar: Calendar to use for date calculations
    /// - Returns: The visual state for this day
    func calculateState(
        schedule: Schedule,
        completions: Set<Date>,
        calendar: Calendar = .current
    ) -> CalendarDayState {
        // First check if the rule is scheduled for this day
        guard schedule.appliesOn(date: date) else {
            return .notScheduled
        }
        
        // Rule is scheduled - check if it was completed (binary check)
        let isCompleted = completions.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: date)
        }
        
        return isCompleted ? .completed : .missed
    }
    
    /// Calculate state for multiple rules on this day
    /// - Parameters:
    ///   - rules: Array of rules to check
    ///   - schedules: Dictionary mapping rule IDs to their schedules
    ///   - calendar: Calendar to use for date calculations
    /// - Returns: Dictionary mapping rule IDs to their states
    func calculateStates(
        for rules: [NewRule],
        schedules: [UUID: Schedule],
        calendar: Calendar = .current
    ) -> [UUID: CalendarDayState] {
        var states: [UUID: CalendarDayState] = [:]
        
        for rule in rules {
            guard let schedule = schedules[rule.id] else {
                states[rule.id] = .notScheduled
                continue
            }
            
            states[rule.id] = calculateState(
                for: rule,
                schedule: schedule,
                calendar: calendar
            )
        }
        
        return states
    }
    
    /// Check if this day is in the past (for determining if missed days count)
    /// - Parameter calendar: Calendar to use for date calculations
    /// - Returns: True if this day is before today
    func isInPast(calendar: Calendar = .current) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let thisDay = calendar.startOfDay(for: date)
        return thisDay < today
    }
    
    /// Check if this day is today
    /// - Parameter calendar: Calendar to use for date calculations
    /// - Returns: True if this day is today
    func isToday(calendar: Calendar = .current) -> Bool {
        calendar.isDateInToday(date)
    }
}
