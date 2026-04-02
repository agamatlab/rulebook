import SwiftUI

// MARK: - Pattern Insights View
// Displays detected patterns with actionable suggestions

struct PatternInsightsView: View {
    let patterns: [DetectedPattern]
    let theme: AppTheme
    let onActionTap: (DetectedPattern) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.accentColor)
                
                Text("Pattern Insights")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimaryColor)
                
                Spacer()
                
                Text("\(patterns.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accentSoftColor)
                    .clipShape(Capsule())
            }
            
            if patterns.isEmpty {
                emptyState
            } else {
                patternsList
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
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundStyle(theme.textSecondaryColor.opacity(0.5))
            
            Text("Keep tracking for 7+ days")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
            
            Text("Pattern insights will appear here")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textSecondaryColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - Patterns List
    
    private var patternsList: some View {
        VStack(spacing: 12) {
            ForEach(patterns.prefix(5)) { pattern in
                patternCard(pattern)
            }
            
            if patterns.count > 5 {
                Text("+ \(patterns.count - 5) more insights")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.textSecondaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Pattern Card
    
    private func patternCard(_ pattern: DetectedPattern) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title with priority indicator
            HStack(spacing: 8) {
                priorityIndicator(pattern.priority)
                
                Text(pattern.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimaryColor)
                
                Spacer()
            }
            
            // Description
            Text(pattern.description)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textSecondaryColor)
                .fixedSize(horizontal: false, vertical: true)
            
            // Action button
            if let action = pattern.actionSuggestion {
                Button(action: { onActionTap(pattern) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 12))
                        
                        Text(action)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(theme.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(theme.accentSoftColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(theme.backgroundSecondaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(borderColor(for: pattern.priority), lineWidth: 1)
        )
    }
    
    // MARK: - Priority Indicator
    
    private func priorityIndicator(_ priority: PatternPriority) -> some View {
        Circle()
            .fill(priorityColor(priority))
            .frame(width: 8, height: 8)
    }
    
    private func priorityColor(_ priority: PatternPriority) -> Color {
        switch priority {
        case .high: return Color.red
        case .medium: return Color.orange
        case .low: return theme.accentColor
        }
    }
    
    private func borderColor(for priority: PatternPriority) -> Color {
        switch priority {
        case .high: return Color.red.opacity(0.2)
        case .medium: return Color.orange.opacity(0.2)
        case .low: return theme.strokeColor
        }
    }
}

// MARK: - Compact Pattern Summary

struct PatternSummaryCompact: View {
    let summary: PatternInsightsSummary
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Pattern Insights")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.textPrimaryColor)
                
                Text(summary.summaryText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(theme.textSecondaryColor)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if summary.highPriorityCount > 0 {
                Text("\(summary.highPriorityCount)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())
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
}

// MARK: - Preview

#Preview("With Patterns") {
    PatternInsightsView(
        patterns: [],
        theme: .sageCalm,
        onActionTap: { _ in }
    )
    .padding()
}

#Preview("Empty State") {
    PatternInsightsView(
        patterns: [],
        theme: .skyMist,
        onActionTap: { _ in }
    )
    .padding()
}
