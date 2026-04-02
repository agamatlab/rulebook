import SwiftUI

// MARK: - Motion System
// Slow, intentional, continuous motion that respects accessibility

struct MotionSystem {
    
    // MARK: - Accessibility Check
    static var reduceMotion: Bool {
        #if os(iOS)
        return UIAccessibility.isReduceMotionEnabled
        #else
        return false
        #endif
    }
    
    // MARK: - Standard Animations
    
    static var quickSpring: SwiftUI.Animation {
        .spring(response: DesignSystem.Animation.springResponse, dampingFraction: DesignSystem.Animation.springDamping)
    }
    
    static var standardSpring: SwiftUI.Animation {
        .spring(response: DesignSystem.Animation.standard, dampingFraction: DesignSystem.Animation.springDamping)
    }
    
    static var slowSpring: SwiftUI.Animation {
        .spring(response: DesignSystem.Animation.slow, dampingFraction: DesignSystem.Animation.springDamping)
    }
    
    static var verySlowSpring: SwiftUI.Animation {
        .spring(response: DesignSystem.Animation.verySlow, dampingFraction: DesignSystem.Animation.springDamping)
    }
    
    // MARK: - Tap Feedback
    static func tapFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        #endif
    }
    
    // MARK: - List Entrance (fade + slight rise)
    struct ListEntranceModifier: ViewModifier {
        let index: Int
        @State private var appeared = false
        
        func body(content: Content) -> some View {
            content
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .onAppear {
                    withAnimation(
                        .easeOut(duration: DesignSystem.Animation.standard)
                        .delay(Double(index) * 0.05)
                    ) {
                        appeared = true
                    }
                }
        }
    }
    
    // MARK: - Symbol Effects (iOS 18+)
    @available(iOS 18.0, *)
    @available(iOS 18.0, *)
    struct SymbolBreathe: ViewModifier {
        let isActive: Bool
        
        func body(content: Content) -> some View {
            if isActive && !MotionSystem.reduceMotion {
                content
                    .symbolEffect(.breathe.pulse, options: .speed(0.5))
            } else {
                content
            }
        }
    }
    
    @available(iOS 17.0, *)
    struct SymbolPulse: ViewModifier {
        func body(content: Content) -> some View {
            if !MotionSystem.reduceMotion {
                content
                    .symbolEffect(.pulse, options: .speed(0.8).repeat(1))
            } else {
                content
            }
        }
    }
    
    // MARK: - Scroll Transitions (iOS 17+)
    @available(iOS 17.0, *)
    struct SoftScrollTransition: ViewModifier {
        func body(content: Content) -> some View {
            if !MotionSystem.reduceMotion {
                content
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.7)
                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                    }
            } else {
                content
            }
        }
    }
    
    // MARK: - Card to Detail Transition
    struct CardZoomTransition: ViewModifier {
        let namespace: Namespace.ID
        let id: String
        
        func body(content: Content) -> some View {
            content
                .matchedGeometryEffect(id: id, in: namespace)
        }
    }
}

// MARK: - View Extensions

extension View {
    func listEntrance(index: Int) -> some View {
        modifier(MotionSystem.ListEntranceModifier(index: index))
    }
    
    @available(iOS 18.0, *)
    func symbolBreathe(isActive: Bool = true) -> some View {
        modifier(MotionSystem.SymbolBreathe(isActive: isActive))
    }
    
    @available(iOS 17.0, *)
    func symbolPulseOnce() -> some View {
        modifier(MotionSystem.SymbolPulse())
    }
    
    @available(iOS 17.0, *)
    func softScrollTransition() -> some View {
        modifier(MotionSystem.SoftScrollTransition())
    }
    
    func cardZoomTransition(namespace: Namespace.ID, id: String) -> some View {
        modifier(MotionSystem.CardZoomTransition(namespace: namespace, id: id))
    }
}
