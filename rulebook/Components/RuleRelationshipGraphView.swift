import SwiftUI

// MARK: - Rule Relationship Graph
// Visual graph showing which rules support each other (correlations)

struct RuleRelationshipGraphView: View {
    let rules: [NewRule]
    let correlations: [(NewRule, NewRule, Double)]
    let theme: AppTheme
    
    @State private var selectedRule: NewRule?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "link.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.accentColor)
                
                Text("Rule Connections")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimaryColor)
                
                Spacer()
                
                Text("\(correlations.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accentSoftColor)
                    .clipShape(Capsule())
            }
            
            if correlations.isEmpty {
                emptyState
            } else {
                graphView
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
            Image(systemName: "link.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(theme.textSecondaryColor.opacity(0.5))
            
            Text("No connections yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
            
            Text("Keep tracking to discover which rules support each other")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textSecondaryColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Graph View
    
    private var graphView: some View {
        VStack(spacing: 16) {
            // Simple list view of correlations
            ForEach(correlations.prefix(5), id: \.0.id) { correlation in
                correlationCard(correlation.0, correlation.1, correlation.2)
            }
            
            if correlations.count > 5 {
                Text("+ \(correlations.count - 5) more connections")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.textSecondaryColor)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func correlationCard(_ rule1: NewRule, _ rule2: NewRule, _ strength: Double) -> some View {
        VStack(spacing: 12) {
            // Rule 1
            ruleNode(rule1)
            
            // Connection indicator
            HStack(spacing: 8) {
                Rectangle()
                    .fill(connectionColor(strength))
                    .frame(width: 2, height: 20)
                
                VStack(spacing: 2) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(connectionColor(strength))
                    
                    Text("\(Int(strength * 100))% connected")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(connectionColor(strength))
                }
                
                Rectangle()
                    .fill(connectionColor(strength))
                    .frame(width: 2, height: 20)
            }
            .frame(maxWidth: .infinity)
            
            // Rule 2
            ruleNode(rule2)
            
            // Insight
            Text("Keeping one helps you keep the other")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(theme.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(theme.backgroundSecondaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func ruleNode(_ rule: NewRule) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(theme.accentColor.opacity(0.2))
                .frame(width: 8, height: 8)
            
            Text(rule.statement)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.textPrimaryColor)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(12)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private func connectionColor(_ strength: Double) -> Color {
        switch strength {
        case 0.8...1.0: return Color.green
        case 0.7..<0.8: return theme.accentColor
        default: return Color.orange
        }
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    
    var sampleRule1 = NewRule(
        statement: "Sleep before 11pm",
        successDefinition: "In bed by 11pm",
        reason: "Better sleep"
    )
    
    var sampleRule2 = NewRule(
        statement: "Morning workout",
        successDefinition: "30 min exercise",
        reason: "Stay healthy"
    )
    
    // Add correlated check-ins
    for i in 0..<10 {
        if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
            let keep = i < 8 // Keep first 8 days together
            sampleRule1.checkIns.append(CheckIn(date: date, kept: keep))
            sampleRule2.checkIns.append(CheckIn(date: date, kept: keep))
        }
    }
    
    let correlations = [(sampleRule1, sampleRule2, 0.85)]
    
    return RuleRelationshipGraphView(
        rules: [sampleRule1, sampleRule2],
        correlations: correlations,
        theme: .sageCalm
    )
    .padding()
}
