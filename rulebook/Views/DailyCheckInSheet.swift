import SwiftUI

// MARK: - Daily Check-In Sheet
// Fast, calm interaction for daily rule check-ins
// Large centered rule name with two prominent buttons
// Optional "Not relevant today" for schedule flexibility

struct DailyCheckInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let rule: NewRule
    let onCheckIn: (Bool, Bool) -> Void // (kept, notRelevant)
    
    @State private var showSuccessAnimation = false
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    var body: some View {
        ZStack {
            theme.backgroundPrimaryColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // Centered rule statement
                ruleStatement
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                
                // Action buttons
                actionButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                // Not relevant option
                notRelevantButton
                    .padding(.bottom, 40)
                
                Spacer()
            }
            
            // Success animation overlay
            if showSuccessAnimation {
                successOverlay
            }
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("Did you keep to this rule?")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(theme.textPrimaryColor)
            
            if let schedule = rule.schedule {
                Text(schedule.displayName)
                    .font(.system(size: 14))
                    .foregroundColor(theme.textSecondaryColor)
            }
        }
    }
    
    private var ruleStatement: some View {
        Text(rule.statement)
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(theme.textPrimaryColor)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Yes button
            Button {
                handleYes()
            } label: {
                Text("Yes")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(theme.accentColor)
                    .cornerRadius(16)
            }
            
            // No button
            Button {
                handleNo()
            } label: {
                Text("No")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.textPrimaryColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(theme.surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.strokeColor, lineWidth: 1.5)
                    )
                    .cornerRadius(16)
            }
        }
    }
    
    private var notRelevantButton: some View {
        Button {
            handleNotRelevant()
        } label: {
            Text("Not relevant today")
                .font(.system(size: 15))
                .foregroundColor(theme.textSecondaryColor)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            theme.accentColor.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                    .scaleEffect(showSuccessAnimation ? 1.0 : 0.5)
                    .opacity(showSuccessAnimation ? 1.0 : 0.0)
                
                Text("Kept")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(showSuccessAnimation ? 1.0 : 0.0)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleYes() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessAnimation = true
        }
        
        // Delay dismiss to show animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onCheckIn(true, false)
            dismiss()
        }
    }
    
    private func handleNo() {
        onCheckIn(false, false)
        dismiss()
    }
    
    private func handleNotRelevant() {
        onCheckIn(false, true)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    DailyCheckInSheet(
        rule: NewRule(
            statement: "No phone in bedroom",
            successDefinition: "Phone stays in living room after 10 PM",
            reason: "Better sleep quality",
            schedule: .everyDay
        ),
        onCheckIn: { kept, notRelevant in
            print("Check-in: kept=\(kept), notRelevant=\(notRelevant)")
        }
    )
}
