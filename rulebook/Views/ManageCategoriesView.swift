import SwiftUI

// MARK: - Manage Categories View
// Organize and customize rule categories
// Sections: Enabled, Hidden, Custom categories
// Drag to reorder, toggle to enable/disable, create custom categories

struct ManageCategoriesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var categoryManager: CategoryManager
    
    @State private var showCreateCustom = false
    @State private var editMode: EditMode = .inactive
    
    private var theme: AppTheme {
        themeManager.currentTheme
    }
    
    private var enabledCategories: [RuleCategory] {
        categoryManager.categories.filter { $0.isEnabled }
    }
    
    private var hiddenCategories: [RuleCategory] {
        categoryManager.categories.filter { !$0.isEnabled }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Enabled categories
                    enabledCategoriesSection
                    
                    // Hidden categories
                    if !hiddenCategories.isEmpty {
                        hiddenCategoriesSection
                    }
                    
                    // Custom categories
                    customCategoriesSection
                }
                .padding(.bottom, 40)
            }
            .background(theme.backgroundPrimaryColor)
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCreateCustom) {
            CreateCustomCategorySheet(
                theme: theme,
                onCreate: { category in
                    categoryManager.addCustomCategory(
                        name: category.name,
                        symbolName: category.symbolName,
                        description: category.description
                    )
                }
            )
            .environmentObject(themeManager)
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Manage Categories")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(theme.textPrimaryColor)
            
            Text("Organize how you group your rules")
                .font(.system(size: 16))
                .foregroundColor(theme.textSecondaryColor)
        }
    }
    
    private var enabledCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Enabled Categories",
                subtitle: "Your active categories"
            )
            
            VStack(spacing: 12) {
                ForEach(enabledCategories) { category in
                    categoryRow(category, isEnabled: true)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var hiddenCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Hidden Categories",
                subtitle: "Tap to enable"
            )
            
            VStack(spacing: 12) {
                ForEach(hiddenCategories) { category in
                    categoryRow(category, isEnabled: false)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var customCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Custom Categories",
                subtitle: "Your personalized categories"
            )
            
            let customCategories = categoryManager.categories.filter { $0.isCustom }
            
            if !customCategories.isEmpty {
                VStack(spacing: 12) {
                    ForEach(customCategories) { category in
                        categoryRow(category, isEnabled: true, isCustom: true)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Create custom button
            Button {
                showCreateCustom = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.accentColor)
                    
                    Text("Create custom category")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.accentColor)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(theme.accentSoftColor)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.textPrimaryColor)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondaryColor)
        }
        .padding(.horizontal, 20)
    }
    
    private func categoryRow(_ category: RuleCategory, isEnabled: Bool, isCustom: Bool = false) -> some View {
        HStack(spacing: 16) {
            // Drag handle (only in edit mode for enabled categories)
            if editMode == .active && isEnabled && !isCustom {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16))
                    .foregroundColor(theme.textSecondaryColor)
            }
            
            // Category icon
            Image(systemName: category.symbolName)
                .font(.system(size: 20))
                .foregroundColor(isEnabled ? theme.accentColor : theme.textSecondaryColor)
                .frame(width: 32)
            
            // Category info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.textPrimaryColor)
                
                if !category.description.isEmpty {
                    Text(category.description)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSecondaryColor)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Toggle or custom badge
            if isCustom {
                Text("Custom")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accentSoftColor)
                    .cornerRadius(6)
            } else {
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { newValue in
                        toggleCategory(category, enabled: newValue)
                    }
                ))
                .labelsHidden()
                .tint(theme.accentColor)
            }
        }
        .padding(16)
        .background(theme.surfaceColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.strokeColor, lineWidth: 1)
        )
    }
    
    // MARK: - Actions
    
    private func toggleCategory(_ category: RuleCategory, enabled: Bool) {
        categoryManager.toggleCategory(category)
    }
    
}

// MARK: - Create Custom Category Sheet

struct CreateCustomCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    let theme: AppTheme
    let onCreate: (RuleCategory) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star"
    
    private let iconOptions = [
        "star", "heart", "bolt", "flame", "leaf",
        "book", "pencil", "lightbulb", "target", "flag",
        "trophy", "crown", "sparkles", "moon.stars", "sun.max"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.textSecondaryColor)
                        
                        TextField("e.g., Creative Projects", text: $name)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(theme.surfaceColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.strokeColor, lineWidth: 1)
                            )
                    }
                    
                    // Description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.textSecondaryColor)
                        
                        TextField("Brief description", text: $description)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(theme.surfaceColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.strokeColor, lineWidth: 1)
                            )
                    }
                    
                    // Icon picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.textSecondaryColor)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                iconButton(icon)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.backgroundPrimaryColor)
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.textSecondaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createCategory()
                    }
                    .foregroundColor(theme.accentColor)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func iconButton(_ icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(selectedIcon == icon ? .white : theme.accentColor)
                .frame(width: 60, height: 60)
                .background(selectedIcon == icon ? theme.accentColor : theme.accentSoftColor)
                .cornerRadius(12)
        }
    }
    
    private func createCategory() {
        let category = RuleCategory(
            name: name,
            symbolName: selectedIcon,
            description: description,
            isEnabled: true,
            isCustom: true,
            sortOrder: 999
        )
        onCreate(category)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Manage Categories") {
    ManageCategoriesView()
        .environmentObject(ThemeManager())
        .environmentObject(CategoryManager())
}

#Preview("Create Custom Category") {
    CreateCustomCategorySheet(
        theme: .sageCalm,
        onCreate: { _ in }
    )
}
