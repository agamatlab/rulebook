import SwiftUI

struct OnboardingCategoriesView: View {
    let onContinue: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var categoryManager: CategoryManager
    
    @State private var selectedCategories: Set<UUID> = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(spacing: 20) {
                    categoryGrid
                    
                    subtleNote
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            
            Spacer()
            
            continueButton
        }
        .background(themeManager.backgroundPrimary.ignoresSafeArea())
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("What do you want Rulebook to help with?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 24)
                .padding(.top, 60)
        }
    }
    
    // MARK: - Category Grid
    
    private var categoryGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categoryManager.categories.prefix(8)) { category in
                OnboardingCategoryTile(
                    category: category,
                    isSelected: selectedCategories.contains(category.id),
                    onTap: {
                        toggleCategory(category)
                    }
                )
            }
            
            moreCategoriesTile
        }
    }
    
    private var moreCategoriesTile: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
                
                Text("More categories")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(themeManager.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(themeManager.stroke, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Subtle Note
    
    private var subtleNote: some View {
        Text("You can change this later")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(themeManager.textSecondary.opacity(0.7))
            .padding(.top, 8)
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(themeManager.stroke)
            
            Button(action: handleContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedCategories.isEmpty ? themeManager.textSecondary.opacity(0.3) : themeManager.accent)
                    )
            }
            .disabled(selectedCategories.isEmpty)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(themeManager.backgroundPrimary)
        }
    }
    
    // MARK: - Actions
    
    private func toggleCategory(_ category: RuleCategory) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCategories.contains(category.id) {
                selectedCategories.remove(category.id)
            } else {
                selectedCategories.insert(category.id)
            }
        }
    }
    
    private func handleContinue() {
        // Save selected categories to app state
        appState.selectedCategories = selectedCategories
        onContinue()
    }
}

// MARK: - Onboarding Category Tile

struct OnboardingCategoryTile: View {
    let category: RuleCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 8) {
                        Image(systemName: category.symbolName)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(isSelected ? themeManager.accent : themeManager.textSecondary)
                        
                        Text(category.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    
                    if isSelected {
                        checkmark
                            .padding(8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? themeManager.accentSoft : themeManager.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? themeManager.accent.opacity(0.4) : themeManager.stroke,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var checkmark: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(themeManager.accent)
            .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    OnboardingCategoriesView(onContinue: {})
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
        .environmentObject(CategoryManager())
}
