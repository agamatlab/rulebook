import SwiftUI

// MARK: - Review View
// Monthly reflection dashboard with patterns and insights

struct ReviewView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var categoryStats: [CategoryStat] = []
    @State private var insights: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Weekly Review Link (NEW - with ML insights and graph)
                NavigationLink(destination: WeeklyReviewView()) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(themeManager.accentSoft)
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(themeManager.accent)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("Weekly Insights")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(themeManager.textPrimary)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(themeManager.accent)
                            }
                            
                            Text("AI patterns, evolution & rule connections")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(themeManager.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                    }
                    .padding(20)
                    .background(themeManager.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(themeManager.accent.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: themeManager.accent.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Current month summary card
                monthSummaryCard
                    .padding(.horizontal, 20)
                
                // Category summary cards
                categorySummarySection
                    .padding(.horizontal, 20)
                
                // Patterns section
                patternsSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for floating button
            }
        }
        .background(themeManager.backgroundPrimary)
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            calculateStats()
            generateInsights()
        }
    }
    
    // MARK: - Data Calculation
    
    private func calculateStats() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return
        }
        
        var stats: [CategoryStat] = []
        
        for category in categoryManager.categories {
            let rules = appState.rules(forCategory: category.id)
            guard !rules.isEmpty else { continue }
            
            var totalScheduledDays = 0
            var totalKeptDays = 0
            var previousWeekKept = 0
            var previousWeekScheduled = 0
            
            for rule in rules {
                let checkIns = rule.checkIns.filter { $0.date >= monthStart && $0.date <= monthEnd }
                
                for checkIn in checkIns {
                    if let schedule = rule.schedule, schedule.appliesOn(date: checkIn.date) {
                        totalScheduledDays += 1
                        if checkIn.kept {
                            totalKeptDays += 1
                        }
                        
                        // Check previous week for trend
                        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                           checkIn.date < weekAgo {
                            previousWeekScheduled += 1
                            if checkIn.kept {
                                previousWeekKept += 1
                            }
                        }
                    }
                }
            }
            
            guard totalScheduledDays > 0 else { continue }
            
            let compliance = Double(totalKeptDays) / Double(totalScheduledDays)
            
            // Calculate trend
            let currentWeekCompliance = totalScheduledDays > 0 ? Double(totalKeptDays) / Double(totalScheduledDays) : 0
            let previousWeekCompliance = previousWeekScheduled > 0 ? Double(previousWeekKept) / Double(previousWeekScheduled) : 0
            
            let trend: CategoryStat.Trend
            if currentWeekCompliance > previousWeekCompliance + 0.1 {
                trend = .improving
            } else if currentWeekCompliance < previousWeekCompliance - 0.1 {
                trend = .declining
            } else {
                trend = .stable
            }
            
            stats.append(CategoryStat(
                name: category.name,
                symbolName: category.symbolName,
                compliance: compliance,
                trend: trend
            ))
        }
        
        categoryStats = stats.sorted { $0.compliance > $1.compliance }
    }
    
    private func generateInsights() {
        if #available(iOS 17.0, *) {
            insights = MLPatternAnalyzer.generateInsights(from: appState.rules, categoryManager: categoryManager)
        } else {
            // Fallback for older iOS versions
            insights = generateBasicInsights()
        }
    }
    
    private func generateBasicInsights() -> [String] {
        var generatedInsights: [String] = []
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }
        
        // Only show insights if there's data
        let totalCheckIns = appState.rules.flatMap { $0.checkIns }.filter { $0.date >= monthStart }.count
        guard totalCheckIns >= 3 else {
            return ["Start tracking your rules to see personalized insights"]
        }
        
        // Insight 1: Best day of week
        var dayOfWeekStats: [Int: (kept: Int, total: Int)] = [:]
        
        for rule in appState.rules {
            for checkIn in rule.checkIns.filter({ $0.date >= monthStart }) {
                let dayOfWeek = calendar.component(.weekday, from: checkIn.date)
                var stats = dayOfWeekStats[dayOfWeek] ?? (kept: 0, total: 0)
                stats.total += 1
                if checkIn.kept {
                    stats.kept += 1
                }
                dayOfWeekStats[dayOfWeek] = stats
            }
        }
        
        if let bestDay = dayOfWeekStats.max(by: { 
            let comp1 = Double($0.value.kept) / Double($0.value.total)
            let comp2 = Double($1.value.kept) / Double($1.value.total)
            return comp1 < comp2
        }) {
            let dayName = calendar.weekdaySymbols[bestDay.key - 1]
            let compliance = Int((Double(bestDay.value.kept) / Double(bestDay.value.total)) * 100)
            generatedInsights.append("Your best day is \(dayName) with \(compliance)% compliance")
        }
        
        // Insight 2: Longest streak
        var longestStreak = 0
        var longestStreakRule: NewRule?
        
        for rule in appState.rules {
            if rule.currentStreak > longestStreak {
                longestStreak = rule.currentStreak
                longestStreakRule = rule
            }
        }
        
        if longestStreak >= 3, let rule = longestStreakRule {
            generatedInsights.append("You're on a \(longestStreak)-day streak with '\(rule.statement)'")
        }
        
        // Insight 3: Category that needs attention
        if let weakestCategory = categoryStats.last, weakestCategory.compliance < 0.7 {
            generatedInsights.append("\(weakestCategory.name) needs attention - only \(Int(weakestCategory.compliance * 100))% compliance")
        }
        
        // Insight 4: Weekend vs weekday
        var weekdayKept = 0, weekdayTotal = 0
        var weekendKept = 0, weekendTotal = 0
        
        for rule in appState.rules {
            for checkIn in rule.checkIns.filter({ $0.date >= monthStart }) {
                let dayOfWeek = calendar.component(.weekday, from: checkIn.date)
                if dayOfWeek == 1 || dayOfWeek == 7 {
                    weekendTotal += 1
                    if checkIn.kept { weekendKept += 1 }
                } else {
                    weekdayTotal += 1
                    if checkIn.kept { weekdayKept += 1 }
                }
            }
        }
        
        if weekdayTotal > 0 && weekendTotal > 0 {
            let weekdayComp = Double(weekdayKept) / Double(weekdayTotal)
            let weekendComp = Double(weekendKept) / Double(weekendTotal)
            
            if weekendComp > weekdayComp + 0.15 {
                generatedInsights.append("Weekend compliance is \(Int((weekendComp - weekdayComp) * 100))% higher than weekdays")
            } else if weekdayComp > weekendComp + 0.15 {
                generatedInsights.append("Weekday compliance is \(Int((weekdayComp - weekendComp) * 100))% higher than weekends")
            }
        }
        
        return generatedInsights
    }
    
    // MARK: - Month Summary Card
    
    private var monthSummaryCard: some View {
        let calendar = Calendar.current
        let now = Date()
        let monthName = calendar.monthSymbols[calendar.component(.month, from: now) - 1]
        let activeRules = appState.rules.filter { $0.status == .active }
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return AnyView(EmptyView())
        }
        
        var totalKept = 0
        var totalScheduled = 0
        
        for rule in activeRules {
            for checkIn in rule.checkIns.filter({ $0.date >= monthStart && $0.date <= monthEnd }) {
                if let schedule = rule.schedule, schedule.appliesOn(date: checkIn.date) {
                    totalScheduled += 1
                    if checkIn.kept {
                        totalKept += 1
                    }
                }
            }
        }
        
        let strongestCategory = categoryStats.first?.name ?? "N/A"
        let slippingCategory = categoryStats.last?.name ?? "N/A"
        
        return AnyView(
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthName)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(themeManager.textPrimary)
                    
                    Text("\(activeRules.count) active rules")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary)
                }
                
                Divider()
                    .background(themeManager.stroke)
                
                // Stats grid
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Days kept")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(themeManager.textSecondary)
                            .textCase(.uppercase)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(totalKept)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(themeManager.accent)
                            
                            Text("/ \(totalScheduled)")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(themeManager.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        statRow(label: "Strongest", value: strongestCategory, icon: "arrow.up.circle.fill", color: themeManager.success)
                        statRow(label: "Slipping", value: slippingCategory, icon: "arrow.down.circle.fill", color: themeManager.warning)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(themeManager.surface)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(themeManager.stroke, lineWidth: 1)
            )
        )
    }
    
    private func statRow(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(themeManager.textPrimary)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Category Summary Section
    
    private var categorySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(themeManager.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(categoryStats) { stat in
                    categoryStatCard(stat)
                }
            }
        }
    }
    
    private func categoryStatCard(_ stat: CategoryStat) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(themeManager.accentSoft)
                    .frame(width: 44, height: 44)
                
                Image(systemName: stat.symbolName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(themeManager.accent)
            }
            
            // Name and progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(stat.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.textPrimary)
                    
                    Spacer()
                    
                    // Trend indicator
                    trendIndicator(stat.trend)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(themeManager.stroke.opacity(0.3))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(complianceColor(stat.compliance))
                            .frame(width: geometry.size.width * stat.compliance, height: 6)
                    }
                }
                .frame(height: 6)
                
                // Percentage
                Text("\(Int(stat.compliance * 100))% compliance")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(themeManager.stroke, lineWidth: 1)
        )
    }
    
    private func trendIndicator(_ trend: CategoryStat.Trend) -> some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.system(size: 12, weight: .semibold))
            
            Text(trend.label)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(trend.color(theme: themeManager))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(trend.color(theme: themeManager).opacity(0.15))
        )
    }
    
    private func complianceColor(_ compliance: Double) -> Color {
        if compliance >= 0.8 {
            return themeManager.success
        } else if compliance >= 0.6 {
            return themeManager.accent
        } else {
            return themeManager.warning
        }
    }
    
    // MARK: - Patterns Section
    
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(themeManager.accent)
                
                Text("Patterns")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(insights.prefix(3).enumerated()), id: \.offset) { index, insight in
                    insightCard(insight, index: index)
                }
            }
            
            if insights.isEmpty {
                Text("Keep tracking your rules to see patterns")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(themeManager.surface)
                    )
            }
            
            Text("These insights help you understand your patterns, not judge them")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(themeManager.textSecondary)
                .padding(.top, 8)
        }
    }
    
    private func insightCard(_ insight: String, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.accent)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(themeManager.accentSoft)
                )
            
            Text(insight)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(themeManager.textPrimary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(themeManager.accent.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Category Stat Model

private struct CategoryStat: Identifiable {
    let id = UUID()
    let name: String
    let symbolName: String
    let compliance: Double
    let trend: Trend
    
    enum Trend {
        case improving
        case stable
        case declining
        
        var icon: String {
            switch self {
            case .improving: return "arrow.up"
            case .stable: return "minus"
            case .declining: return "arrow.down"
            }
        }
        
        var label: String {
            switch self {
            case .improving: return "Improving"
            case .stable: return "Stable"
            case .declining: return "Slipping"
            }
        }
        
        @MainActor
        func color(theme: ThemeManager) -> Color {
            switch self {
            case .improving: return theme.success
            case .stable: return theme.textSecondary
            case .declining: return theme.warning
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        ReviewView()
    }
    .themeManager(ThemeManager())
}
