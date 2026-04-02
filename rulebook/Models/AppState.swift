import Foundation
import SwiftUI

// MARK: - App State Manager
// Central state management for the entire app

@MainActor
class AppState: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isOnboarded: Bool
    @Published var rules: [NewRule] = []
    @Published var selectedCategories: Set<UUID> = []
    
    // MARK: - Managers
    
    let themeManager: ThemeManager
    let categoryManager: CategoryManager
    
    // MARK: - UserDefaults Keys
    
    private let onboardingKey = "rulebook.hasCompletedOnboarding"
    private let rulesKey = "rulebook.rules"
    private let selectedCategoriesKey = "rulebook.selectedCategories"
    
    // MARK: - Initialization
    
    init(themeManager: ThemeManager, categoryManager: CategoryManager) {
        self.themeManager = themeManager
        self.categoryManager = categoryManager
        
        // Load onboarding status
        self.isOnboarded = UserDefaults.standard.bool(forKey: onboardingKey)
        
        // Load rules
        loadRules()
        
        // Load selected categories
        loadSelectedCategories()
    }
    
    convenience init() {
        self.init(themeManager: ThemeManager(), categoryManager: CategoryManager())
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        isOnboarded = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetOnboarding() {
        isOnboarded = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
    }
    
    // MARK: - Category Selection
    
    func selectCategory(_ categoryId: UUID) {
        selectedCategories.insert(categoryId)
        saveSelectedCategories()
    }
    
    func deselectCategory(_ categoryId: UUID) {
        selectedCategories.remove(categoryId)
        saveSelectedCategories()
    }
    
    func toggleCategorySelection(_ categoryId: UUID) {
        if selectedCategories.contains(categoryId) {
            deselectCategory(categoryId)
        } else {
            selectCategory(categoryId)
        }
    }
    
    private func loadSelectedCategories() {
        if let data = UserDefaults.standard.data(forKey: selectedCategoriesKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            selectedCategories = decoded
        } else {
            // Default: select all default categories
            selectedCategories = Set(categoryManager.categories.map { $0.id })
        }
    }
    
    private func saveSelectedCategories() {
        if let encoded = try? JSONEncoder().encode(selectedCategories) {
            UserDefaults.standard.set(encoded, forKey: selectedCategoriesKey)
        }
    }
    
    // MARK: - Rules Management
    
    func addRule(_ rule: NewRule) {
        rules.append(rule)
        saveRules()
    }
    
    func updateRule(_ rule: NewRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
            saveRules()
        }
    }
    
    func deleteRule(_ rule: NewRule) {
        rules.removeAll { $0.id == rule.id }
        saveRules()
    }
    
    func deleteRules(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
        saveRules()
    }
    
    func checkInRule(id: UUID, kept: Bool, note: String? = nil, date: Date = Date()) {
        if let index = rules.firstIndex(where: { $0.id == id }) {
            rules[index].checkIn(kept: kept, note: note, date: date)
            saveRules()
        }
    }
    
    func pauseRule(id: UUID) {
        if let index = rules.firstIndex(where: { $0.id == id }) {
            rules[index].pause()
            saveRules()
        }
    }
    
    func resumeRule(id: UUID) {
        if let index = rules.firstIndex(where: { $0.id == id }) {
            rules[index].resume()
            saveRules()
        }
    }
    
    func archiveRule(id: UUID) {
        if let index = rules.firstIndex(where: { $0.id == id }) {
            rules[index].archive()
            saveRules()
        }
    }
    
    // MARK: - Persistence
    
    private func loadRules() {
        if let data = UserDefaults.standard.data(forKey: rulesKey),
           let decoded = try? JSONDecoder().decode([NewRule].self, from: data) {
            rules = decoded
        }
    }
    
    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: rulesKey)
        }
    }
    
    // MARK: - Computed Properties
    
    var activeRules: [NewRule] {
        rules.filter { $0.status == .active }
    }
    
    var pausedRules: [NewRule] {
        rules.filter { $0.status == .paused }
    }
    
    var archivedRules: [NewRule] {
        rules.filter { $0.status == .archived }
    }
    
    var todaysRules: [NewRule] {
        activeRules.filter { $0.isRelevantToday }
    }
    
    func rules(forCategory categoryId: UUID) -> [NewRule] {
        rules.filter { $0.categoryId == categoryId }
    }
    
    func activeRules(forCategory categoryId: UUID) -> [NewRule] {
        activeRules.filter { $0.categoryId == categoryId }
    }
    
    // MARK: - Statistics
    
    var totalRules: Int {
        rules.count
    }
    
    var totalActiveRules: Int {
        activeRules.count
    }
    
    var overallCompliance: Double {
        guard !activeRules.isEmpty else { return 0.0 }
        
        let totalCompliance = activeRules.reduce(0.0) { $0 + $1.complianceThisMonth }
        return totalCompliance / Double(activeRules.count)
    }
    
    var totalCheckInsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 0
        }
        
        return rules.reduce(0) { total, rule in
            total + rule.checkIns.filter { $0.date >= monthStart && $0.date <= monthEnd }.count
        }
    }
    
    var longestStreak: Int {
        rules.map { $0.currentStreak }.max() ?? 0
    }
    
    // MARK: - Reset
    
    func resetAllData() {
        rules.removeAll()
        selectedCategories.removeAll()
        saveRules()
        saveSelectedCategories()
        categoryManager.resetToDefaults()
    }
}

// MARK: - Environment Key

private struct AppStateKey: EnvironmentKey {
    @MainActor static let defaultValue: AppState = {
        AppState(themeManager: ThemeManager(), categoryManager: CategoryManager())
    }()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func appState(_ state: AppState) -> some View {
        environment(\.appState, state)
    }
}
