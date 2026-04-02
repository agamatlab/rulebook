import Foundation

struct RuleCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var symbolName: String
    var description: String
    var isEnabled: Bool
    var isCustom: Bool
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        symbolName: String,
        description: String,
        isEnabled: Bool = true,
        isCustom: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.description = description
        self.isEnabled = isEnabled
        self.isCustom = isCustom
        self.sortOrder = sortOrder
    }
    
    // MARK: - Default Categories
    
    static let defaultCategories: [RuleCategory] = [
        RuleCategory(
            name: "Sleep & Recovery",
            symbolName: "bed.double",
            description: "Rest, sleep quality, and recovery practices",
            sortOrder: 1
        ),
        RuleCategory(
            name: "Physical Health & Movement",
            symbolName: "figure.walk",
            description: "Exercise, movement, and physical wellness",
            sortOrder: 2
        ),
        RuleCategory(
            name: "Nutrition & Hydration",
            symbolName: "fork.knife",
            description: "Eating habits, nutrition, and hydration",
            sortOrder: 3
        ),
        RuleCategory(
            name: "Mental Health",
            symbolName: "brain.head.profile",
            description: "Mental wellness, mindfulness, and cognitive health",
            sortOrder: 4
        ),
        RuleCategory(
            name: "Emotional Regulation",
            symbolName: "heart.text.square",
            description: "Managing emotions and emotional well-being",
            sortOrder: 5
        ),
        RuleCategory(
            name: "Focus & Deep Work",
            symbolName: "brain",
            description: "Concentration, productivity, and deep work sessions",
            sortOrder: 6
        ),
        RuleCategory(
            name: "Work Boundaries",
            symbolName: "briefcase",
            description: "Work-life balance and professional boundaries",
            sortOrder: 7
        ),
        RuleCategory(
            name: "Money & Spending",
            symbolName: "dollarsign.circle",
            description: "Financial habits and spending decisions",
            sortOrder: 8
        ),
        RuleCategory(
            name: "Digital Hygiene",
            symbolName: "iphone",
            description: "Screen time, digital wellness, and tech boundaries",
            sortOrder: 9
        ),
        RuleCategory(
            name: "Relationships & Communication",
            symbolName: "person.2",
            description: "Social connections and communication practices",
            sortOrder: 10
        )
    ]
}
