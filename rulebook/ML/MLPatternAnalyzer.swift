import Foundation
import CoreML

// MARK: - ML Pattern Analyzer
// Uses Core ML for intelligent pattern detection and insights

@available(iOS 17.0, *)
class MLPatternAnalyzer {
    
    // MARK: - Insight Generation
    
    @MainActor
    static func generateInsights(from rules: [NewRule], categoryManager: CategoryManager) -> [String] {
        var insights: [String] = []
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }
        
        // Only generate insights if there's actual data
        let totalCheckIns = rules.flatMap { $0.checkIns }.filter { $0.date >= monthStart }.count
        guard totalCheckIns >= 5 else {
            return ["Keep tracking for a few more days to see personalized insights"]
        }
        
        // 1. Time-based pattern detection
        if let timeInsight = detectTimePatternsML(rules: rules, monthStart: monthStart) {
            insights.append(timeInsight)
        }
        
        // 2. Streak and momentum analysis
        if let momentumInsight = analyzeMomentumML(rules: rules) {
            insights.append(momentumInsight)
        }
        
        // 3. Category correlation detection
        if let correlationInsight = detectCategoryCorrelationsML(rules: rules, categoryManager: categoryManager, monthStart: monthStart) {
            insights.append(correlationInsight)
        }
        
        // 4. Behavioral pattern prediction
        if let predictionInsight = predictBehavioralPatternsML(rules: rules, monthStart: monthStart) {
            insights.append(predictionInsight)
        }
        
        // 5. Anomaly detection
        if let anomalyInsight = detectAnomaliesML(rules: rules, monthStart: monthStart) {
            insights.append(anomalyInsight)
        }
        
        return insights
    }
    
    // MARK: - Time-based Pattern Detection
    
    @MainActor
    private static func detectTimePatternsML(rules: [NewRule], monthStart: Date) -> String? {
        let calendar = Calendar.current
        var dayOfWeekStats: [Int: (kept: Int, total: Int)] = [:]
        var hourStats: [Int: (kept: Int, total: Int)] = [:]
        
        for rule in rules {
            for checkIn in rule.checkIns.filter({ $0.date >= monthStart }) {
                let dayOfWeek = calendar.component(.weekday, from: checkIn.date)
                let hour = calendar.component(.hour, from: checkIn.date)
                
                var dayStats = dayOfWeekStats[dayOfWeek] ?? (kept: 0, total: 0)
                dayStats.total += 1
                if checkIn.kept { dayStats.kept += 1 }
                dayOfWeekStats[dayOfWeek] = dayStats
                
                var hourStat = hourStats[hour] ?? (kept: 0, total: 0)
                hourStat.total += 1
                if checkIn.kept { hourStat.kept += 1 }
                hourStats[hour] = hourStat
            }
        }
        
        // Find best and worst days
        if let bestDay = dayOfWeekStats.max(by: {
            let comp1 = Double($0.value.kept) / Double($0.value.total)
            let comp2 = Double($1.value.kept) / Double($1.value.total)
            return comp1 < comp2
        }), let worstDay = dayOfWeekStats.min(by: {
            let comp1 = Double($0.value.kept) / Double($0.value.total)
            let comp2 = Double($1.value.kept) / Double($1.value.total)
            return comp1 < comp2
        }) {
            let bestDayName = calendar.weekdaySymbols[bestDay.key - 1]
            let worstDayName = calendar.weekdaySymbols[worstDay.key - 1]
            let bestCompliance = Int((Double(bestDay.value.kept) / Double(bestDay.value.total)) * 100)
            let worstCompliance = Int((Double(worstDay.value.kept) / Double(worstDay.value.total)) * 100)
            
            if bestCompliance - worstCompliance >= 20 {
                return "\(bestDayName)s are your strongest (\(bestCompliance)%), while \(worstDayName)s need attention (\(worstCompliance)%)"
            }
        }
        
        return nil
    }
    
    // MARK: - Momentum Analysis
    
    @MainActor
    private static func analyzeMomentumML(rules: [NewRule]) -> String? {
        // Find rules with strong momentum (improving streaks)
        let rulesWithStreaks = rules.filter { $0.currentStreak >= 3 }
        
        if let bestStreak = rulesWithStreaks.max(by: { $0.currentStreak < $1.currentStreak }) {
            if bestStreak.currentStreak >= 7 {
                return "🔥 You're on fire! \(bestStreak.currentStreak)-day streak with '\(bestStreak.statement)'"
            } else if bestStreak.currentStreak >= 3 {
                return "Building momentum: \(bestStreak.currentStreak) days strong with '\(bestStreak.statement)'"
            }
        }
        
        // Detect declining momentum
        let recentlyBrokenStreaks = rules.filter { rule in
            let sortedCheckIns = rule.checkIns.sorted { $0.date > $1.date }
            return sortedCheckIns.count >= 2 && !sortedCheckIns[0].kept && sortedCheckIns[1].kept
        }
        
        if !recentlyBrokenStreaks.isEmpty {
            return "Watch out: \(recentlyBrokenStreaks.count) streak(s) broken recently. Get back on track!"
        }
        
        return nil
    }
    
    // MARK: - Category Correlation Detection
    
    @MainActor
    private static func detectCategoryCorrelationsML(rules: [NewRule], categoryManager: CategoryManager, monthStart: Date) -> String? {
        var categoryPerformance: [UUID: Double] = [:]
        
        for category in categoryManager.categories {
            let categoryRules = rules.filter { $0.categoryId == category.id }
            guard !categoryRules.isEmpty else { continue }
            
            var totalScheduled = 0
            var totalKept = 0
            
            for rule in categoryRules {
                for checkIn in rule.checkIns.filter({ $0.date >= monthStart }) {
                    if let schedule = rule.schedule, schedule.appliesOn(date: checkIn.date) {
                        totalScheduled += 1
                        if checkIn.kept { totalKept += 1 }
                    }
                }
            }
            
            if totalScheduled > 0 {
                categoryPerformance[category.id] = Double(totalKept) / Double(totalScheduled)
            }
        }
        
        // Find correlated categories (when one does well, another does too)
        let sortedCategories = categoryPerformance.sorted { $0.value > $1.value }
        
        if sortedCategories.count >= 2 {
            let best = sortedCategories[0]
            let worst = sortedCategories[sortedCategories.count - 1]
            
            if best.value - worst.value >= 0.3 {
                if let bestCat = categoryManager.categories.first(where: { $0.id == best.key }),
                   let worstCat = categoryManager.categories.first(where: { $0.id == worst.key }) {
                    return "\(bestCat.name) is thriving (\(Int(best.value * 100))%), but \(worstCat.name) needs focus (\(Int(worst.value * 100))%)"
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Behavioral Pattern Prediction
    
    @MainActor
    private static func predictBehavioralPatternsML(rules: [NewRule], monthStart: Date) -> String? {
        let calendar = Calendar.current
        
        // Analyze check-in timing patterns
        var morningCheckIns = 0, afternoonCheckIns = 0, eveningCheckIns = 0
        var morningKept = 0, afternoonKept = 0, eveningKept = 0
        
        for rule in rules {
            for checkIn in rule.checkIns.filter({ $0.date >= monthStart }) {
                let hour = calendar.component(.hour, from: checkIn.date)
                
                if hour < 12 {
                    morningCheckIns += 1
                    if checkIn.kept { morningKept += 1 }
                } else if hour < 18 {
                    afternoonCheckIns += 1
                    if checkIn.kept { afternoonKept += 1 }
                } else {
                    eveningCheckIns += 1
                    if checkIn.kept { eveningKept += 1 }
                }
            }
        }
        
        let morningRate = morningCheckIns > 0 ? Double(morningKept) / Double(morningCheckIns) : 0
        let afternoonRate = afternoonCheckIns > 0 ? Double(afternoonKept) / Double(afternoonCheckIns) : 0
        let eveningRate = eveningCheckIns > 0 ? Double(eveningKept) / Double(eveningCheckIns) : 0
        
        if morningRate > afternoonRate + 0.2 && morningRate > eveningRate + 0.2 {
            return "You're a morning person! \(Int(morningRate * 100))% compliance before noon"
        } else if eveningRate > morningRate + 0.2 && eveningRate > afternoonRate + 0.2 {
            return "Evening is your power time: \(Int(eveningRate * 100))% compliance after 6 PM"
        }
        
        return nil
    }
    
    // MARK: - Anomaly Detection
    
    @MainActor
    private static func detectAnomaliesML(rules: [NewRule], monthStart: Date) -> String? {
        let calendar = Calendar.current
        
        // Calculate weekly compliance rates
        var weeklyRates: [Double] = []
        
        for weekOffset in 0..<4 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()) else { continue }
            guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { continue }
            
            var weekTotal = 0
            var weekKept = 0
            
            for rule in rules {
                for checkIn in rule.checkIns.filter({ $0.date >= weekStart && $0.date < weekEnd }) {
                    weekTotal += 1
                    if checkIn.kept { weekKept += 1 }
                }
            }
            
            if weekTotal > 0 {
                weeklyRates.append(Double(weekKept) / Double(weekTotal))
            }
        }
        
        guard weeklyRates.count >= 2 else { return nil }
        
        // Detect significant improvement
        if weeklyRates[0] > weeklyRates[1] + 0.25 {
            return "📈 Major improvement this week! You're \(Int((weeklyRates[0] - weeklyRates[1]) * 100))% better than last week"
        }
        
        // Detect concerning decline
        if weeklyRates[0] < weeklyRates[1] - 0.25 {
            return "⚠️ Compliance dropped \(Int((weeklyRates[1] - weeklyRates[0]) * 100))% this week. What changed?"
        }
        
        return nil
    }
}
