import SwiftUI

// MARK: - Rule Health Score View
// Real-time display of rule health analysis with visual feedback

struct RuleHealthScoreView: View {
    let score: RuleHealthScore
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Overall score header
            HStack(spacing: 12) {
                Image(systemName: score.rating.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(scoreColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rule Health")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.textSecondaryColor)
                    
                    Text(score.rating.description)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(scoreColor)
                }
                
                Spacer()
                
                // Overall score percentage
                Text("\(Int(score.overallScore * 100))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)
            }
            
            // Score breakdown bars
            VStack(spacing: 12) {
                scoreBar(
                    label: "Specific",
                    value: score.specificity,
                    icon: "target"
                )
                
                scoreBar(
                    label: "Achievable",
                    value: score.achievability,
                    icon: "checkmark.circle"
                )
                
                scoreBar(
                    label: "Measurable",
                    value: score.measurability,
                    icon: "ruler"
                )
            }
            
            // Suggestions
            if !score.suggestions.isEmpty {
                Divider()
                    .background(theme.strokeColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(score.suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: suggestionIcon(for: suggestion))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(suggestionColor(for: suggestion))
                                .frame(width: 16)
                            
                            Text(suggestion)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(theme.textSecondaryColor)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(theme.surfaceColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 2)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: score.overallScore)
    }
    
    // MARK: - Score Bar Component
    
    private func scoreBar(label: String, value: Double, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textSecondaryColor)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.textSecondaryColor)
                
                Spacer()
                
                Text("\(Int(value * 100))%")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(barColor(for: value))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(theme.strokeColor.opacity(0.3))
                        .frame(height: 6)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(barColor(for: value))
                        .frame(width: geometry.size.width * value, height: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: value)
                }
            }
            .frame(height: 6)
        }
    }
    
    // MARK: - Color Helpers
    
    private var scoreColor: Color {
        switch score.rating {
        case .excellent: return Color.green
        case .good: return theme.accentColor
        case .needsWork: return Color.orange
        case .poor: return Color.red
        }
    }
    
    private var borderColor: Color {
        switch score.rating {
        case .excellent: return Color.green.opacity(0.3)
        case .good: return theme.accentColor.opacity(0.3)
        case .needsWork: return Color.orange.opacity(0.3)
        case .poor: return Color.red.opacity(0.3)
        }
    }
    
    private func barColor(for value: Double) -> Color {
        switch value {
        case 0.7...1.0: return Color.green
        case 0.5..<0.7: return theme.accentColor
        case 0.3..<0.5: return Color.orange
        default: return Color.red
        }
    }
    
    private func suggestionIcon(for suggestion: String) -> String {
        if suggestion.contains("well-defined") || suggestion.contains("Excellent") {
            return "checkmark.circle.fill"
        } else if suggestion.contains("Replace") || suggestion.contains("Add") {
            return "lightbulb.fill"
        } else {
            return "exclamationmark.circle.fill"
        }
    }
    
    private func suggestionColor(for suggestion: String) -> Color {
        if suggestion.contains("well-defined") || suggestion.contains("Excellent") {
            return Color.green
        } else if suggestion.contains("Replace") || suggestion.contains("Add") {
            return Color.orange
        } else {
            return theme.accentColor
        }
    }
}

// MARK: - Compact Version (for inline display)

struct RuleHealthScoreCompact: View {
    let score: RuleHealthScore
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: score.rating.iconName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(scoreColor)
            
            Text("\(Int(score.overallScore * 100))%")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(scoreColor)
            
            Text(score.rating.description)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(theme.surfaceColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1.5)
        )
    }
    
    private var scoreColor: Color {
        switch score.rating {
        case .excellent: return Color.green
        case .good: return theme.accentColor
        case .needsWork: return Color.orange
        case .poor: return Color.red
        }
    }
    
    private var borderColor: Color {
        switch score.rating {
        case .excellent: return Color.green.opacity(0.3)
        case .good: return theme.accentColor.opacity(0.3)
        case .needsWork: return Color.orange.opacity(0.3)
        case .poor: return Color.red.opacity(0.3)
        }
    }
}

// MARK: - Preview

#Preview("Excellent Score") {
    let analyzer = RuleHealthAnalyzer()
    let score = analyzer.analyze("Sleep before 11pm on weekdays")
    
    RuleHealthScoreView(score: score, theme: .sageCalm)
        .padding()
}

#Preview("Needs Work") {
    let analyzer = RuleHealthAnalyzer()
    let score = analyzer.analyze("Exercise more")
    
    RuleHealthScoreView(score: score, theme: .skyMist)
        .padding()
}

#Preview("Compact Version") {
    let analyzer = RuleHealthAnalyzer()
    let score = analyzer.analyze("No phone in bedroom after 10pm")
    
    RuleHealthScoreCompact(score: score, theme: .lavenderHaze)
        .padding()
}
