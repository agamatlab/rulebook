import SwiftUI

// MARK: - Rule Card View
// Compact card for displaying a rule with tap action

struct RuleCardView: View {
    let rule: NewRule
    let theme: AppTheme
    let selectedDate: Date
    let onTap: () -> Void
    
    @EnvironmentObject var categoryManager: CategoryManager
    @State private var isPressed = false
    @State private var logoRotation: Double = 0
    
    private var hasCheckedInOnDate: Bool {
        return rule.checkIns.contains { checkIn in
            Calendar.current.isDate(checkIn.date, inSameDayAs: selectedDate)
        }
    }
    
    private var dateCheckIn: CheckIn? {
        return rule.checkIns.first { checkIn in
            Calendar.current.isDate(checkIn.date, inSameDayAs: selectedDate)
        }
    }
    
    private var category: RuleCategory? {
        guard let categoryId = rule.categoryId else { return nil }
        return categoryManager.categories.first { $0.id == categoryId }
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            onTap()
        }) {
            HStack(spacing: 16) {
                // Status indicator
                ZStack {
                    Circle()
                        .strokeBorder(
                            hasCheckedInOnDate ? theme.accentColor : theme.strokeColor,
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)
                    
                    if let checkIn = dateCheckIn, checkIn.kept {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(theme.accentColor)
                            .scaleEffect(hasCheckedInOnDate ? 1.0 : 0.5)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: hasCheckedInOnDate)
                    }
                }
                
                // Rule content
                VStack(alignment: .leading, spacing: 6) {
                    Text(rule.statement)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(theme.textPrimaryColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let schedule = rule.schedule {
                        Text(schedule.displayName)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(theme.textSecondaryColor)
                    }
                }
                
                Spacer()
                
                // Animated category logo
                if let category = category {
                    ZStack {
                        Circle()
                            .fill(theme.accentSoftColor)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: category.symbolName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(theme.accentColor)
                            .rotationEffect(.degrees(logoRotation))
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            logoRotation = 5
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(theme.surfaceColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(theme.strokeColor, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(color: Color.black.opacity(isPressed ? 0.1 : 0.05), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
        }
        .buttonStyle(.plain)
    }
}
