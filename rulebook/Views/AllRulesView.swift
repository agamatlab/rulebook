import SwiftUI

// MARK: - All Rules View
// View all rules across all categories

struct AllRulesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var filterStatus: RuleStatus = .active
    @State private var searchText = ""
    
    private var filteredRules: [NewRule] {
        var rules = appState.rules.filter { $0.status == filterStatus }
        
        if !searchText.isEmpty {
            rules = rules.filter { $0.statement.localizedCaseInsensitiveContains(searchText) }
        }
        
        return rules.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(themeManager.textSecondary)
                    
                    TextField("Search rules...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(12)
                .background(themeManager.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(themeManager.stroke, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([RuleStatus.active, RuleStatus.paused, RuleStatus.archived], id: \.self) { status in
                            Button(action: { filterStatus = status }) {
                                Text(status.rawValue.capitalized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(filterStatus == status ? themeManager.accent : themeManager.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(filterStatus == status ? themeManager.accentSoft : themeManager.surface)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Rules count
                HStack {
                    Text("\(filteredRules.count) \(filteredRules.count == 1 ? "rule" : "rules")")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(themeManager.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Rules list
                VStack(spacing: 12) {
                    ForEach(filteredRules) { rule in
                        ruleCard(rule)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(themeManager.backgroundPrimary)
        .navigationTitle("All Rules")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func ruleCard(_ rule: NewRule) -> some View {
        NavigationLink(destination: RuleDetailView(rule: rule)) {
            VStack(alignment: .leading, spacing: 12) {
                // Category badge
                if let categoryId = rule.categoryId,
                   let category = categoryManager.categories.first(where: { $0.id == categoryId }) {
                    HStack(spacing: 6) {
                        Image(systemName: category.symbolName)
                            .font(.system(size: 12, weight: .medium))
                        Text(category.name)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(themeManager.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.accentSoft)
                    .clipShape(Capsule())
                }
                
                // Rule statement
                Text(rule.statement)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(themeManager.textPrimary)
                
                // Schedule
                if let schedule = rule.schedule {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13))
                        Text(schedule.displayName)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(themeManager.textSecondary)
                }
                
                // Stats
                HStack(spacing: 16) {
                    // Streak
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(themeManager.accent)
                        Text("\(rule.currentStreak) day streak")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(themeManager.textSecondary)
                    }
                    
                    // Compliance
                    let compliance = rule.complianceThisMonth
                    if compliance > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(themeManager.success)
                            Text("\(Int(compliance * 100))% this month")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(themeManager.textSecondary)
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(themeManager.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AllRulesView()
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environmentObject(CategoryManager())
    }
}
