import SwiftUI

// MARK: - Weekly Review View
// Shows patterns, evolution suggestions, and insights

struct WeeklyReviewView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var patterns: [DetectedPattern] = []
    @State private var evolutionSuggestions: [EvolutionSuggestion] = []
    @State private var selectedPattern: DetectedPattern?
    @State private var selectedSuggestion: EvolutionSuggestion?
    
    private let patternDetector = PatternDetector()
    private let evolutionEngine = RuleEvolutionEngine()
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Weekly Stats
                weeklyStatsCard
                
                // Pattern Insights
                if !patterns.isEmpty {
                    patternInsightsSection
                }
                
                // Evolution Suggestions
                if !evolutionSuggestions.isEmpty {
                    evolutionSuggestionsSection
                }
                
                // Rule Relationship Graph
                let correlations = calculateCorrelations()
                if !correlations.isEmpty {
                    RuleRelationshipGraphView(
                        rules: appState.activeRules,
                        correlations: correlations,
                        theme: theme
                    )
                }
                
                // Rules Performance
                rulesPerformanceSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 100)
        }
        .background(theme.backgroundPrimaryColor)
        .navigationTitle("Weekly Review")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            analyzePatterns()
            analyzeEvolution()
        }
        .sheet(item: $selectedPattern) { pattern in
            PatternDetailSheet(pattern: pattern, theme: theme)
        }
        .sheet(item: $selectedSuggestion) { suggestion in
            EvolutionSuggestionSheet(
                suggestion: suggestion,
                theme: theme,
                onAccept: { acceptEvolutionSuggestion(suggestion) }
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(weekRangeText)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
            
            Text("Your Weekly Insights")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimaryColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var weekRangeText: String {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else {
            return "This Week"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: today))"
    }
    
    // MARK: - Weekly Stats Card
    
    private var weeklyStatsCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                statItem(
                    icon: "checkmark.circle.fill",
                    value: "\(weeklyCheckIns)",
                    label: "Check-ins",
                    color: Color.green
                )
                
                Divider()
                    .frame(height: 40)
                
                statItem(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(weeklyCompliance * 100))%",
                    label: "Compliance",
                    color: theme.accentColor
                )
                
                Divider()
                    .frame(height: 40)
                
                statItem(
                    icon: "flame.fill",
                    value: "\(longestStreak)",
                    label: "Best Streak",
                    color: Color.orange
                )
            }
        }
        .padding(20)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(theme.strokeColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimaryColor)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Pattern Insights Section
    
    private var patternInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pattern Insights")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimaryColor)
                    
                    Text("\(patterns.count) patterns detected")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.textSecondaryColor)
                }
            }
            
            PatternInsightsView(
                patterns: patterns,
                theme: theme,
                onActionTap: { pattern in
                    selectedPattern = pattern
                }
            )
        }
    }
    
    // MARK: - Evolution Suggestions Section
    
    private var evolutionSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.up.forward.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Evolution Suggestions")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimaryColor)
                    
                    Text("\(evolutionSuggestions.count) recommendations")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.textSecondaryColor)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(evolutionSuggestions.prefix(3)) { suggestion in
                    evolutionSuggestionCard(suggestion)
                }
            }
        }
    }
    
    private func evolutionSuggestionCard(_ suggestion: EvolutionSuggestion) -> some View {
        Button(action: {
            selectedSuggestion = suggestion
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor(for: suggestion).opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: suggestion.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(iconColor(for: suggestion))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimaryColor)
                    
                    Text(suggestion.rule.statement)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondaryColor)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.textSecondaryColor.opacity(0.5))
            }
            .padding(16)
            .background(theme.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(theme.strokeColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func iconColor(for suggestion: EvolutionSuggestion) -> Color {
        switch suggestion {
        case .levelUp: return Color.green
        case .makeEasier: return Color.orange
        case .pause: return Color.blue
        case .archive: return Color.gray
        case .celebrate: return Color.yellow
        }
    }
    
    // MARK: - Rules Performance Section
    
    private var rulesPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rules Performance")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimaryColor)
                    
                    Text("Last 7 days")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.textSecondaryColor)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(appState.activeRules.prefix(5)) { rule in
                    rulePerformanceCard(rule)
                }
            }
        }
    }
    
    private func rulePerformanceCard(_ rule: NewRule) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(rule.statement)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimaryColor)
            
            HStack(spacing: 8) {
                // Week dots
                ForEach(0..<7, id: \.self) { dayOffset in
                    weekDayDot(for: rule, dayOffset: dayOffset)
                }
                
                Spacer()
                
                // Compliance percentage
                Text("\(Int(weekCompliance(for: rule) * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(complianceColor(weekCompliance(for: rule)))
            }
        }
        .padding(16)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(theme.strokeColor, lineWidth: 1)
        )
    }
    
    private func weekDayDot(for rule: NewRule, dayOffset: Int) -> some View {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: Date()) else {
            return AnyView(Circle().fill(Color.gray.opacity(0.2)).frame(width: 24, height: 24))
        }
        
        let dayStart = calendar.startOfDay(for: date)
        let checkIn = rule.checkIns.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) })
        
        let color: Color
        if let checkIn = checkIn {
            color = checkIn.kept ? Color.green : Color.red
        } else {
            color = Color.gray.opacity(0.2)
        }
        
        return AnyView(
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
        )
    }
    
    private func weekCompliance(for rule: NewRule) -> Double {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: Date()) else {
            return 0.0
        }
        
        let weekCheckIns = rule.checkIns.filter { $0.date >= weekStart }
        guard !weekCheckIns.isEmpty else { return 0.0 }
        
        let keptCount = weekCheckIns.filter { $0.kept }.count
        return Double(keptCount) / Double(weekCheckIns.count)
    }
    
    private func complianceColor(_ compliance: Double) -> Color {
        switch compliance {
        case 0.8...1.0: return Color.green
        case 0.6..<0.8: return theme.accentColor
        case 0.4..<0.6: return Color.orange
        default: return Color.red
        }
    }
    
    // MARK: - Analytics
    
    private var weeklyCheckIns: Int {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: Date()) else {
            return 0
        }
        
        return appState.rules.reduce(0) { total, rule in
            total + rule.checkIns.filter { $0.date >= weekStart }.count
        }
    }
    
    private var weeklyCompliance: Double {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: Date()) else {
            return 0.0
        }
        
        let activeRules = appState.activeRules
        guard !activeRules.isEmpty else { return 0.0 }
        
        var totalCompliance = 0.0
        var ruleCount = 0
        
        for rule in activeRules {
            let weekCheckIns = rule.checkIns.filter { $0.date >= weekStart }
            if !weekCheckIns.isEmpty {
                let keptCount = weekCheckIns.filter { $0.kept }.count
                totalCompliance += Double(keptCount) / Double(weekCheckIns.count)
                ruleCount += 1
            }
        }
        
        return ruleCount > 0 ? totalCompliance / Double(ruleCount) : 0.0
    }
    
    private var longestStreak: Int {
        appState.rules.map { $0.currentStreak }.max() ?? 0
    }
    
    // MARK: - ML Analysis
    
    private func analyzePatterns() {
        patterns = patternDetector.detectPatterns(for: appState.activeRules)
    }
    
    private func analyzeEvolution() {
        evolutionSuggestions = evolutionEngine.analyzeSuggestions(for: appState.activeRules)
    }
    
    private func calculateCorrelations() -> [(NewRule, NewRule, Double)] {
        return patternDetector.calculateCorrelations(for: appState.activeRules)
    }
    
    private func acceptEvolutionSuggestion(_ suggestion: EvolutionSuggestion) {
        // Handle different suggestion types
        switch suggestion {
        case .levelUp(let rule, let newStatement, _):
            var updatedRule = rule
            updatedRule.statement = newStatement
            appState.updateRule(updatedRule)
            
        case .makeEasier(let rule, let newStatement, _):
            var updatedRule = rule
            updatedRule.statement = newStatement
            appState.updateRule(updatedRule)
            
        case .pause(let rule, _):
            appState.pauseRule(id: rule.id)
            
        case .archive(let rule, _):
            appState.archiveRule(id: rule.id)
            
        case .celebrate:
            // Just dismiss - it's a celebration!
            break
        }
        
        // Refresh suggestions
        analyzeEvolution()
    }
}

// MARK: - Pattern Detail Sheet

struct PatternDetailSheet: View {
    let pattern: DetectedPattern
    let theme: AppTheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(pattern.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(theme.textPrimaryColor)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let action = pattern.actionSuggestion {
                    Button(action: { dismiss() }) {
                        Text(action)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle(pattern.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Evolution Suggestion Sheet

struct EvolutionSuggestionSheet: View {
    let suggestion: EvolutionSuggestion
    let theme: AppTheme
    let onAccept: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(suggestion.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(theme.textPrimaryColor)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("Not Now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.textPrimaryColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.surfaceColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(theme.strokeColor, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        onAccept()
                        dismiss()
                    }) {
                        Text(suggestion.actionLabel)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(theme.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle(suggestion.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyReviewView()
            .environmentObject(AppState())
            .environmentObject(ThemeManager())
    }
}
