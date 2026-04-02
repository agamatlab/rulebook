import SwiftUI

// MARK: - Main Tab View
// Root navigation with 4 tabs and floating "New Rule" button

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var selectedTab = 0
    @State private var showNewRuleSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        TodayView()
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                            .environmentObject(appState.categoryManager)
                    }
                case 1:
                    NavigationStack {
                        CategoriesView()
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                            .environmentObject(appState.categoryManager)
                    }
                case 2:
                    NavigationStack {
                        ReviewView()
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                            .environmentObject(appState.categoryManager)
                    }
                case 3:
                    NavigationStack {
                        SettingsView()
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                    }
                default:
                    NavigationStack {
                        TodayView()
                            .environmentObject(themeManager)
                            .environmentObject(appState)
                            .environmentObject(appState.categoryManager)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(themeManager.backgroundPrimary)
            
            // Custom floating tab bar
            VStack(spacing: 0) {
                Spacer()
                
                // Floating "New Rule" button
                floatingNewRuleButton
                    .padding(.bottom, 16)
                
                // Custom tab bar
                customTabBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showNewRuleSheet) {
            NewRuleFlow { newRule in
                appState.addRule(newRule)
            }
            .environmentObject(themeManager)
            .environmentObject(appState.categoryManager)
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabItems.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabItems[index].icon)
                            .font(.system(size: 22, weight: .medium))
                            .frame(height: 28)
                        
                        Text(tabItems[index].title)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == index ? themeManager.accent : themeManager.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TabButtonStyle())
            }
        }
        .background(
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(themeManager.surface)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(themeManager.stroke.opacity(0.5), lineWidth: 1)
                        )
                    
                    // Sliding bubble indicator
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(themeManager.accentSoft)
                        .frame(width: geometry.size.width / CGFloat(tabItems.count) - 16, height: 56)
                        .offset(x: (geometry.size.width / CGFloat(tabItems.count)) * CGFloat(selectedTab) + 8)
                }
            }
        )
        .frame(height: 72)
    }
    
    private var tabItems: [(icon: String, title: String)] {
        [
            ("calendar", "Today"),
            ("square.grid.2x2", "Categories"),
            ("chart.bar", "Review"),
            ("gearshape", "Settings")
        ]
    }
    
    // MARK: - Floating Button
    
    private var floatingNewRuleButton: some View {
        Button(action: {
            showNewRuleSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("New Rule")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(themeManager.accent)
                    .shadow(color: themeManager.accent.opacity(0.3), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(FloatingButtonStyle())
    }
}

// MARK: - Categories View

private struct CategoriesView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var categoryManager: CategoryManager
    
    @State private var showManageCategories = false
    @State private var categoryToEdit: RuleCategory?
    @State private var sortOrder: CategorySortOrder = .custom
    
    enum CategorySortOrder: String, CaseIterable {
        case custom = "Custom"
        case alphabetical = "A-Z"
        case ruleCount = "Rule Count"
        case compliance = "Compliance"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with manage button
                HStack {
                    Spacer()
                    
                    Button(action: { showManageCategories = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .medium))
                            Text("Manage")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundStyle(themeManager.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.accentSoft)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Sort options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CategorySortOrder.allCases, id: \.self) { order in
                            Button(action: { 
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    sortOrder = order
                                }
                            }) {
                                Text(order.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(sortOrder == order ? themeManager.accent : themeManager.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(sortOrder == order ? themeManager.accentSoft : themeManager.surface)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // All Rules button
                NavigationLink(destination: AllRulesView()) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 16, weight: .medium))
                        Text("View All Rules")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(themeManager.textSecondary.opacity(0.5))
                    }
                    .foregroundStyle(themeManager.textPrimary)
                    .padding(16)
                    .background(themeManager.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(themeManager.stroke, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                
                // Categories grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(sortedCategories()) { category in
                        categoryCard(category)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
        }
        .background(themeManager.backgroundPrimary)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showManageCategories) {
            ManageCategoriesView()
                .environmentObject(themeManager)
                .environmentObject(categoryManager)
        }
        .sheet(item: $categoryToEdit) { category in
            EditCategorySheet(category: category, onSave: { updatedCategory in
                categoryManager.updateCategory(updatedCategory)
                categoryToEdit = nil
            }, onDelete: {
                categoryManager.deleteCategory(category)
                categoryToEdit = nil
            })
            .environmentObject(themeManager)
        }
    }
    
    private func categoryCard(_ category: RuleCategory) -> some View {
        let rules = appState.rules(forCategory: category.id)
        let completedDays = calculateCompletedDays(for: category.id)
        
        return NavigationLink(destination: CategoryDetailView(category: category)) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and edit button
                HStack {
                    ZStack {
                        Circle()
                            .fill(themeManager.accentSoft)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: category.symbolName)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(themeManager.accent)
                    }
                    
                    Spacer()
                    
                    if category.isCustom {
                        Button(action: {
                            categoryToEdit = category
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(themeManager.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                // Category name
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Stats
                if !rules.isEmpty {
                    HStack(spacing: 4) {
                        Text("\(rules.count)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(themeManager.accent)
                        
                        Text(rules.count == 1 ? "rule" : "rules")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(themeManager.textSecondary)
                        
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundStyle(themeManager.textSecondary)
                        
                        Text("\(completedDays) days")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(themeManager.textSecondary)
                    }
                } else {
                    Text("No rules yet")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(themeManager.textSecondary.opacity(0.7))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(themeManager.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(themeManager.stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private func calculateCompletedDays(for categoryId: UUID) -> Int {
        let rules = appState.rules(forCategory: categoryId)
        guard !rules.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 0
        }
        
        // Track unique days where at least one rule was kept
        var daysWithKeptRules = Set<Date>()
        
        for rule in rules {
            let relevantCheckIns = rule.checkIns.filter { checkIn in
                checkIn.date >= monthStart && checkIn.date <= monthEnd && checkIn.kept
            }
            
            for checkIn in relevantCheckIns {
                let dayStart = calendar.startOfDay(for: checkIn.date)
                daysWithKeptRules.insert(dayStart)
            }
        }
        
        return daysWithKeptRules.count
    }
    
    private func sortedCategories() -> [RuleCategory] {
        let categories = categoryManager.categories
        
        switch sortOrder {
        case .custom:
            return categories.sorted { $0.sortOrder < $1.sortOrder }
        case .alphabetical:
            return categories.sorted { $0.name < $1.name }
        case .ruleCount:
            return categories.sorted { 
                let rules1 = appState.rules(forCategory: $0.id).count
                let rules2 = appState.rules(forCategory: $1.id).count
                return rules1 > rules2
            }
        case .compliance:
            return categories.sorted {
                let comp1 = calculateCompliance(for: $0.id)
                let comp2 = calculateCompliance(for: $1.id)
                return comp1 > comp2
            }
        }
    }
    
    private func calculateCompliance(for categoryId: UUID) -> Double {
        let rules = appState.rules(forCategory: categoryId)
        guard !rules.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 0
        }
        
        var totalScheduled = 0
        var totalKept = 0
        
        for rule in rules {
            for checkIn in rule.checkIns.filter({ $0.date >= monthStart && $0.date <= monthEnd }) {
                if let schedule = rule.schedule, schedule.appliesOn(date: checkIn.date) {
                    totalScheduled += 1
                    if checkIn.kept {
                        totalKept += 1
                    }
                }
            }
        }
        
        return totalScheduled > 0 ? Double(totalKept) / Double(totalScheduled) : 0
    }
}

// MARK: - Floating Button Style

private struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tab Button Style

private struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
}
