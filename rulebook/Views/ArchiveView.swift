import SwiftUI

// MARK: - Archive View
// A compassionate space for paused and archived rules
// People need to evolve without feeling like they failed

struct ArchiveView: View {
    @Environment(\.themeManager) private var themeManager
    @State private var selectedTab: ArchiveTab = .paused
    @State private var rules: [NewRule] = [] // TODO: Connect to data source
    @State private var ruleToDelete: NewRule?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom tab picker
            tabPicker
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Content
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filteredRules) { rule in
                        archiveRuleCard(rule)
                    }
                    
                    if filteredRules.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
        }
        .background(themeManager.backgroundPrimary)
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete permanently?", isPresented: $showDeleteConfirmation, presenting: ruleToDelete) { rule in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRule(rule)
            }
        } message: { rule in
            Text("This will permanently remove \"\(rule.statement)\" and all its history. This cannot be undone.")
        }
    }
    
    // MARK: - Tab Picker
    
    private var tabPicker: some View {
        HStack(spacing: 0) {
            tabButton(.paused, label: "Paused")
            tabButton(.archived, label: "Archived")
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(themeManager.backgroundSecondary)
        )
    }
    
    private func tabButton(_ tab: ArchiveTab, label: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(selectedTab == tab ? themeManager.textPrimary : themeManager.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selectedTab == tab ? themeManager.surface : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(2)
    }
    
    // MARK: - Archive Rule Card
    
    private func archiveRuleCard(_ rule: NewRule) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Rule statement
            Text(rule.statement)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(themeManager.textPrimary.opacity(0.6))
            
            // Success definition
            if !rule.successDefinition.isEmpty {
                Text(rule.successDefinition)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(themeManager.textSecondary.opacity(0.6))
            }
            
            // Actions
            HStack(spacing: 8) {
                // Restore button
                actionButton(
                    icon: "arrow.counterclockwise",
                    label: "Restore",
                    action: { restoreRule(rule) }
                )
                
                // Edit button
                actionButton(
                    icon: "pencil",
                    label: "Edit",
                    action: { editRule(rule) }
                )
                
                Spacer()
                
                // Delete button
                actionButton(
                    icon: "trash",
                    label: "Delete",
                    isDestructive: true,
                    action: {
                        ruleToDelete = rule
                        showDeleteConfirmation = true
                    }
                )
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.surface.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(themeManager.stroke.opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - Action Button
    
    private func actionButton(
        icon: String,
        label: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isDestructive ? themeManager.warning.opacity(0.8) : themeManager.accent.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isDestructive ? themeManager.warning.opacity(0.1) : themeManager.accentSoft.opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedTab == .paused ? "pause.circle" : "archivebox")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(themeManager.textSecondary.opacity(0.4))
                .padding(.top, 60)
            
            Text(selectedTab == .paused ? "No paused rules" : "No archived rules")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(themeManager.textPrimary.opacity(0.6))
            
            Text(selectedTab == .paused ? "Rules you pause will appear here" : "Rules you archive will appear here")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(themeManager.textSecondary.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Computed Properties
    
    private var filteredRules: [NewRule] {
        rules.filter { rule in
            switch selectedTab {
            case .paused:
                return rule.status == .paused
            case .archived:
                return rule.status == .archived
            }
        }
    }
    
    // MARK: - Actions
    
    private func restoreRule(_ rule: NewRule) {
        // TODO: Implement restore logic
        // This should change the rule status back to .active
        print("Restore rule: \(rule.statement)")
    }
    
    private func editRule(_ rule: NewRule) {
        // TODO: Implement edit logic
        // This should open the rule editor
        print("Edit rule: \(rule.statement)")
    }
    
    private func deleteRule(_ rule: NewRule) {
        // TODO: Implement delete logic
        // This should permanently remove the rule
        print("Delete rule: \(rule.statement)")
    }
}

// MARK: - Archive Tab

enum ArchiveTab {
    case paused
    case archived
}

// MARK: - Previews

#Preview("With Rules") {
    NavigationStack {
        ArchiveView()
    }
    .themeManager(ThemeManager())
}

#Preview("Empty") {
    NavigationStack {
        ArchiveView()
    }
    .themeManager(ThemeManager())
}
