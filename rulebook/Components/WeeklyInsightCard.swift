import SwiftUI

// MARK: - Weekly Insight Card
// Animated card showing weekly performance insights

struct WeeklyInsightCard: View {
    let theme: AppTheme
    let weekCompliance: Double
    let bestDay: String
    let totalRules: Int
    let completedToday: Int
    
    @State private var animateProgress = false
    @State private var animateGlow = false
    @State private var showContent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with animated icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(theme.accentSoftColor)
                        .frame(width: 44, height: 44)
                        .scaleEffect(animateGlow ? 1.1 : 1.0)
                        .opacity(animateGlow ? 0.6 : 1.0)
                    
                    Circle()
                        .fill(theme.accentSoftColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.accentColor)
                        .rotationEffect(.degrees(animateGlow ? 5 : -5))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        animateGlow = true
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Insight")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(theme.textPrimaryColor)
                    
                    Text("Last 7 days")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(theme.textSecondaryColor)
                }
                
                Spacer()
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -10)
            
            // Compliance progress
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(Int(weekCompliance * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.accentColor)
                    
                    Text("compliance")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(theme.textSecondaryColor)
                }
                
                // Animated progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(theme.strokeColor.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: animateProgress ? geometry.size.width * weekCompliance : 0, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
            
            // Stats grid
            HStack(spacing: 12) {
                statBox(
                    icon: "star.fill",
                    value: bestDay,
                    label: "Best Day",
                    color: theme.accentColor
                )
                
                statBox(
                    icon: "checkmark.circle.fill",
                    value: "\(completedToday)",
                    label: "Today",
                    color: theme.successColor
                )
                
                statBox(
                    icon: "list.bullet",
                    value: "\(totalRules)",
                    label: "Active",
                    color: theme.textSecondaryColor
                )
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [theme.accentColor.opacity(0.3), theme.accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: theme.accentColor.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.3)) {
                animateProgress = true
            }
        }
    }
    
    private func statBox(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimaryColor)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(theme.backgroundPrimaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    WeeklyInsightCard(
        theme: .sageCalm,
        weekCompliance: 0.85,
        bestDay: "Wed",
        totalRules: 12,
        completedToday: 8
    )
    .padding(20)
    .background(Color(.systemGroupedBackground))
}
