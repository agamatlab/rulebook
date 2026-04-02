import SwiftUI

// MARK: - AI Recommendations View
// Displays AI-powered category and schedule recommendations

struct AIRecommendationsView: View {
    let score: RuleHealthScore
    let theme: AppTheme
    let onCategorySelect: (String) -> Void
    let onScheduleSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.accentColor)
                
                Text("AI Suggestions")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimaryColor)
            }
            
            VStack(spacing: 12) {
                // Category recommendation
                if let category = score.recommendedCategory, score.categoryConfidence > 0.5 {
                    recommendationCard(
                        icon: "folder",
                        title: "Recommended Category",
                        value: category,
                        confidence: score.categoryConfidence,
                        action: { onCategorySelect(category) }
                    )
                }
                
                // Schedule recommendation
                if let schedule = score.recommendedSchedule, score.scheduleConfidence > 0.5 {
                    recommendationCard(
                        icon: "calendar",
                        title: "Recommended Schedule",
                        value: schedule,
                        confidence: score.scheduleConfidence,
                        action: { onScheduleSelect(schedule) }
                    )
                }
            }
        }
        .padding(16)
        .background(theme.accentSoftColor.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(theme.accentColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func recommendationCard(
        icon: String,
        title: String,
        value: String,
        confidence: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(theme.accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(theme.accentColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textSecondaryColor)
                    
                    Text(value)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimaryColor)
                }
                
                Spacer()
                
                // Confidence indicator
                HStack(spacing: 4) {
                    Text("\(Int(confidence * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(confidenceColor(confidence))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.textSecondaryColor.opacity(0.5))
                }
            }
            .padding(12)
            .background(theme.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0: return Color.green
        case 0.6..<0.8: return theme.accentColor
        default: return Color.orange
        }
    }
}

#Preview {
    let analyzer = RuleHealthAnalyzer()
    let score = analyzer.analyze("Go to gym for 30 minutes on weekdays")
    
    AIRecommendationsView(
        score: score,
        theme: .sageCalm,
        onCategorySelect: { _ in },
        onScheduleSelect: { _ in }
    )
    .padding()
}
