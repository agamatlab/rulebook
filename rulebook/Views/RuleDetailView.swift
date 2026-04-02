import SwiftUI

// MARK: - Rule Detail View
// View and edit individual rule details

struct RuleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    
    let rule: NewRule
    
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ruleStatementCard
                statsSection
                actionsSection
            }
            .padding(20)
        }
        .background(theme.backgroundPrimaryColor)
        .navigationTitle("Rule Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Rule", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appState.deleteRule(rule)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this rule? This action cannot be undone.")
        }
    }
    
    private var ruleStatementCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(rule.statement)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(theme.textPrimaryColor)
            
            if !rule.reason.isEmpty {
                Text(rule.reason)
                    .font(.system(size: 16))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(theme.strokeColor, lineWidth: 1)
        )
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            statCard(
                icon: "flame.fill",
                value: "\(rule.currentStreak)",
                label: "Day Streak"
            )
            
            statCard(
                icon: "chart.bar.fill",
                value: "\(Int(rule.complianceThisMonth * 100))%",
                label: "This Month"
            )
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            editButton
            pauseResumeButton
            deleteButton
        }
    }
    
    private var editButton: some View {
        Button(action: { showEditSheet = true }) {
            HStack {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .medium))
                Text("Edit Rule")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(theme.textPrimaryColor)
            .padding(16)
            .background(theme.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(theme.strokeColor, lineWidth: 1)
            )
        }
    }
    
    private var pauseResumeButton: some View {
        Button(action: {
            if rule.status == .active {
                appState.pauseRule(id: rule.id)
            } else {
                appState.resumeRule(id: rule.id)
            }
        }) {
            HStack {
                Image(systemName: rule.status == .active ? "pause.circle" : "play.circle")
                    .font(.system(size: 16, weight: .medium))
                Text(rule.status == .active ? "Pause Rule" : "Resume Rule")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(theme.textPrimaryColor)
            .padding(16)
            .background(theme.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(theme.strokeColor, lineWidth: 1)
            )
        }
    }
    
    private var deleteButton: some View {
        Button(action: { showDeleteConfirmation = true }) {
            HStack {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                Text("Delete Rule")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(.red)
            .padding(16)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(theme.accentColor)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimaryColor)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(theme.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(theme.strokeColor, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RuleDetailView(rule: NewRule(
            statement: "No phone in bedroom",
            successDefinition: "Phone stays in living room after 10 PM",
            reason: "Better sleep quality",
            schedule: .everyDay
        ))
        .environmentObject(ThemeManager())
        .environmentObject(AppState())
    }
}
