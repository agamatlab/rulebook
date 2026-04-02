import SwiftUI

// MARK: - Theme System
// All colors in the app come from theme tokens

struct AppTheme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let accent: ColorComponents
    let accentSoft: ColorComponents
    let backgroundPrimary: ColorComponents
    let backgroundSecondary: ColorComponents
    let surface: ColorComponents
    let surfaceElevated: ColorComponents
    let textPrimary: ColorComponents
    let textSecondary: ColorComponents
    let stroke: ColorComponents
    let success: ColorComponents
    let warning: ColorComponents
    let calendarComplete: ColorComponents
    let calendarMissed: ColorComponents
    let calendarNeutral: ColorComponents
    
    var accentColor: Color { accent.toColor() }
    var accentSoftColor: Color { accentSoft.toColor() }
    var backgroundPrimaryColor: Color { backgroundPrimary.toColor() }
    var backgroundSecondaryColor: Color { backgroundSecondary.toColor() }
    var surfaceColor: Color { surface.toColor() }
    var surfaceElevatedColor: Color { surfaceElevated.toColor() }
    var textPrimaryColor: Color { textPrimary.toColor() }
    var textSecondaryColor: Color { textSecondary.toColor() }
    var strokeColor: Color { stroke.toColor() }
    var successColor: Color { success.toColor() }
    var warningColor: Color { warning.toColor() }
    var calendarCompleteColor: Color { calendarComplete.toColor() }
    var calendarMissedColor: Color { calendarMissed.toColor() }
    var calendarNeutralColor: Color { calendarNeutral.toColor() }
}

struct ColorComponents: Codable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
    
    func toColor() -> Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
