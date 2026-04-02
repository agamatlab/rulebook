import SwiftUI

// MARK: - Edit Category Sheet
// Edit custom category name, icon, and description

struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let category: RuleCategory
    let onSave: (RuleCategory) -> Void
    let onDelete: () -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var selectedIcon: String
    @State private var showDeleteConfirmation = false
    
    private let iconOptions = [
        "star", "heart", "bolt", "flame", "leaf",
        "book", "pencil", "lightbulb", "target", "flag",
        "trophy", "crown", "sparkles", "moon.stars", "sun.max",
        "cloud", "drop", "snowflake", "wind", "tornado"
    ]
    
    init(category: RuleCategory, onSave: @escaping (RuleCategory) -> Void, onDelete: @escaping () -> Void) {
        self.category = category
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: category.name)
        _description = State(initialValue: category.description)
        _selectedIcon = State(initialValue: category.symbolName)
    }
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textSecondaryColor)
                        
                        TextField("e.g., Creative Projects", text: $name)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(theme.surfaceColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(theme.strokeColor, lineWidth: 1)
                            )
                    }
                    
                    // Description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textSecondaryColor)
                        
                        TextField("Brief description", text: $description)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(theme.surfaceColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(theme.strokeColor, lineWidth: 1)
                            )
                    }
                    
                    // Icon picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textSecondaryColor)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                iconButton(icon)
                            }
                        }
                    }
                    
                    // Delete button (only for custom categories)
                    if category.isCustom {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Delete Category")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(20)
            }
            .background(theme.backgroundPrimaryColor)
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(theme.textSecondaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .foregroundStyle(theme.accentColor)
                    .disabled(name.isEmpty)
                }
            }
            .alert("Delete Category", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this category? Rules in this category will not be deleted.")
            }
        }
    }
    
    private func iconButton(_ icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(selectedIcon == icon ? .white : theme.accentColor)
                .frame(width: 60, height: 60)
                .background(selectedIcon == icon ? theme.accentColor : theme.accentSoftColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func saveCategory() {
        var updatedCategory = category
        updatedCategory.name = name
        updatedCategory.description = description
        updatedCategory.symbolName = selectedIcon
        onSave(updatedCategory)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EditCategorySheet(
        category: RuleCategory(
            name: "Creative Projects",
            symbolName: "star",
            description: "Creative and artistic pursuits",
            isCustom: true
        ),
        onSave: { _ in },
        onDelete: { }
    )
    .environmentObject(ThemeManager())
}
