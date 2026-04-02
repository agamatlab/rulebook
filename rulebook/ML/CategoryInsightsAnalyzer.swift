import Foundation
import NaturalLanguage

// MARK: - Category Insights Analyzer
// Uses iOS NLP to generate natural language insights about category performance

struct CategoryInsight {
    let text: String
    let sentiment: InsightSentiment
    let icon: String
    
    enum InsightSentiment {
        case positive, neutral, negative, encouraging
        
        var color: String {
            switch self {
            case .positive: return "green"
            case .neutral: return "blue"
            case .negative: return "orange"
            case .encouraging: return "purple"
            }
        }
    }
}

class CategoryInsightsAnalyzer {
    
    // MARK: - Generate Monthly Overview
    
    func generateMonthlyOverview(
        categoryName: String,
        rules: [NewRule],
        month: Date
    ) -> [CategoryInsight] {
        var insights: [CategoryInsight] = []
        
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        // Calculate stats
        let stats = calculateMonthStats(rules: rules, monthStart: monthStart, monthEnd: monthEnd)
        
        // Generate insights using NLP
        insights.append(contentsOf: generatePerformanceInsight(stats: stats, categoryName: categoryName))
        insights.append(contentsOf: generateStreakInsight(stats: stats))
        insights.append(contentsOf: generateTrendInsight(stats: stats, categoryName: categoryName))
        insights.append(contentsOf: generateBestDayInsight(stats: stats))
        insights.append(contentsOf: generateEncouragementInsight(stats: stats, categoryName: categoryName))
        
        return insights
    }
    
    // MARK: - Calculate Stats
    
    private struct MonthStats {
        let totalCheckIns: Int
        let keptCount: Int
        let missedCount: Int
        let complianceRate: Double
        let longestStreak: Int
        let currentStreak: Int
        let bestDay: String?
        let worstDay: String?
        let improvementRate: Double // Comparing first half vs second half
        let activeRulesCount: Int
    }
    
    private func calculateMonthStats(rules: [NewRule], monthStart: Date, monthEnd: Date) -> MonthStats {
        var totalCheckIns = 0
        var keptCount = 0
        var longestStreak = 0
        var currentStreak = 0
        
        // Day of week analysis
        var dayStats: [Int: (kept: Int, total: Int)] = [:]
        
        // First half vs second half
        let calendar = Calendar.current
        let monthMidpoint = calendar.date(byAdding: .day, value: 15, to: monthStart) ?? monthStart
        var firstHalfKept = 0
        var firstHalfTotal = 0
        var secondHalfKept = 0
        var secondHalfTotal = 0
        
        for rule in rules {
            let monthCheckIns = rule.checkIns.filter { $0.date >= monthStart && $0.date <= monthEnd }
            totalCheckIns += monthCheckIns.count
            keptCount += monthCheckIns.filter { $0.kept }.count
            
            // Calculate streak
            let ruleStreak = calculateStreak(checkIns: monthCheckIns)
            longestStreak = max(longestStreak, ruleStreak)
            
            // Day of week stats
            for checkIn in monthCheckIns {
                let weekday = calendar.component(.weekday, from: checkIn.date)
                if dayStats[weekday] == nil {
                    dayStats[weekday] = (kept: 0, total: 0)
                }
                dayStats[weekday]?.total += 1
                if checkIn.kept {
                    dayStats[weekday]?.kept += 1
                }
            }
            
            // First vs second half
            for checkIn in monthCheckIns {
                if checkIn.date < monthMidpoint {
                    firstHalfTotal += 1
                    if checkIn.kept { firstHalfKept += 1 }
                } else {
                    secondHalfTotal += 1
                    if checkIn.kept { secondHalfKept += 1 }
                }
            }
        }
        
        // Find best/worst days
        var bestDay: String?
        var worstDay: String?
        var bestRate = 0.0
        var worstRate = 1.0
        
        for (day, stats) in dayStats where stats.total > 0 {
            let rate = Double(stats.kept) / Double(stats.total)
            if rate > bestRate {
                bestRate = rate
                bestDay = dayName(day)
            }
            if rate < worstRate {
                worstRate = rate
                worstDay = dayName(day)
            }
        }
        
        // Calculate improvement
        let firstHalfRate = firstHalfTotal > 0 ? Double(firstHalfKept) / Double(firstHalfTotal) : 0
        let secondHalfRate = secondHalfTotal > 0 ? Double(secondHalfKept) / Double(secondHalfTotal) : 0
        let improvementRate = secondHalfRate - firstHalfRate
        
        let complianceRate = totalCheckIns > 0 ? Double(keptCount) / Double(totalCheckIns) : 0
        
        return MonthStats(
            totalCheckIns: totalCheckIns,
            keptCount: keptCount,
            missedCount: totalCheckIns - keptCount,
            complianceRate: complianceRate,
            longestStreak: longestStreak,
            currentStreak: currentStreak,
            bestDay: bestDay,
            worstDay: worstDay,
            improvementRate: improvementRate,
            activeRulesCount: rules.count
        )
    }
    
    // MARK: - Generate Insights
    
    private func generatePerformanceInsight(stats: MonthStats, categoryName: String) -> [CategoryInsight] {
        let percentage = Int(stats.complianceRate * 100)
        
        if stats.complianceRate >= 0.8 {
            return [CategoryInsight(
                text: "Outstanding! You kept \(categoryName) rules \(percentage)% of the time this month. You're building strong habits.",
                sentiment: .positive,
                icon: "star.fill"
            )]
        } else if stats.complianceRate >= 0.6 {
            return [CategoryInsight(
                text: "Good progress on \(categoryName). You kept rules \(percentage)% of the time. Keep up the momentum!",
                sentiment: .neutral,
                icon: "hand.thumbsup.fill"
            )]
        } else if stats.complianceRate >= 0.4 {
            return [CategoryInsight(
                text: "\(categoryName) rules were kept \(percentage)% of the time. There's room for improvement, but you're making progress.",
                sentiment: .encouraging,
                icon: "arrow.up.circle.fill"
            )]
        } else {
            return [CategoryInsight(
                text: "\(categoryName) rules were challenging this month (\(percentage)% kept). Consider adjusting them to be more achievable.",
                sentiment: .negative,
                icon: "exclamationmark.triangle.fill"
            )]
        }
    }
    
    private func generateStreakInsight(stats: MonthStats) -> [CategoryInsight] {
        guard stats.longestStreak > 0 else { return [] }
        
        if stats.longestStreak >= 7 {
            return [CategoryInsight(
                text: "Impressive \(stats.longestStreak)-day streak! You're proving consistency is your strength.",
                sentiment: .positive,
                icon: "flame.fill"
            )]
        } else if stats.longestStreak >= 3 {
            return [CategoryInsight(
                text: "You maintained a \(stats.longestStreak)-day streak. Building consistency takes time, and you're on the right track.",
                sentiment: .encouraging,
                icon: "flame"
            )]
        }
        
        return []
    }
    
    private func generateTrendInsight(stats: MonthStats, categoryName: String) -> [CategoryInsight] {
        if stats.improvementRate > 0.15 {
            return [CategoryInsight(
                text: "You're improving! \(categoryName) compliance increased \(Int(stats.improvementRate * 100))% in the second half of the month.",
                sentiment: .positive,
                icon: "chart.line.uptrend.xyaxis"
            )]
        } else if stats.improvementRate < -0.15 {
            return [CategoryInsight(
                text: "Compliance dipped \(Int(abs(stats.improvementRate) * 100))% in the second half. What changed? Consider reviewing your rules.",
                sentiment: .negative,
                icon: "chart.line.downtrend.xyaxis"
            )]
        }
        
        return []
    }
    
    private func generateBestDayInsight(stats: MonthStats) -> [CategoryInsight] {
        if let bestDay = stats.bestDay {
            return [CategoryInsight(
                text: "\(bestDay)s are your strongest day. Consider scheduling important rules on \(bestDay)s.",
                sentiment: .neutral,
                icon: "calendar.badge.checkmark"
            )]
        }
        return []
    }
    
    private func generateEncouragementInsight(stats: MonthStats, categoryName: String) -> [CategoryInsight] {
        if stats.keptCount > 0 {
            return [CategoryInsight(
                text: "You completed \(stats.keptCount) check-ins in \(categoryName) this month. Every check-in is progress!",
                sentiment: .encouraging,
                icon: "checkmark.circle.fill"
            )]
        }
        return []
    }
    
    // MARK: - Helper Functions
    
    private func calculateStreak(checkIns: [CheckIn]) -> Int {
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
    
    private func dayName(_ weekday: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[weekday - 1]
    }
}
