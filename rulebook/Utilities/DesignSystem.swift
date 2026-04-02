import SwiftUI
import UIKit

// MARK: - Design System
// Shared visual foundation for Personal Rulebook and Future Message
// Philosophy: Native, restrained, expensive. Design for continuity, not decoration.

struct DesignSystem {
    
    // MARK: - Personal Rulebook Theme
    struct PersonalRulebook {
        static let primaryAccent = Color("RulebookIndigo", bundle: nil) ?? Color(red: 0.29, green: 0.33, blue: 0.55)
        static let secondaryAccent = Color("RulebookSage", bundle: nil) ?? Color(red: 0.55, green: 0.65, blue: 0.55)
        static let background = Color(uiColor: .systemGroupedBackground)
        static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.22)
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.47)
    }
    
    // MARK: - Future Message Theme (placeholder for sister app)
    struct FutureMessage {
        static let primaryAccent = Color(red: 0.4, green: 0.35, blue: 0.5)
        static let secondaryAccent = Color(red: 0.6, green: 0.55, blue: 0.65)
        static let background = Color(uiColor: .systemGroupedBackground)
        static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.22)
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.47)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Generous top spacing
        static let topGenerous: CGFloat = 60
        
        // Bottom safe-area breathing room
        static let bottomBreathing: CGFloat = 20
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Animation Durations
    struct Animation {
        // Slow enough to feel intentional
        static let quick: Double = 0.2
        static let standard: Double = 0.35
        static let slow: Double = 0.5
        static let verySlow: Double = 0.8
        
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
    }
    
    // MARK: - SF Symbols (outline only)
    struct Symbols {
        // Personal Rulebook
        static let bookClosed = "book.closed"
        static let bookmark = "bookmark"
        static let checklist = "checklist"
        static let arrowTurnDownRight = "arrow.turn.down.right"
        static let moon = "moon"
        static let briefcase = "briefcase"
        static let wallet = "wallet"
        static let heartTextSquare = "heart.text.square"
        static let plus = "plus"
        static let chevronRight = "chevron.right"
        static let ellipsis = "ellipsis"
        
        // Categories
        static let money = "dollarsign.circle"
        static let work = "briefcase"
        static let health = "heart"
        static let social = "person.2"
        static let home = "house"
    }
}

// MARK: - Reusable Modifiers

struct SoftCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
    }
}

struct GenerousTopSpacing: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, DesignSystem.Spacing.topGenerous)
    }
}

struct BottomBreathing: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom, DesignSystem.Spacing.bottomBreathing)
    }
}

extension View {
    func softCard() -> some View {
        modifier(SoftCardStyle())
    }
    
    func generousTopSpacing() -> some View {
        modifier(GenerousTopSpacing())
    }
    
    func bottomBreathing() -> some View {
        modifier(BottomBreathing())
    }
}
