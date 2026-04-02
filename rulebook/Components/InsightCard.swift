import SwiftUI

struct InsightCard: View {
    let icon: String
    let headline: String
    let explanation: String
    let onTap: (() -> Void)?
    
    @Environment(\.themeManager) private var themeManager
    @State private var isPressed = false
    
    init(
        icon: String,
        headline: String,
        explanation: String,
        onTap: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.headline = headline
        self.explanation = explanation
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(themeManager.accentSoft)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(themeManager.accent)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(headline)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(themeManager.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(explanation)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(themeManager.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(themeManager.stroke.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(InsightCardButtonStyle())
        .disabled(onTap == nil)
    }
}

// MARK: - Button Style

struct InsightCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Insight Types") {
    VStack(spacing: 16) {
        InsightCard(
            icon: "sparkles",
            headline: "You're on a 7-day streak",
            explanation: "Keep it up! Consistency builds lasting habits.",
            onTap: {}
        )
        
        InsightCard(
            icon: "lightbulb",
            headline: "Best time to review your rules",
            explanation: "Sunday evenings work well for weekly planning.",
            onTap: {}
        )
        
        InsightCard(
            icon: "chart.line.uptrend.xyaxis",
            headline: "Your completion rate is improving",
            explanation: "Up 12% from last week across all categories.",
            onTap: {}
        )
        
        InsightCard(
            icon: "moon.stars",
            headline: "Sleep rules are your strongest",
            explanation: "95% completion rate over the past month.",
            onTap: nil
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("In Context") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                InsightCard(
                    icon: "sparkles",
                    headline: "You're on a 7-day streak",
                    explanation: "Keep it up! Consistency builds lasting habits.",
                    onTap: {}
                )
                
                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    headline: "Your completion rate is improving",
                    explanation: "Up 12% from last week across all categories.",
                    onTap: {}
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}
