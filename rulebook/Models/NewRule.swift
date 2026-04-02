import Foundation

// MARK: - Rule Model
// Binary promise model: a simple statement with success definition

struct NewRule: Identifiable, Codable, Hashable {
    let id: UUID
    var statement: String
    var successDefinition: String
    var reason: String
    
    var categoryId: UUID?
    var schedule: Schedule?
    
    let createdAt: Date
    var status: RuleStatus
    
    var checkIns: [CheckIn]
    var reminderSettings: ReminderSettings?
    
    init(
        id: UUID = UUID(),
        statement: String,
        successDefinition: String,
        reason: String,
        categoryId: UUID? = nil,
        schedule: Schedule? = nil,
        createdAt: Date = Date(),
        status: RuleStatus = .active,
        checkIns: [CheckIn] = [],
        reminderSettings: ReminderSettings? = nil
    ) {
        self.id = id
        self.statement = statement
        self.successDefinition = successDefinition
        self.reason = reason
        self.categoryId = categoryId
        self.schedule = schedule
        self.createdAt = createdAt
        self.status = status
        self.checkIns = checkIns
        self.reminderSettings = reminderSettings
    }
}

// MARK: - Supporting Types

enum RuleStatus: String, Codable, Hashable {
    case active
    case paused
    case archived
}

struct CheckIn: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let kept: Bool
    let note: String?
    
    init(id: UUID = UUID(), date: Date, kept: Bool, note: String? = nil) {
        self.id = id
        self.date = date
        self.kept = kept
        self.note = note
    }
}

struct ReminderSettings: Codable, Hashable {
    var enabled: Bool
    var time: Date
    var daysOfWeek: Set<Int>
    
    init(enabled: Bool = true, time: Date = Date(), daysOfWeek: Set<Int> = [1, 2, 3, 4, 5, 6, 7]) {
        self.enabled = enabled
        self.time = time
        self.daysOfWeek = daysOfWeek
    }
}

// CalendarDayState is defined in CalendarDay.swift

// Schedule model is in Schedule.swift
// MARK: - Computed Properties

extension NewRule {
    /// Determines if this rule is relevant today based on its schedule
    var isRelevantToday: Bool {
        guard status == .active else { return false }
        guard let schedule = schedule else { return true }
        
        let today = Date()
        return schedule.appliesOn(date: today)
    }
    
    /// Calculates compliance percentage for the current month
    var complianceThisMonth: Double {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 0.0
        }
        
        let relevantCheckIns = checkIns.filter { checkIn in
            checkIn.date >= monthStart && checkIn.date <= monthEnd
        }
        
        guard !relevantCheckIns.isEmpty else { return 0.0 }
        
        let keptCount = relevantCheckIns.filter { $0.kept }.count
        return Double(keptCount) / Double(relevantCheckIns.count)
    }
    
    /// Calculates the current streak of consecutive kept check-ins
    var currentStreak: Int {
        guard !checkIns.isEmpty else { return 0 }
        
        let sortedCheckIns = checkIns.sorted { $0.date > $1.date }
        var streak = 0
        
        for checkIn in sortedCheckIns {
            if checkIn.kept {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Methods

extension NewRule {
    /// Records a check-in for this rule
    mutating func checkIn(kept: Bool, note: String? = nil, date: Date = Date()) {
        let newCheckIn = CheckIn(date: date, kept: kept, note: note)
        checkIns.append(newCheckIn)
    }
    
    /// Pauses the rule
    mutating func pause() {
        status = .paused
    }
    
    /// Resumes the rule
    mutating func resume() {
        status = .active
    }
    
    /// Archives the rule
    mutating func archive() {
        status = .archived
    }
    
    /// Determines the calendar state for a specific day
    func stateForDay(date: Date) -> CalendarDayState {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        
        // Check if rule was active on this date
        if targetDay < calendar.startOfDay(for: createdAt) {
            return .notScheduled
        }
        
        // Check if rule is relevant for this day based on schedule
        if let schedule = schedule, !schedule.appliesOn(date: targetDay) {
            return .notScheduled
        }
        
        // Find check-in for this specific day
        if let checkIn = checkIns.first(where: { calendar.isDate($0.date, inSameDayAs: targetDay) }) {
            return checkIn.kept ? .completed : .missed
        }
        
        // If day is in the past and no check-in exists, it's missed
        if targetDay < calendar.startOfDay(for: Date()) {
            return .missed
        }
        
        // Future or today without check-in - not scheduled yet
        return .notScheduled
    }
}
