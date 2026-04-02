import Foundation

// MARK: - Rule Evolution Engine
// Suggests rule adjustments based on performance patterns
// Detects: Mastered rules (level up), struggling rules (adjust), stale rules (archive)

enum EvolutionSuggestion: Identifiable, Equatable {
    case levelUp(rule: NewRule, suggestion: String, reason: String)
    case makeEasier(rule: NewRule, suggestion: String, reason: String)
    case pause(rule: NewRule, reason: String)
    case archive(rule: NewRule, reason: String)
    case celebrate(rule: NewRule, achievement: String)
    
    var id: String {
        switch self {
        case .levelUp(let rule, _, _): return "levelup-\(rule.id)"
        case .makeEasier(let rule, _, _): return "easier-\(rule.id)"
        case .pause(let rule, _): return "pause-\(rule.id)"
        case .archive(let rule, _): return "archive-\(rule.id)"
        case .celebrate(let rule, _): return "celebrate-\(rule.id)"
        }
    }
    
    var rule: NewRule {
        switch self {
        case .levelUp(let rule, _, _): return rule
        case .makeEasier(let rule, _, _): return rule
        case .pause(let rule, _): return rule
        case .archive(let rule, _): return rule
        case .celebrate(let rule, _): return rule
        }
    }
    
    var title: String {
        switch self {
        case .levelUp: return "Ready to level up?"
        case .makeEasier: return "Make this easier?"
        case .pause: return "Pause this rule?"
        case .archive: return "Archive this rule?"
        case .celebrate: return "Achievement unlocked!"
        }
    }
    
    var icon: String {
        switch self {
        case .levelUp: return "arrow.up.circle.fill"
        case .makeEasier: return "arrow.down.circle.fill"
        case .pause: return "pause.circle.fill"
        case .archive: return "archivebox.fill"
        case .celebrate: return "star.fill"
        }
    }
    
    var iconColor: String {
        switch self {
        case .levelUp: return "green"
        case .makeEasier: return "orange"
        case .pause: return "blue"
        case .archive: return "gray"
        case .celebrate: return "yellow"
        }
    }
    
    var description: String {
        switch self {
        case .levelUp(_, let suggestion, let reason):
            return "\(reason)\n\nSuggestion: \(suggestion)"
        case .makeEasier(_, let suggestion, let reason):
            return "\(reason)\n\nSuggestion: \(suggestion)"
        case .pause(_, let reason):
            return reason
        case .archive(_, let reason):
            return reason
        case .celebrate(_, let achievement):
            return achievement
        }
    }
    
    var actionLabel: String {
        switch self {
        case .levelUp: return "Level Up"
        case .makeEasier: return "Adjust Rule"
        case .pause: return "Pause"
        case .archive: return "Archive"
        case .celebrate: return "Awesome!"
        }
    }
    
    static func == (lhs: EvolutionSuggestion, rhs: EvolutionSuggestion) -> Bool {
        lhs.id == rhs.id
    }
}

class RuleEvolutionEngine {
    
    // MARK: - Thresholds
    
    private let masteryThreshold = 0.9        // 90%+ compliance
    private let masteryDaysRequired = 30      // 30+ days
    private let struggleThreshold = 0.4       // <40% compliance
    private let struggleDaysRequired = 21     // 21+ days
    private let staleDaysThreshold = 60       // 60+ days no check-ins
    private let celebrationStreakThreshold = 30 // 30-day streak
    
    // MARK: - Main Analysis Function
    
    func analyzeSuggestions(for rules: [NewRule]) -> [EvolutionSuggestion] {
        var suggestions: [EvolutionSuggestion] = []
        
        for rule in rules {
            if let suggestion = analyzeRule(rule) {
                suggestions.append(suggestion)
            }
        }
        
        return suggestions
    }
    
    private func analyzeRule(_ rule: NewRule) -> EvolutionSuggestion? {
        let daysSinceCreated = daysSince(rule.createdAt)
        let recentCompliance = calculateRecentCompliance(rule)
        let currentStreak = calculateStreak(rule.checkIns)
        
        // Celebration: Long streak
        if currentStreak >= celebrationStreakThreshold {
            return .celebrate(
                rule: rule,
                achievement: "You've kept '\(rule.statement)' for \(currentStreak) days straight! This is now a solid habit."
            )
        }
        
        // Level up: Mastered rule
        if recentCompliance >= masteryThreshold && daysSinceCreated >= masteryDaysRequired {
            let suggestion = generateLevelUpSuggestion(for: rule)
            return .levelUp(
                rule: rule,
                suggestion: suggestion,
                reason: "You've kept this rule \(Int(recentCompliance * 100))% of the time for \(daysSinceCreated) days. You've mastered it!"
            )
        }
        
        // Make easier: Struggling rule
        if recentCompliance < struggleThreshold && daysSinceCreated >= struggleDaysRequired {
            let suggestion = generateEasierSuggestion(for: rule)
            return .makeEasier(
                rule: rule,
                suggestion: suggestion,
                reason: "You've kept this rule only \(Int(recentCompliance * 100))% of the time. It might be too strict."
            )
        }
        
        // Archive: Stale rule
        if rule.checkIns.isEmpty && daysSinceCreated >= staleDaysThreshold {
            return .archive(
                rule: rule,
                reason: "No check-ins in \(daysSinceCreated) days. This rule might not be relevant anymore."
            )
        }
        
        // Pause: Consistently missed recently
        if let pauseSuggestion = checkForPauseSuggestion(rule) {
            return pauseSuggestion
        }
        
        return nil
    }
    
    // MARK: - Level Up Suggestions
    
    private func generateLevelUpSuggestion(for rule: NewRule) -> String {
        let statement = rule.statement.lowercased()
        
        // Time-based rules
        if statement.contains("before") {
            if let time = extractTime(from: statement) {
                let earlierTime = makeEarlier(time)
                return "Try '\(rule.statement.replacingOccurrences(of: time, with: earlierTime))'"
            }
        }
        
        // Frequency-based rules
        if statement.contains("weekday") {
            return "Try '\(rule.statement.replacingOccurrences(of: "weekday", with: "every day"))'"
        }
        
        // Duration-based rules
        if statement.contains("30 min") {
            return "Try '\(rule.statement.replacingOccurrences(of: "30 min", with: "45 min"))'"
        }
        
        if statement.contains("minutes") {
            // Extract number and increase it
            if let minutes = extractNumber(from: statement) {
                let increased = minutes + 15
                return "Try '\(rule.statement.replacingOccurrences(of: "\(minutes) min", with: "\(increased) min"))'"
            }
        }
        
        // Generic suggestion
        return "Make this rule slightly more challenging"
    }
    
    // MARK: - Make Easier Suggestions
    
    private func generateEasierSuggestion(for rule: NewRule) -> String {
        let statement = rule.statement.lowercased()
        
        // Time-based rules
        if statement.contains("before") {
            if let time = extractTime(from: statement) {
                let laterTime = makeLater(time)
                return "Try '\(rule.statement.replacingOccurrences(of: time, with: laterTime))'"
            }
        }
        
        // Frequency-based rules
        if statement.contains("every day") {
            return "Try '\(rule.statement.replacingOccurrences(of: "every day", with: "on weekdays"))'"
        }
        
        // Absolute words
        if statement.contains("never") {
            return "Try '\(rule.statement.replacingOccurrences(of: "never", with: "rarely"))'"
        }
        
        if statement.contains("always") {
            return "Try '\(rule.statement.replacingOccurrences(of: "always", with: "usually"))'"
        }
        
        // Duration-based rules
        if statement.contains("minutes") {
            if let minutes = extractNumber(from: statement) {
                let reduced = max(10, minutes - 10)
                return "Try '\(rule.statement.replacingOccurrences(of: "\(minutes) min", with: "\(reduced) min"))'"
            }
        }
        
        // Generic suggestion
        return "Make this rule less strict or add flexibility"
    }
    
    // MARK: - Pause Suggestion
    
    private func checkForPauseSuggestion(_ rule: NewRule) -> EvolutionSuggestion? {
        // Check last 7 days
        let calendar = Calendar.current
        let now = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return nil }
        
        let recentCheckIns = rule.checkIns.filter { $0.date >= weekAgo }
        
        // If 5+ missed in last 7 days
        let missedCount = recentCheckIns.filter { !$0.kept }.count
        if missedCount >= 5 {
            return .pause(
                rule: rule,
                reason: "You've missed this rule \(missedCount) times in the last week. Taking a break might help you reset."
            )
        }
        
        return nil
    }
    
    // MARK: - Helper Functions
    
    private func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day ?? 0
    }
    
    private func calculateRecentCompliance(_ rule: NewRule) -> Double {
        let recentCheckIns = Array(rule.checkIns.suffix(30)) // Last 30 check-ins
        guard !recentCheckIns.isEmpty else { return 0.0 }
        
        let keptCount = recentCheckIns.filter { $0.kept }.count
        return Double(keptCount) / Double(recentCheckIns.count)
    }
    
    private func calculateStreak(_ checkIns: [CheckIn]) -> Int {
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
    
    private func extractTime(from text: String) -> String? {
        // Simple time extraction (e.g., "11pm", "midnight")
        let timePatterns = ["11pm", "10pm", "midnight", "11:30pm", "10:30pm"]
        for pattern in timePatterns {
            if text.contains(pattern) {
                return pattern
            }
        }
        return nil
    }
    
    private func makeEarlier(_ time: String) -> String {
        switch time {
        case "midnight": return "11:30pm"
        case "11pm": return "10:30pm"
        case "11:30pm": return "11pm"
        case "10pm": return "9:30pm"
        case "10:30pm": return "10pm"
        default: return time
        }
    }
    
    private func makeLater(_ time: String) -> String {
        switch time {
        case "10pm": return "10:30pm"
        case "10:30pm": return "11pm"
        case "11pm": return "11:30pm"
        case "11:30pm": return "midnight"
        case "9:30pm": return "10pm"
        default: return time
        }
    }
    
    private func extractNumber(from text: String) -> Int? {
        let pattern = "(\\d+)\\s*min"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        
        if let match = regex?.firstMatch(in: text, range: range),
           let numberRange = Range(match.range(at: 1), in: text) {
            return Int(text[numberRange])
        }
        
        return nil
    }
}
