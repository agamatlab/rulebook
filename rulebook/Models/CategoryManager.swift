import Foundation
import SwiftUI

@MainActor
class CategoryManager: ObservableObject {
    @Published private(set) var categories: [RuleCategory] = []
    
    private let userDefaultsKey = "rulebook.categories"
    
    init() {
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([RuleCategory].self, from: data) {
            categories = decoded.sorted { $0.sortOrder < $1.sortOrder }
        } else {
            categories = RuleCategory.defaultCategories
            saveCategories()
        }
    }
    
    func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func addCustomCategory(name: String, symbolName: String, description: String) {
        let maxSortOrder = categories.map { $0.sortOrder }.max() ?? 0
        let newCategory = RuleCategory(
            name: name,
            symbolName: symbolName,
            description: description,
            isEnabled: true,
            isCustom: true,
            sortOrder: maxSortOrder + 1
        )
        categories.append(newCategory)
        saveCategories()
    }
    
    func updateCategory(_ category: RuleCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(_ category: RuleCategory) {
        guard category.isCustom else { return }
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }
    
    func toggleCategory(_ category: RuleCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].isEnabled.toggle()
            saveCategories()
        }
    }
    
    func reorderCategories(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        for (index, _) in categories.enumerated() {
            categories[index].sortOrder = index + 1
        }
        saveCategories()
    }
    
    func resetToDefaults() {
        categories = RuleCategory.defaultCategories
        saveCategories()
    }
    
    // MARK: - Computed Properties
    
    var enabledCategories: [RuleCategory] {
        categories.filter { $0.isEnabled }
    }
    
    var customCategories: [RuleCategory] {
        categories.filter { $0.isCustom }
    }
    
    var defaultCategories: [RuleCategory] {
        categories.filter { !$0.isCustom }
    }
    
    func category(withId id: UUID) -> RuleCategory? {
        categories.first { $0.id == id }
    }
}
