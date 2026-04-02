import SwiftUI

// MARK: - Theme Definitions
// All 6 starter themes for the Rulebook app

extension AppTheme {
    // MARK: - Sage Calm
    static let sageCalm = AppTheme(
        id: "sage-calm",
        name: "Sage Calm",
        accent: ColorComponents(red: 0.42, green: 0.58, blue: 0.49),           // #6B9479
        accentSoft: ColorComponents(red: 0.42, green: 0.58, blue: 0.49, opacity: 0.15),
        backgroundPrimary: ColorComponents(red: 0.98, green: 0.98, blue: 0.97), // #FAFAF8
        backgroundSecondary: ColorComponents(red: 0.95, green: 0.96, blue: 0.94), // #F2F4F0
        surface: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),              // #FFFFFF
        surfaceElevated: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),      // #FFFFFF
        textPrimary: ColorComponents(red: 0.13, green: 0.15, blue: 0.13),       // #212621
        textSecondary: ColorComponents(red: 0.42, green: 0.46, blue: 0.42),     // #6B756B
        stroke: ColorComponents(red: 0.85, green: 0.87, blue: 0.84),            // #D9DED6
        success: ColorComponents(red: 0.42, green: 0.58, blue: 0.49),           // #6B9479
        warning: ColorComponents(red: 0.85, green: 0.55, blue: 0.38),           // #D98C61
        calendarComplete: ColorComponents(red: 0.42, green: 0.58, blue: 0.49),  // Uses accent
        calendarMissed: ColorComponents(red: 0.85, green: 0.55, blue: 0.38),    // #D98C61
        calendarNeutral: ColorComponents(red: 0.85, green: 0.87, blue: 0.84)    // #D9DED6
    )
    
    // MARK: - Sky Mist
    static let skyMist = AppTheme(
        id: "sky-mist",
        name: "Sky Mist",
        accent: ColorComponents(red: 0.40, green: 0.60, blue: 0.75),           // #6699BF
        accentSoft: ColorComponents(red: 0.40, green: 0.60, blue: 0.75, opacity: 0.15),
        backgroundPrimary: ColorComponents(red: 0.97, green: 0.98, blue: 0.99), // #F8FAFC
        backgroundSecondary: ColorComponents(red: 0.94, green: 0.96, blue: 0.98), // #F0F4F8
        surface: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),              // #FFFFFF
        surfaceElevated: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),      // #FFFFFF
        textPrimary: ColorComponents(red: 0.12, green: 0.16, blue: 0.20),       // #1F2933
        textSecondary: ColorComponents(red: 0.40, green: 0.47, blue: 0.54),     // #66788A
        stroke: ColorComponents(red: 0.82, green: 0.88, blue: 0.93),            // #D1E0ED
        success: ColorComponents(red: 0.40, green: 0.60, blue: 0.75),           // #6699BF
        warning: ColorComponents(red: 0.95, green: 0.65, blue: 0.35),           // #F2A659
        calendarComplete: ColorComponents(red: 0.40, green: 0.60, blue: 0.75),  // Uses accent
        calendarMissed: ColorComponents(red: 0.95, green: 0.65, blue: 0.35),    // #F2A659
        calendarNeutral: ColorComponents(red: 0.82, green: 0.88, blue: 0.93)    // #D1E0ED
    )
    
    // MARK: - Lavender Haze
    static let lavenderHaze = AppTheme(
        id: "lavender-haze",
        name: "Lavender Haze",
        accent: ColorComponents(red: 0.60, green: 0.52, blue: 0.75),           // #9985BF
        accentSoft: ColorComponents(red: 0.60, green: 0.52, blue: 0.75, opacity: 0.15),
        backgroundPrimary: ColorComponents(red: 0.98, green: 0.97, blue: 0.99), // #FAF8FC
        backgroundSecondary: ColorComponents(red: 0.96, green: 0.94, blue: 0.98), // #F5F0F8
        surface: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),              // #FFFFFF
        surfaceElevated: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),      // #FFFFFF
        textPrimary: ColorComponents(red: 0.15, green: 0.12, blue: 0.20),       // #261F33
        textSecondary: ColorComponents(red: 0.47, green: 0.40, blue: 0.54),     // #78668A
        stroke: ColorComponents(red: 0.87, green: 0.82, blue: 0.93),            // #DED1ED
        success: ColorComponents(red: 0.60, green: 0.52, blue: 0.75),           // #9985BF
        warning: ColorComponents(red: 0.90, green: 0.60, blue: 0.50),           // #E69980
        calendarComplete: ColorComponents(red: 0.60, green: 0.52, blue: 0.75),  // Uses accent
        calendarMissed: ColorComponents(red: 0.90, green: 0.60, blue: 0.50),    // #E69980
        calendarNeutral: ColorComponents(red: 0.87, green: 0.82, blue: 0.93)    // #DED1ED
    )
    
    // MARK: - Peach Sand
    static let peachSand = AppTheme(
        id: "peach-sand",
        name: "Peach Sand",
        accent: ColorComponents(red: 0.90, green: 0.65, blue: 0.50),           // #E6A680
        accentSoft: ColorComponents(red: 0.90, green: 0.65, blue: 0.50, opacity: 0.15),
        backgroundPrimary: ColorComponents(red: 0.99, green: 0.98, blue: 0.97), // #FCF9F7
        backgroundSecondary: ColorComponents(red: 0.98, green: 0.95, blue: 0.93), // #FAF2ED
        surface: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),              // #FFFFFF
        surfaceElevated: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),      // #FFFFFF
        textPrimary: ColorComponents(red: 0.20, green: 0.15, blue: 0.12),       // #33261F
        textSecondary: ColorComponents(red: 0.54, green: 0.47, blue: 0.42),     // #8A786B
        stroke: ColorComponents(red: 0.93, green: 0.87, blue: 0.82),            // #EDDDD1
        success: ColorComponents(red: 0.90, green: 0.65, blue: 0.50),           // #E6A680
        warning: ColorComponents(red: 0.85, green: 0.55, blue: 0.38),           // #D98C61
        calendarComplete: ColorComponents(red: 0.90, green: 0.65, blue: 0.50),  // Uses accent
        calendarMissed: ColorComponents(red: 0.85, green: 0.55, blue: 0.38),    // #D98C61
        calendarNeutral: ColorComponents(red: 0.93, green: 0.87, blue: 0.82)    // #EDDDD1
    )
    
    // MARK: - Monochrome Light
    static let monochromeLight = AppTheme(
        id: "monochrome-light",
        name: "Monochrome Light",
        accent: ColorComponents(red: 0.20, green: 0.20, blue: 0.20),           // #333333
        accentSoft: ColorComponents(red: 0.20, green: 0.20, blue: 0.20, opacity: 0.15),
        backgroundPrimary: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),    // #FFFFFF
        backgroundSecondary: ColorComponents(red: 0.97, green: 0.97, blue: 0.97), // #F7F7F7
        surface: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),              // #FFFFFF
        surfaceElevated: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),      // #FFFFFF
        textPrimary: ColorComponents(red: 0.13, green: 0.13, blue: 0.13),       // #212121
        textSecondary: ColorComponents(red: 0.47, green: 0.47, blue: 0.47),     // #787878
        stroke: ColorComponents(red: 0.88, green: 0.88, blue: 0.88),            // #E0E0E0
        success: ColorComponents(red: 0.20, green: 0.20, blue: 0.20),           // #333333
        warning: ColorComponents(red: 0.40, green: 0.40, blue: 0.40),           // #666666
        calendarComplete: ColorComponents(red: 0.20, green: 0.20, blue: 0.20),  // Uses accent
        calendarMissed: ColorComponents(red: 0.40, green: 0.40, blue: 0.40),    // #666666
        calendarNeutral: ColorComponents(red: 0.88, green: 0.88, blue: 0.88)    // #E0E0E0
    )
    
    // MARK: - Monochrome Dark
    static let monochromeDark = AppTheme(
        id: "monochrome-dark",
        name: "Monochrome Dark",
        accent: ColorComponents(red: 0.85, green: 0.85, blue: 0.85),            // #D9D9D9 - Light gray for contrast
        accentSoft: ColorComponents(red: 0.85, green: 0.85, blue: 0.85, opacity: 0.15),
        backgroundPrimary: ColorComponents(red: 0.07, green: 0.07, blue: 0.07), // #121212 - Darker
        backgroundSecondary: ColorComponents(red: 0.11, green: 0.11, blue: 0.11), // #1C1C1C
        surface: ColorComponents(red: 0.15, green: 0.15, blue: 0.15),           // #262626 - Lighter surface
        surfaceElevated: ColorComponents(red: 0.20, green: 0.20, blue: 0.20),   // #333333 - More elevated
        textPrimary: ColorComponents(red: 1.0, green: 1.0, blue: 1.0),          // #FFFFFF - Pure white
        textSecondary: ColorComponents(red: 0.65, green: 0.65, blue: 0.65),     // #A6A6A6 - Medium gray
        stroke: ColorComponents(red: 0.30, green: 0.30, blue: 0.30),            // #4D4D4D - More visible
        success: ColorComponents(red: 0.85, green: 0.85, blue: 0.85),           // #D9D9D9
        warning: ColorComponents(red: 0.60, green: 0.60, blue: 0.60),           // #999999 - Medium gray
        calendarComplete: ColorComponents(red: 0.85, green: 0.85, blue: 0.85),  // #D9D9D9
        calendarMissed: ColorComponents(red: 0.60, green: 0.60, blue: 0.60),    // #999999
        calendarNeutral: ColorComponents(red: 0.30, green: 0.30, blue: 0.30)    // #4D4D4D
    )
    
    // MARK: - All Themes Collection
    static let allThemes: [AppTheme] = [
        .sageCalm,
        .skyMist,
        .lavenderHaze,
        .peachSand,
        .monochromeLight,
        .monochromeDark
    ]
    
    // MARK: - Default Theme
    static let `default` = sageCalm
}
