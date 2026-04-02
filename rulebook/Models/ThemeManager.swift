import SwiftUI

// MARK: - Theme Manager
// Manages the current theme with smooth animations and persistence

@MainActor
class ThemeManager: ObservableObject {
    @Published private(set) var currentTheme: AppTheme
    
    private let userDefaultsKey = "selectedThemeId"
    
    init() {
        // Load saved theme or use default
        if let savedThemeId = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedTheme = AppTheme.allThemes.first(where: { $0.id == savedThemeId }) {
            self.currentTheme = savedTheme
        } else {
            self.currentTheme = .default
        }
    }
    
    // MARK: - Theme Selection
    
    func setTheme(_ theme: AppTheme, animated: Bool = true) {
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentTheme = theme
            }
        } else {
            currentTheme = theme
        }
        
        // Persist selection
        UserDefaults.standard.set(theme.id, forKey: userDefaultsKey)
    }
    
    func setThemeById(_ id: String, animated: Bool = true) {
        guard let theme = AppTheme.allThemes.first(where: { $0.id == id }) else {
            return
        }
        setTheme(theme, animated: animated)
    }
    
    // MARK: - Theme Queries
    
    var availableThemes: [AppTheme] {
        AppTheme.allThemes
    }
    
    // MARK: - Convenience Accessors
    
    var accent: Color { currentTheme.accentColor }
    var accentSoft: Color { currentTheme.accentSoftColor }
    var backgroundPrimary: Color { currentTheme.backgroundPrimaryColor }
    var backgroundSecondary: Color { currentTheme.backgroundSecondaryColor }
    var surface: Color { currentTheme.surfaceColor }
    var surfaceElevated: Color { currentTheme.surfaceElevatedColor }
    var textPrimary: Color { currentTheme.textPrimaryColor }
    var textSecondary: Color { currentTheme.textSecondaryColor }
    var stroke: Color { currentTheme.strokeColor }
    var success: Color { currentTheme.successColor }
    var warning: Color { currentTheme.warningColor }
    var calendarComplete: Color { currentTheme.calendarCompleteColor }
    var calendarMissed: Color { currentTheme.calendarMissedColor }
    var calendarNeutral: Color { currentTheme.calendarNeutralColor }
}

// MARK: - Environment Key
private struct ThemeManagerKey: EnvironmentKey {
    @MainActor static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    func themeManager(_ manager: ThemeManager) -> some View {
        environment(\.themeManager, manager)
    }
}
