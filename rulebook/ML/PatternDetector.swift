import Foundation

// MARK: - Pattern Detector
// On-device pattern analysis to discover user behavior patterns
// Detects: Day-of-week patterns, rule correlations, time patterns

enum DetectedPattern: Identifiable, Equatable {
    case weakDay(rule: NewRule, day: Int, successRate: Double)
    case strongDay(rule: NewRule, day: Int, successRate: Double)
    case correlation(rule1: NewRule, rule2: NewRule, strength: Double)
    case timePattern(rule: NewRule, preferredTime: String)
    case consistentSuccess(rule: NewRule, streak: Int)
    case strugglingRule(rule: NewRule, failureRate: Double)
    
    var id: String {
        switch self {
        case .weakDay(let rule, let day, _):
            return "weak-\(rule.id)-\(day)"
        case .strongDay(let rule, let day, _):
            return "strong-\(rule.id)-\(day)"
        case .correlation(let rule1, let rule2, _):
            return "corr-\(rule1.id)-\(rule2.id)"
        case .timePattern(let rule, _):
            return "time-\(rule.id)"
        case .consistentSuccess(let rule, _):
            return "success-\(rule.id)"
        case .strugglingRule(let rule, _):
            return "struggle-\(rule.id)"
        }
    }
    
    var title: String {
        switch self {
        case .weakDay(_, let day, let rate):
            return "\(dayName(day)) is challenging"
        case .strongDay(_, let day, let rate):
            return "\(dayName(day)) is your strongest day"
        case .correlation(_, _, let strength):
            return "Rules are connected (\(Int(strength * 100))%)"
        case .timePattern(_, let time):
            return "Best time: \(time)"
        case .consistentSuccess(_, let streak):
            return "\(streak)-day streak!"
        case .strugglingRule(_, let rate):
            return "Struggling (\(Int(rate * 100))% missed)"
        }
    }
    
    var description: String {
        switch self {
        case .weakDay(let rule, let day, let rate):
            return "You keep '\(rule.statement)' only \(Int(rate * 100))% of the time on \(dayName(day))s. Consider adjusting this rule for \(dayName(day))s."
        case .strongDay(let rule, let day, let rate):
            return "You keep '\(rule.statement)' \(Int(rate * 100))% of the time on \(dayName(day))s. Great consistency!"
        case .correlation(let rule1, let rule2, let strength):
            return "When you keep '\(rule1.statement)', you're \(Int(strength * 100))% more likely to keep '\(rule2.statement)'. These rules support each other."
        case .timePattern(let rule, let time):
            return "You usually keep '\(rule.statement)' around \(time). This might be your optimal time."
        case .consistentSuccess(let rule, let streak):
            return "You've kept '\(rule.statement)' for \(streak) days straight. You've mastered this rule!"
        case .strugglingRule(let rule, let rate):
            return "You've missed '\(rule.statement)' \(Int(rate * 100))% of the time. This rule might be too strict or not relevant right now."
        }
    }
    
    var actionSuggestion: String? {
        switch self {
        case .weakDay(_, let day, _):
            return "Adjust rule for \(dayName(day))s"
        case .strongDay:
            return nil
        case .correlation:
            return "Keep both rules together"
        case .timePattern:
            return "Set reminder for this time"
        case .consistentSuccess:
            return "Level up this rule"
        case .strugglingRule:
            return "Make rule easier or pause"
        }
    }
    
    var priority: PatternPriority {
        switch self {
        case .weakDay(_, _, let rate) where rate < 0.3:
            return .high
        case .strugglingRule(_, let rate) where rate > 0.7:
            return .high
        case .correlation(_, _, let strength) where strength > 0.8:
            return .medium
        case .consistentSuccess:
            return .medium
        default:
            return .low
        }
    }
    
    private func dayName(_ day: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[day - 1]
    }
    
    static func == (lhs: DetectedPattern, rhs: DetectedPattern) -> Bool {
        lhs.id == rhs.id
    }
}

enum PatternPriority: Int, Comparable {
    case high = 3
    case medium = 2
    case low = 1
    
    static func < (lhs: PatternPriority, rhs: PatternPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

class PatternDetector {
    
    // MARK: - Main Detection Function
    
    func detectPatterns(for rules: [NewRule], minimumDataPoints: Int = 7) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        // Only analyze active rules with sufficient data
        let analyzableRules = rules.filter { rule in
            rule.status == .active && rule.checkIns.count >= minimumDataPoints
        }
        
        guard !analyzableRules.isEmpty else { return [] }
        
        for rule in analyzableRules {
            // Day-of-week patterns
            patterns.append(contentsOf: detectDayOfWeekPatterns(for: rule))
            
            // Success/struggle patterns
            patterns.append(contentsOf: detectSuccessPatterns(for: rule))
            
            // Time patterns
            if let timePattern = detectTimePattern(for: rule) {
                patterns.append(timePattern)
            }
        }
        
        // Correlation patterns (between rules)
        patterns.append(contentsOf: detectCorrelations(among: analyzableRules))
        
        // Sort by priority
        return patterns.sorted { $0.priority > $1.priority }
    }
    
    // MARK: - Day of Week Analysis
    
    private func detectDayOfWeekPatterns(for rule: NewRule) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        let daySuccessRates = analyzeDayOfWeek(rule.checkIns)
        
        // Find weakest day (if significantly below average)
        if let weakestDay = daySuccessRates.min(by: { $0.value < $1.value }),
           weakestDay.value < 0.5 {
            patterns.append(.weakDay(rule: rule, day: weakestDay.key, successRate: weakestDay.value))
        }
        
        // Find strongest day (if significantly above average)
        if let strongestDay = daySuccessRates.max(by: { $0.value < $1.value }),
           strongestDay.value > 0.8 {
            patterns.append(.strongDay(rule: rule, day: strongestDay.key, successRate: strongestDay.value))
        }
        
        return patterns
    }
    
    private func analyzeDayOfWeek(_ checkIns: [CheckIn]) -> [Int: Double] {
        var dayStats: [Int: (kept: Int, total: Int)] = [:]
        
        let calendar = Calendar.current
        
        for checkIn in checkIns {
            let weekday = calendar.component(.weekday, from: checkIn.date) // 1 = Sunday, 7 = Saturday
            
            if dayStats[weekday] == nil {
                dayStats[weekday] = (kept: 0, total: 0)
            }
            
            dayStats[weekday]?.total += 1
            if checkIn.kept {
                dayStats[weekday]?.kept += 1
            }
        }
        
        // Calculate success rates
        var successRates: [Int: Double] = [:]
        for (day, stats) in dayStats {
            if stats.total > 0 {
                successRates[day] = Double(stats.kept) / Double(stats.total)
            }
        }
        
        return successRates
    }
    
    // MARK: - Success/Struggle Pattern Detection
    
    private func detectSuccessPatterns(for rule: NewRule) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        let recentCheckIns = Array(rule.checkIns.suffix(30)) // Last 30 check-ins
        guard recentCheckIns.count >= 7 else { return [] }
        
        let keptCount = recentCheckIns.filter { $0.kept }.count
        let successRate = Double(keptCount) / Double(recentCheckIns.count)
        
        // Consistent success (90%+ success rate)
        if successRate >= 0.9 {
            let streak = calculateCurrentStreak(recentCheckIns)
            if streak >= 7 {
                patterns.append(.consistentSuccess(rule: rule, streak: streak))
            }
        }
        
        // Struggling rule (70%+ failure rate)
        if successRate <= 0.3 {
            patterns.append(.strugglingRule(rule: rule, failureRate: 1.0 - successRate))
        }
        
        return patterns
    }
    
    private func calculateCurrentStreak(_ checkIns: [CheckIn]) -> Int {
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
    
    // MARK: - Time Pattern Detection
    
    private func detectTimePattern(for rule: NewRule) -> DetectedPattern? {
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        
        // Analyze when check-ins happen
        for checkIn in rule.checkIns where checkIn.kept {
            let hour = calendar.component(.hour, from: checkIn.date)
            hourCounts[hour, default: 0] += 1
        }
        
        // Find most common hour
        guard let mostCommonHour = hourCounts.max(by: { $0.value < $1.value }),
              mostCommonHour.value >= 3 else { // At least 3 occurrences
            return nil
        }
        
        let timeString = formatHour(mostCommonHour.key)
        return .timePattern(rule: rule, preferredTime: timeString)
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        var components = DateComponents()
        components.hour = hour
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        
        return "\(hour):00"
    }
    
    // MARK: - Correlation Detection
    
    func detectCorrelations(among rules: [NewRule]) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        // Need at least 2 rules to find correlations
        guard rules.count >= 2 else { return [] }
        
        // Compare each pair of rules
        for i in 0..<rules.count {
            for j in (i+1)..<rules.count {
                let rule1 = rules[i]
                let rule2 = rules[j]
                
                let correlation = calculateCorrelation(rule1.checkIns, rule2.checkIns)
                
                // Strong correlation (70%+)
                if correlation >= 0.7 {
                    patterns.append(.correlation(rule1: rule1, rule2: rule2, strength: correlation))
                }
            }
        }
        
        return patterns
    }
    
    // MARK: - Public Correlation Calculator (for RuleRelationshipGraphView)
    
    func calculateCorrelation(_ checkIns1: [CheckIn], _ checkIns2: [CheckIn]) -> Double {
        let calendar = Calendar.current
        
        // Create date-based lookup for both rules
        var dates1: Set<Date> = []
        var dates2: Set<Date> = []
        
        for checkIn in checkIns1 where checkIn.kept {
            let dayStart = calendar.startOfDay(for: checkIn.date)
            dates1.insert(dayStart)
        }
        
        for checkIn in checkIns2 where checkIn.kept {
            let dayStart = calendar.startOfDay(for: checkIn.date)
            dates2.insert(dayStart)
        }
        
        // Find overlapping days
        let overlap = dates1.intersection(dates2).count
        let union = dates1.union(dates2).count
        
        guard union > 0 else { return 0.0 }
        
        // Jaccard similarity coefficient
        return Double(overlap) / Double(union)
    }
    
    // MARK: - Public Helper for RuleRelationshipGraphView
    
    func calculateCorrelations(for rules: [NewRule]) -> [(NewRule, NewRule, Double)] {
        var correlations: [(NewRule, NewRule, Double)] = []
        
        guard rules.count >= 2 else { return [] }
        
        for i in 0..<rules.count {
            for j in (i+1)..<rules.count {
                let rule1 = rules[i]
                let rule2 = rules[j]
                
                let correlation = calculateCorrelation(rule1.checkIns, rule2.checkIns)
                
                if correlation >= 0.7 {
                    correlations.append((rule1, rule2, correlation))
                }
            }
        }
        
        return correlations.sorted { $0.2 > $1.2 } // Sort by strength
    }
}

// MARK: - Pattern Insights Summary

struct PatternInsightsSummary {
    let totalPatterns: Int
    let highPriorityCount: Int
    let topPattern: DetectedPattern?
    let correlatedRulePairs: Int
    let strugglingRulesCount: Int
    let masteredRulesCount: Int
    
    init(patterns: [DetectedPattern]) {
        self.totalPatterns = patterns.count
        self.highPriorityCount = patterns.filter { $0.priority == .high }.count
        self.topPattern = patterns.first
        self.correlatedRulePairs = patterns.filter {
            if case .correlation = $0 { return true }
            return false
        }.count
        self.strugglingRulesCount = patterns.filter {
            if case .strugglingRule = $0 { return true }
            return false
        }.count
        self.masteredRulesCount = patterns.filter {
            if case .consistentSuccess = $0 { return true }
            return false
        }.count
    }
    
    var hasInsights: Bool {
        totalPatterns > 0
    }
    
    var summaryText: String {
        if !hasInsights {
            return "Keep tracking for 7+ days to unlock pattern insights"
        }
        
        var parts: [String] = []
        
        if masteredRulesCount > 0 {
            parts.append("\(masteredRulesCount) mastered rule\(masteredRulesCount == 1 ? "" : "s")")
        }
        
        if strugglingRulesCount > 0 {
            parts.append("\(strugglingRulesCount) rule\(strugglingRulesCount == 1 ? "" : "s") need adjustment")
        }
        
        if correlatedRulePairs > 0 {
            parts.append("\(correlatedRulePairs) connected rule pair\(correlatedRulePairs == 1 ? "" : "s")")
        }
        
        return parts.isEmpty ? "No significant patterns yet" : parts.joined(separator: " • ")
    }
}
